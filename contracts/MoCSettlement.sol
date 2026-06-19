pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./base/MoCBase.sol";
import "./token/DocToken.sol";
import "./interface/IMoCState.sol";
import "./interface/IMoCExchange.sol";
import "./MoCBProxManager.sol";
import "./PartialExecution.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";
import "./interface/IMoCVendors.sol";
import "./interface/IMoCSettlement.sol";

contract MoCSettlementEvents {
  event SettlementCompleted(uint256 commissionsPayed);
}

contract MoCSettlement is
MoCSettlementEvents,
MoCBase,
PartialExecution,
Governed,
IMoCSettlement
{
  using Math for uint256;
  using SafeMath for uint256;

  bytes32 public constant DOC_REDEMPTION_TASK = keccak256("DocRedemption");
  bytes32 public constant DELEVERAGING_TASK = keccak256("Deleveraging");
  bytes32 public constant SETTLEMENT_TASK = keccak256("Settlement");

  struct RedeemRequest {
    address payable who;
    uint256 amount;
  }

  struct UserRedeemRequest {
    uint256 index;
    bool activeRedeemer;
  }

  // All necessary data for Settlement execution
  struct SettlementInfo {
    uint256 btcPrice;
    uint256 btcxPrice;
    uint256 docRedeemCount;
    uint256 deleveragingCount;
    uint256 bproxAmount;
    uint256 partialCommissionAmount;
    uint256 finalCommissionAmount;
    uint256 leverage;
    uint256 startBlockNumber;
    bool isProtectedMode;
  }

  // Contracts
  IMoCState internal mocState;
  IMoCExchange internal mocExchange;
  DocToken internal docToken;
  MoCBProxManager internal bproxManager;

  /**
  @dev Block Number of the last successful execution
  */
  uint256 internal lastProcessedBlock;
  /**
  @dev Min number of blocks settlement should be re evaluated on
  */
  uint256 internal blockSpan;
  /**
  @dev Information for Settlement execution
  */
  SettlementInfo internal settlementInfo;
  /**
  @dev Redeem queue
  */
  RedeemRequest[] private redeemQueue;
  uint256 private redeemQueueLength;

  mapping(address => UserRedeemRequest) private redeemMapping;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
    @param _blockSpan Blockspan configuration blockspan of settlement
  */
  function initialize(
    address connectorAddress,
    address _governor,
    uint256 _blockSpan
  ) public initializer {
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _blockSpan);
  }

  /**
   *  @dev Set the blockspan configuration blockspan of settlement
   */
  function setBlockSpan(uint256 bSpan) public onlyAuthorizedChanger() {
    blockSpan = bSpan;
  }

  /**
    @dev Gets the RedeemRequest at the queue index position
    @return redeemer's address and amount he submitted
  */
  function getRedeemRequestAt(uint256 /*_index*/)
  public
  pure
  returns (address payable, uint256)
  {
    return (address(0), 0);
  }

  /**
    @dev Gets the number of blocks the settlemnet will be allowed to run
  */
  function getBlockSpan() public view returns (uint256) {
    return blockSpan;
  }

  /**
    @dev Returns the current redeem request queue's length
  */
  function redeemQueueSize() public pure returns (uint256) {
    return 0;
  }

  /**
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
  function isSettlementEnabled() public view returns (bool) {
    return nextSettlementBlock() <= block.number;
  }

  /**
    @dev Returns the next block from which settlement is possible
  */
  function nextSettlementBlock() public view returns (uint256) {
    return lastProcessedBlock.add(blockSpan);
  }

  /**
    @dev returns the total amount of Docs in the redeem queue for _who
    @return total amount of Docs in the redeem queue for _who [using mocPrecision]
  */
  function docAmountToRedeem(address /*_who*/) public pure returns (uint256) {
    return 0;
  }

  /**
    @dev Runs settlement process in steps
    @return The commissions collected in the executed steps
  */
  function runSettlement(uint256 /*steps*/)
  public
  onlyWhitelisted(msg.sender)
  isTime()
  returns (uint256)
  {
    lastProcessedBlock = block.number;
    // Reset total paid in MoC for every vendor
    IMoCVendors mocVendors = IMoCVendors(mocState.getMoCVendors());
    mocVendors.resetTotalPaidInMoC();
    emit SettlementCompleted(0);
    return 0;
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = IMoCState(connector.mocState());
    mocExchange = IMoCExchange(connector.mocExchange());
  }

  function initializeValues(address _governor, uint256 _blockSpan) internal {
    governor = IGovernor(_governor);
    blockSpan = _blockSpan;
    lastProcessedBlock = block.number;
  }


  modifier isTime() {
    require(isSettlementEnabled(), "Settlement not yet enabled");
    _;
  }

  /**************************************************/
  /******************** TASKS ***********************/
  /**************************************************/

/**
  @dev Returns the amount of steps for the Deleveraging task
  which is the amount of active BProx addresses
*/
  function deleveragingStepCount() internal pure returns (uint256) {
    return 0;
  }

  /**
  @dev Returns the amount of steps for the Doc Redemption task
  which is the amount of redeem requests in the queue
*/
  function docRedemptionStepCount() internal pure returns (uint256) {
    return 0;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
