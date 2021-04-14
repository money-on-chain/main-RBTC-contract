pragma solidity 0.5.8;

import "zos-lib/contracts/Initializable.sol";

contract NewTask is Initializable {

    struct TaskGroup {
        bytes32 id;
        function() internal onStart;
        function() internal onFinish;
    }
    event OldEvent(string);
    event NewEvent(string);
    event FinishEvent(string);
    event OtherEvent(string);

    bytes32 public constant DOC_REDEMPTION_TASK = keccak256("DocRedemption");
    bytes32 public constant DELEVERAGING_TASK = keccak256("Deleveraging");
    bytes32 public constant SETTLEMENT_TASK = keccak256("Settlement");
    TaskGroup internal theTaskGroup;

    function initialize() internal initializer {
        initializeTasks();
    }

    function initializeTasks() internal {
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

    function otherFunction() internal {
        //Add this to see if the pointer is afected by new lines
        emit OtherEvent("unrelevant function");
    }

    function initializeSettlement() internal {
        //Add this to see if the pointer is afected by new lines
        uint x = 0;
        if (x == 0) {
            emit NewEvent("new event initialize settlement");
        }
    }

    function finishSettlement() internal {
        emit FinishEvent("old event finish settlement");
    }

    function getTaskId() public view returns(bytes32) {
        return theTaskGroup.id;
    }
}