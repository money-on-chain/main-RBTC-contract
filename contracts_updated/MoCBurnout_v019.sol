pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./base/MoCBase.sol";
import "./PartialExecution.sol";
import "./token/DocToken.sol";
import "./MoCExchange.sol";

contract MoCBurnoutEvents {
  event BurnoutAddressSet(address indexed account, address burnoutAddress);
  event BurnoutExecuted(uint256 addressCount);
  event BurnoutAddressProcessed(address indexed account, address burnoutAddress, uint256 btcAmount);
}
/*****************************************************/
/*****   THIS CONTRACT IS DEPRECATED SINCE V0110 *****/
/*****************************************************/
/**
 * @title Burnout Queue for liquidation event
 * @dev Track all Burnout addresses that will be used in liquidation event. When liquidation happens
 * all Docs of the holders in the queue will be sent to the corresponding burnout address.
 */
contract MoCBurnout_v019 is MoCBase, MoCBurnoutEvents, PartialExecution {
  using SafeMath for uint256;

  // Contracts
  DocToken internal docToken;
  MoCExchange internal mocExchange;
  MoCState internal mocState;

  bytes32 internal constant BURNOUT_TASK = keccak256("Burnout");

  // Burnout addresses
  mapping(address => address payable) burnoutBook;
  // Used to iterate in liquidation event
  address[] private burnoutQueue;
  uint256 private numElements;

  function initialize(
    address connectorAddress
  ) public initializer {
    initializeBase(connectorAddress);
    initializeContracts();
    initializeTasks();
  }

  function isBurnoutRunning() public view returns(bool) {
    return isTaskRunning(BURNOUT_TASK);
  }

  /**
    @dev Return current burnout queue size
   */
  function burnoutQueueSize() public view returns(uint256) {
    return numElements;
  }

  /**
    @dev Returns the burnout address for _who address
    @param _who Address to find burnout address
    @return Burnout address
   */
  function getBurnoutAddress(address _who) public view returns(address) {
    return burnoutBook[_who];
  }

  /**
    @dev push a new burnout address to the queue for _who
    @param _who address for which set the burnout address
    @param _burnout address to send docs in liquidation event
  */
  function pushBurnoutAddress(address _who, address payable _burnout) public onlyWhitelisted(msg.sender) {
    require(_burnout != address(0x0), "Burnout address can't be 0x0");

    if (burnoutBook[_who] == address(0x0)) {
      pushAddressToQueue(_who);
    }

    burnoutBook[_who] = _burnout;
    emit BurnoutAddressSet(_who, _burnout);
  }

  /**
    @dev Iterate over the burnout address book and redeem docs
  **/
  function executeBurnout(uint256 steps) public onlyWhitelisted(msg.sender) {
    executeTask(BURNOUT_TASK, steps);
  }

  function burnoutStep(uint256 index) internal {
    address account = burnoutQueue[index];
    address payable burnout = burnoutBook[account];
    uint256 btcTotal = mocExchange.redeemAllDoc(account, burnout);

    emit BurnoutAddressProcessed(account, burnout, btcTotal);
  }

  function finishBurnout() internal {
    emit BurnoutExecuted(numElements);
    clearBook();
  }

  function burnoutStepCount() internal view returns(uint256) {
    return numElements;
  }

  function pushAddressToQueue(address _who) internal {
    if (numElements == burnoutQueue.length) {
      burnoutQueue.length += 1;
    }

    burnoutQueue[numElements++] = _who;
  }

  /**
    @dev empty the queue
   */
  function clearBook() internal {
    numElements = 0;
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    mocExchange = MoCExchange(connector.mocExchange());
    mocState = MoCState(connector.mocState());
  }

  /**
    @dev Create Task structures for Settlement execution
  */
  function initializeTasks() internal {
    createTask(BURNOUT_TASK, burnoutStepCount, burnoutStep, noFunction, finishBurnout);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
