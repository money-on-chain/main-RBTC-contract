pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./base/MoCBase.sol";
import "./token/DocToken.sol";
import "./MoCState.sol";
import "./MoCExchange.sol";
import "./MoCBProxManager.sol";
import "./PartialExecution_v019.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";



contract MoCSettlement_v019 is
    MoCSettlementEvents,
    MoCBase,
    PartialExecution_v019,
    Governed
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
    }

    // Contracts
    MoCState internal mocState;
    MoCExchange internal mocExchange;
    DocToken internal docToken;
    MoCBProxManager internal bproxManager;

    /**
    @dev Block Number of the last successful execution
  **/
    uint256 internal lastProcessedBlock;
    /**
    @dev Min number of blocks settlement should be re evaluated on
  **/
    uint256 internal blockSpan;
    /**
    @dev Information for Settlement execution
  **/
    SettlementInfo internal settlementInfo;
    /**
    @dev Redeem queue
  **/
    RedeemRequest[] private redeemQueue;
    uint256 private redeemQueueLength;

    mapping(address => UserRedeemRequest) private redeemMapping;

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
     *  @dev Set Settlement to be kept in finnished state after
     *  all execution is completed.
     */
    function setSettlementToStall() public onlyAuthorizedChanger() {
        setAutoRestart(SETTLEMENT_TASK, false);
    }

    /**
     *  @dev Set Settlement state to Ready
     */
    function restartSettlementState() public onlyAuthorizedChanger() {
        resetGroup(SETTLEMENT_TASK);
        setAutoRestart(SETTLEMENT_TASK, true);
    }

    /**
    @dev Gets the RedeemRequest at the queue index position
    @param _index queue position to get
    @return redeemer's address and amount he submitted
  */
    function getRedeemRequestAt(uint256 _index)
        public
        view
        withinBoundaries(_index)
        returns (address payable, uint256)
    {
        return (redeemQueue[_index].who, redeemQueue[_index].amount);
    }

    /**
    @dev Gets the number of blocks the settlemnet will be allowed to run
  */
    function getBlockSpan() public view returns (uint256) {
        return blockSpan;
    }

    /**
   @dev Verify that the index is smaller than the length of the redeem request queue
   @param _index queue position to get
   */
    modifier withinBoundaries(uint256 _index) {
        require(_index < redeemQueueLength, "Index out of boundaries");
        _;
    }

    /**
    @dev Returns the current redeem request queue's length
   */
    function redeemQueueSize() public view returns (uint256) {
        return redeemQueueLength;
    }

    /**
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
    function isSettlementEnabled() public view returns (bool) {
        return nextSettlementBlock() <= block.number;
    }

    /**
    @dev Returns true if the settlment is running
  */
    function isSettlementRunning() public view returns (bool) {
        return isGroupRunning(SETTLEMENT_TASK);
    }

    /**
    @dev Returns true if the settlment is ready
  */
    function isSettlementReady() public view returns (bool) {
        return isGroupReady(SETTLEMENT_TASK);
    }

    /**
    @dev Returns the next block from which settlement is possible
   */
    function nextSettlementBlock() public view returns (uint256) {
        return lastProcessedBlock.add(blockSpan);
    }

    /**
    @dev returns the total amount of Docs in the redeem queue for _who
    @param _who address for which ^ is computed
    @return total amount of Docs in the redeem queue for _who [using mocPrecision]
   */
    function docAmountToRedeem(address _who) public view returns (uint256) {
        if (!redeemMapping[_who].activeRedeemer) {
            return 0;
        }

        uint256 indexRedeem = redeemMapping[_who].index;
        RedeemRequest memory redeemRequest = redeemQueue[indexRedeem];
        return redeemRequest.amount;
    }

    /**
    @dev push a new redeem request to the queue for the sender or updates the amount if the user has a redeem request
    @param amount amount he is willing to redeem [using mocPrecision]
    @param redeemer redeemer address
  */
    function addRedeemRequest(uint256 amount, address payable redeemer)
        public
        onlyWhitelisted(msg.sender)
    {
        if (!redeemMapping[redeemer].activeRedeemer) {
            if (redeemQueueLength == redeemQueue.length) {
                redeemQueue.length += 1;
            }
            uint256 index = redeemQueueLength;
            redeemQueue[redeemQueueLength++] = RedeemRequest(redeemer, amount);
            redeemMapping[redeemer] = UserRedeemRequest(index, true);
            emit RedeemRequestAlter(redeemer, true, amount);
        } else {
            alterRedeemRequestAmount(true, amount, redeemer);
        }
    }

    /**
    @dev empty the queue
   */
    function clear() public onlyWhitelisted(msg.sender) {
        redeemQueueLength = 0;
    }

    /**
    @dev Alters the redeem amount position for the redeemer
    @param isAddition true if adding amount to redeem, false to substract.
    @param delta the amount to add/substract to current position [using mocPrecision]
    @param redeemer address to alter amount for
    @return the filled amount [using mocPrecision]
  */
    function alterRedeemRequestAmount(
        bool isAddition,
        uint256 delta,
        address redeemer
    ) public onlyWhitelisted(msg.sender) {
        require(
            redeemMapping[redeemer].activeRedeemer,
            "This is not an active redeemer"
        );
        uint256 indexRedeem = redeemMapping[redeemer].index;
        RedeemRequest storage redeemRequest = redeemQueue[indexRedeem];
        require(redeemRequest.who == redeemer, "Not allowed redeemer");
        uint256 actualDelta = delta;
        if (isAddition) {
            redeemRequest.amount = redeemRequest.amount.add(delta);
        } else {
            if (redeemRequest.amount < delta) {
                actualDelta = redeemRequest.amount;
                redeemRequest.amount = 0;
            } else {
                redeemRequest.amount = redeemRequest.amount.sub(delta);
            }
        }
        emit RedeemRequestAlter(redeemer, isAddition, actualDelta);
    }

    /**
  * @dev Runs settlement process in steps
    @param steps Amount of steps to run
    @return The commissions collected in the executed steps
  */
    function runSettlement(uint256 steps)
        public
        onlyWhitelisted(msg.sender)
        isTime()
        returns (uint256)
    {
        executeGroup(SETTLEMENT_TASK, steps);

        return settlementInfo.finalCommissionAmount;
    }

    function initializeContracts() internal {
        docToken = DocToken(connector.docToken());
        bproxManager = MoCBProxManager(connector.bproxManager());
        mocState = MoCState(connector.mocState());
        mocExchange = MoCExchange(connector.mocExchange());
    }

    function initializeValues(address _governor, uint256 _blockSpan) internal {
        governor = IGovernor(_governor);
        blockSpan = _blockSpan;
        lastProcessedBlock = block.number;
        initializeTasks();
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
    function deleveragingStepCount() internal view returns (uint256) {
        return bproxManager.getActiveAddressesCount(BUCKET_X2);
    }

    /**
    @dev Returns the amount of steps for the Doc Redemption task
    which is the amount of redeem requests in the queue
  */
    function docRedemptionStepCount() internal view returns (uint256) {
        return redeemQueueLength;
    }

    /**
    @dev Freezes state for Settlement execution
  */
    function initializeSettlement() internal {
        settlementInfo.leverage = mocState.leverage(BUCKET_X2);
        settlementInfo.btcPrice = mocState.getBitcoinPrice();
        settlementInfo.btcxPrice = mocState.bucketBProTecPrice(BUCKET_X2);
        settlementInfo.startBlockNumber = block.number;

        settlementInfo.docRedeemCount = redeemQueueLength;
        settlementInfo.deleveragingCount = bproxManager.getActiveAddressesCount(
            BUCKET_X2
        );
        settlementInfo.finalCommissionAmount = 0;
        settlementInfo.partialCommissionAmount = 0;
        settlementInfo.startBlockNumber = block.number;

        emit SettlementStarted(
            settlementInfo.docRedeemCount,
            settlementInfo.deleveragingCount,
            settlementInfo.btcxPrice,
            settlementInfo.btcPrice
        );
    }

    /**
    @dev Execute final step of Settlement task group
  */
    function finishSettlement() internal {
        lastProcessedBlock = lastProcessedBlock.add(blockSpan);
        settlementInfo.finalCommissionAmount = settlementInfo
            .partialCommissionAmount;
        emit SettlementCompleted(settlementInfo.finalCommissionAmount);
    }

    /**
    @dev Execute final step of Deleveraging task
  */
    function finishDeleveraging() internal {
        emit SettlementDeleveraging(
            settlementInfo.leverage,
            settlementInfo.btcxPrice,
            settlementInfo.btcPrice,
            settlementInfo.startBlockNumber
        );

        bproxManager.emptyBucket(BUCKET_X2, BUCKET_C0);
    }

    /**
    @dev Execute final step of DocRedemption task
  */
    function finishDocRedemption() internal {
        emit SettlementRedeemStableToken(
            settlementInfo.docRedeemCount,
            settlementInfo.finalCommissionAmount,
            settlementInfo.btcPrice
        );

        clear();
    }

    /**
    @dev Individual Deleveraging step to be executed in partial execution
    uint256 parameter needed for PartialExecution
  */
    function deleveragingStep(uint256) internal {
        // We just pop the first element because the redemption always remove the address.
        address payable userAddress = bproxManager.getActiveAddresses(
            BUCKET_X2
        )[0];
        uint256 bproxBalance = bproxManager.bproxBalanceOf(
            BUCKET_X2,
            userAddress
        );

        // RBTC sending could only fail if the receiving address
        // executes code and reverts. If that happens, the user will lose
        // his Bprox and RBTCs will be kept in MoC.
        mocExchange.forceRedeemBProx(
            BUCKET_X2,
            userAddress,
            bproxBalance,
            settlementInfo.btcxPrice
        );
    }

    /**
    @dev Individual DocRedemption step to be executed in partial execution
    @param index Step number currently in execution
  */
    function docRedemptionStep(uint256 index) internal {
        (address payable redeemer, uint256 redeemAmount) = getRedeemRequestAt(
            index
        );
        uint256 userDocBalance = docToken.balanceOf(redeemer);
        uint256 amountToRedeem = Math.min(userDocBalance, redeemAmount);
        if (amountToRedeem > 0) {
            (bool result, uint256 btcCommissionSpent) = mocExchange
                .redeemDocWithPrice(
                redeemer,
                amountToRedeem,
                settlementInfo.btcPrice
            );
            // Redemption can fail if the receiving address is a contract
            if (result) {
                emit RedeemRequestProcessed(
                    redeemer,
                    btcCommissionSpent,
                    amountToRedeem
                );
                settlementInfo.partialCommissionAmount = settlementInfo
                    .partialCommissionAmount
                    .add(btcCommissionSpent);
            }
        }
        UserRedeemRequest storage userReedem = redeemMapping[redeemer];
        userReedem.activeRedeemer = false;
        redeemQueue[index].amount = 0;
    }

    /**
    @dev Create Task structures for Settlement execution
  */
    function fixTasksPointer() public {
        resetTaskPointers(
            DELEVERAGING_TASK,
            deleveragingStepCount,
            deleveragingStep,
            noFunction,
            finishDeleveraging
        );
        resetTaskPointers(
            DOC_REDEMPTION_TASK,
            docRedemptionStepCount,
            docRedemptionStep,
            noFunction,
            finishDocRedemption
        );
        resetTaskGroupPointers(
            SETTLEMENT_TASK,
            tasks,
            initializeSettlement,
            finishSettlement,
            true
        );
    }

    /**
    @dev Create Task structures for Settlement execution
  */
    function initializeTasks() internal {
        createTask(
            DELEVERAGING_TASK,
            deleveragingStepCount,
            deleveragingStep,
            noFunction,
            finishDeleveraging
        );
        createTask(
            DOC_REDEMPTION_TASK,
            docRedemptionStepCount,
            docRedemptionStep,
            noFunction,
            finishDocRedemption
        );

        bytes32[] memory tasks = new bytes32[](2);
        tasks[0] = DELEVERAGING_TASK;
        tasks[1] = DOC_REDEMPTION_TASK;

        createTaskGroup(
            SETTLEMENT_TASK,
            tasks,
            initializeSettlement,
            finishSettlement,
            true
        );
    }

    // Leave a gap betweeen inherited contracts variables in order to be
    // able to add more variables in them later
    uint256[50] private upgradeGap;
}
