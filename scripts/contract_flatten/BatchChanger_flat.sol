/*
Copyright MOC Investments Corp. 2020. All rights reserved.

You acknowledge and agree that MOC Investments Corp. (“MOC”) (or MOC’s licensors) own all legal right, title and interest in and to the work, software, application, source code, documentation and any other documents in this repository (collectively, the “Program”), including any intellectual property rights which subsist in the Program (whether those rights happen to be registered or not, and wherever in the world those rights may exist), whether in source code or any other form.

Subject to the limited license below, you may not (and you may not permit anyone else to) distribute, publish, copy, modify, merge, combine with another program, create derivative works of, reverse engineer, decompile or otherwise attempt to extract the source code of, the Program or any part thereof, except that you may contribute to this repository.

You are granted a non-exclusive, non-transferable, non-sublicensable license to distribute, publish, copy, modify, merge, combine with another program or create derivative works of the Program (such resulting program, collectively, the “Resulting Program”) solely for Non-Commercial Use as long as you:
 1. give prominent notice (“Notice”) with each copy of the Resulting Program that the Program is used in the Resulting Program and that the Program is the copyright of MOC Investments Corp.; and
 2. subject the Resulting Program and any distribution, publication, copy, modification, merger therewith, combination with another program or derivative works thereof to the same Notice requirement and Non-Commercial Use restriction set forth herein.

“Non-Commercial Use” means each use as described in clauses (1)-(3) below, as reasonably determined by MOC Investments Corp. in its sole discretion:
 1. personal use for research, personal study, private entertainment, hobby projects or amateur pursuits, in each case without any anticipated commercial application;
 2. use by any charitable organization, educational institution, public research organization, public safety or health organization, environmental protection organization or government institution; or
 3. the number of monthly active users of the Resulting Program across all versions thereof and platforms globally do not exceed 100 at any time.

You will not use any trade mark, service mark, trade name, logo of MOC Investments Corp. or any other company or organization in a way that is likely or intended to cause confusion about the owner or authorized user of such marks, names or logos.

If you have any questions, comments or interest in pursuing any other use cases, please reach out to us at moc.license@moneyonchain.com.

*/

pragma solidity ^0.5.0;
// solium-disable no-experimental
pragma experimental ABIEncoderV2;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Adaptation of https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/governance/BatchChanger.sol
/**
 * @dev Contract module that groups operations to be run by the Governor in a single transaction
 */
contract BatchChanger is Ownable {
  address[] public targetsToExecute;
  bytes[] public datasToExecute;

  /**
   * @dev Emitted when a call is scheduled.
   */
  event CallScheduled(address indexed target, bytes data);

  /**
    * @dev Emitted when a call is performed.
    */
  event CallExecuted(address indexed target, bytes data);

  /**
   * @dev Length of the targetsToExecute array
   */
  function targetsToExecuteLength() public view returns(uint) {
    return targetsToExecute.length;
  }

  /**
   * @dev Length of the datasToExecute array
   */
  function datasToExecuteLength() public view returns(uint) {
    return datasToExecute.length;
  }

  /**
    * @dev Schedule an operation containing a batch of transactions.
    *
    * Emits one {CallScheduled} event per transaction in the batch.
    *
    */
  function scheduleBatch(
    address[] memory targets,
    bytes[] memory datas
  ) public onlyOwner {
    require(targets.length == datas.length, "BatchChanger: length mismatch");

    for (uint256 i = 0; i < targets.length; ++i) {
      _schedule(targets[i], datas[i]);
    }
  }

  /**
    * @dev Execute an (ready) operation containing a batch of transactions.
    *
    * Emits one {CallExecuted} event per transaction in the batch.
    *
    * Should be called by the governor, but this contract does not check that explicitly because
    * it is not its responsability in the current architecture
    */
  function execute() public {
    for (uint256 i = 0; i < targetsToExecute.length; ++i) {
      _call(targetsToExecute[i], datasToExecute[i]);
    }
    delete targetsToExecute;
    delete datasToExecute;
  }

  /**
    * @dev Execute an operation's call.
    *
    * Emits a {CallExecuted} event.
    */
  function _call(
    address target,
    bytes memory data
  ) private {
    // solium-disable security/no-low-level-calls
    (bool success, bytes memory returndata) = target.call(data);
    require(success, string(returndata));

    emit CallExecuted(target, data);
  }

  /**
   * @dev Schedule an operation containing a single transaction.
   *
   * Emits a {CallScheduled} event.
   *
   */
  function _schedule(
    address target,
    bytes memory data
  ) private {
    targetsToExecute.push(target);
    datasToExecute.push(data);
    emit CallScheduled(target, data);
  }

  /**
    * @dev Schedule a single transaction.
    *
    * Emits one {CallScheduled} event.
    *
    */
  function schedule(
    address target,
    bytes memory data
  ) public onlyOwner {
    _schedule(target, data);
  }

}
