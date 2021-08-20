// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
// solium-disable no-experimental
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

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