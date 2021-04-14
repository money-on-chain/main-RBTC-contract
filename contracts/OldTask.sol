pragma solidity 0.5.8;

import "zos-lib/contracts/Initializable.sol";

contract OldTask is Initializable {

    struct TaskGroup {
        bytes32 id;
        function() internal onStart;
        function() internal onFinish;
    }
    event OldEvent(string);
    event FinishEvent(string);

    bytes32 public constant DOC_REDEMPTION_TASK = keccak256("DocRedemption");
    bytes32 public constant DELEVERAGING_TASK = keccak256("Deleveraging");
    bytes32 public constant SETTLEMENT_TASK = keccak256("Settlement");
    TaskGroup internal theTaskGroup;

    function initialize() internal initializer {
        initializeTasks();
    }

    function initializeTasks() public {
        theTaskGroup.id = SETTLEMENT_TASK;
        theTaskGroup.onStart = initializeSettlement;
        theTaskGroup.onStart = finishSettlement;
    }

    function runSettlement() public
    {
        theTaskGroup.onStart();
    }

    function fixTasksPointer() public {
        initializeTasks();
    }
    function initializeSettlement() internal {
        emit OldEvent("old event  initialize settlement");
    }

    function finishSettlement() internal {
        emit FinishEvent("old event finish settlement");
    }

    function getTaskId() public view returns(bytes32) {
        return theTaskGroup.id;
    }
}