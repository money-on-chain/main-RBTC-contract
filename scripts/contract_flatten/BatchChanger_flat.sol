// SPDX-License-Identifier: MIT
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

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

// File: contracts/changers/BatchChanger.sol

pragma solidity ^0.5.0;
// solium-disable no-experimental
pragma experimental ABIEncoderV2;


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
