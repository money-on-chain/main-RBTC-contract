pragma solidity ^0.5.8;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";


contract PartialExecutionData {
    enum ExecutionState {Ready, Running, Finished}

    struct TaskGroup {
        bytes32 id;
        ExecutionState state;
        bytes32[] subTasks;
        function() internal onStart;
        function() internal onFinish;
        bool autoRestart;
    }

    struct Task {
        bytes32 id;
        function() internal returns (uint256)  getStepCount;
        function(uint256) internal stepFunction;
        function() internal onStart;
        function() internal onFinish;
        uint256 currentStep;
        uint256 stepCount;
        ExecutionState state;
    }
}


/**
  @dev Brings basic data structures and functions for partial execution.
  The main data structures are:
    Task: Represents a function that needs to be executed by steps.
    TaskGroup: Represents a function that contains several functions that needs to be executed by steps.
  Tasks and Tasks groups can be executed specifying the amount of steps to run.
*/
contract PartialExecution_v019 is PartialExecutionData {
    using SafeMath for uint256;
    using Math for uint256;
    mapping(bytes32 => Task) internal tasks;
    mapping(bytes32 => TaskGroup) internal taskGroups;

    /**
     @dev Auxiliar function for tasks with no onFinish function
   */
    function noFunction() internal {}


    /**
     @dev Reset pointers a task group
     @param _groupId Id of the task group
     @param _subtasks Tasks to execute when executing the task group
     @param _onFinish Function to execute when all tasks of the group are completed
   */
    function resetTaskGroupPointers(
        bytes32 _groupId,
        bytes32[] memory _subtasks,
        function() _onStart,
        function() _onFinish,
        bool _autoRestart
    ) internal {
        taskGroups[_groupId].id = _groupId;
        taskGroups[_groupId].subTasks = _subtasks;
        taskGroups[_groupId].onStart = _onStart;
        taskGroups[_groupId].onFinish = _onFinish;
        taskGroups[_groupId].autoRestart = _autoRestart;

    }

    /**
     @dev Creates a task
     @param taskId Id of the task
     @param _getStepCount Function executed before starting the task
     Should return the step count of the execution
     @param _stepFunction Function to execute at each step
     @param _onStart Function to execute before task execution
     @param _onFinish Function to execute when all steps are completed
   */
    function resetTaskPointers(
        bytes32 taskId,
        function() internal returns (uint256) _getStepCount,
        function(uint256) internal _stepFunction,
        function() internal _onStart,
        function() internal _onFinish
    ) internal {
        tasks[taskId].id = taskId;
        tasks[taskId].getStepCount = _getStepCount;
        tasks[taskId].stepFunction = _stepFunction;
        tasks[taskId].onStart = _onStart;
        tasks[taskId].onFinish = _onFinish;
    }

  

    /**
     @dev Creates a task group
     @param _groupId Id of the task group
     @param _subtasks Tasks to execute when executing the task group
     @param _onFinish Function to execute when all tasks of the group are completed
   */
    function createTaskGroup(
        bytes32 _groupId,
        bytes32[] memory _subtasks,
        function() _onStart,
        function() _onFinish,
        bool _autoRestart
    ) internal {
        taskGroups[_groupId].id = _groupId;
        taskGroups[_groupId].subTasks = _subtasks;
        taskGroups[_groupId].onStart = _onStart;
        taskGroups[_groupId].onFinish = _onFinish;
        taskGroups[_groupId].state = ExecutionState.Ready;
        taskGroups[_groupId].autoRestart = _autoRestart;
    }

    /**
     @dev Creates a task
     @param taskId Id of the task
     @param _getStepCount Function executed before starting the task
     Should return the step count of the execution
     @param _stepFunction Function to execute at each step
     @param _onStart Function to execute before task execution
     @param _onFinish Function to execute when all steps are completed
   */
    function createTask(
        bytes32 taskId,
        function() internal returns (uint256)  _getStepCount,
        function(uint256) internal _stepFunction,
        function() internal _onStart,
        function() internal _onFinish
    ) internal {
        tasks[taskId].id = taskId;
        tasks[taskId].getStepCount = _getStepCount;
        tasks[taskId].stepFunction = _stepFunction;
        tasks[taskId].onStart = _onStart;
        tasks[taskId].onFinish = _onFinish;
        tasks[taskId].state = ExecutionState.Ready;
    }

    /**
     @dev Executes all tasks of the group in order using the step count passed as parameter
     @param groupId Id of the task group
     @param stepCount Step count to execute
   */
    function executeGroup(bytes32 groupId, uint256 stepCount) internal {
        TaskGroup storage group = taskGroups[groupId];

        if (group.state == ExecutionState.Ready) {
            group.onStart();
            group.state = ExecutionState.Running;
        }

        uint256 leftSteps = stepCount;

        for (uint256 i = 0; i < group.subTasks.length && leftSteps > 0; i++) {
            uint256 consumed = executeTask(group.subTasks[i], leftSteps);
            leftSteps = leftSteps.sub(consumed);
        }

        if (groupFinished(groupId)) {
            group.state = ExecutionState.Finished;
            group.onFinish();
            if (group.autoRestart) {
                resetGroup(groupId);
            }
        }
    }

    /**
     @dev Creates a task
     @param taskId Id of the task
     @param steps Step count to execute
     @return The amount of steps consumed in the execution
   */
    function executeTask(bytes32 taskId, uint256 steps)
        internal
        returns (uint256)
    {
        Task storage task = tasks[taskId];
        uint256 initialStep = task.currentStep;

        if (task.state == ExecutionState.Finished) {
            // No execution
            return 0;
        }
        if (task.state == ExecutionState.Ready) {
            task.stepCount = task.getStepCount();
            task.onStart();
            task.state = ExecutionState.Running;
        }
        if (task.state == ExecutionState.Running) {
            uint256 endStep = Math.min(
                task.currentStep.add(steps),
                task.stepCount
            );

            for (
                task.currentStep;
                task.currentStep < endStep;
                task.currentStep++
            ) {
                task.stepFunction(task.currentStep);
            }

            if (task.currentStep == task.stepCount) {
                task.state = ExecutionState.Finished;
                task.onFinish();
            }
        }

        return task.currentStep.sub(initialStep);
    }

    /**
     @dev Put task in Ready to run state and reset currentStep value
     @param taskId Id of the task
   */
    function resetTask(bytes32 taskId) internal {
        tasks[taskId].state = ExecutionState.Ready;
        tasks[taskId].currentStep = 0;
    }

    /**
    @dev Reset all tasks in a group. Used at the completion of a task group execution
    @param groupId Id of the task group
  */
    function resetTasks(bytes32 groupId) internal {
        TaskGroup storage group = taskGroups[groupId];

        for (uint256 i = 0; i < group.subTasks.length; i++) {
            resetTask(group.subTasks[i]);
        }
    }

    /**
    @dev Set if a Group should be automatically set to Ready state
    after Finnished State is reached
    @param groupId Id of the task group
  */
    function setAutoRestart(bytes32 groupId, bool _autoRestart) internal {
        taskGroups[groupId].autoRestart = _autoRestart;
    }

    /**
    @dev Set Group in Ready state. Reset all sub-task.
    @param groupId Id of the task group
  */
    function resetGroup(bytes32 groupId) internal {
        TaskGroup storage group = taskGroups[groupId];
        group.state = ExecutionState.Ready;

        resetTasks(groupId);
    }

    /**
     @dev Returns true if the last task of the group was completed
     @param groupId Id of the task group
     @return boolean
   */
    function groupFinished(bytes32 groupId) internal view returns (bool) {
        TaskGroup storage group = taskGroups[groupId];
        bytes32 taskId = group.subTasks[group.subTasks.length.sub(1)];
        Task storage lastTask = tasks[taskId];

        return lastTask.state == ExecutionState.Finished;
    }

    /**
     @dev Returns true if the group is currently un Running state
     @param groupId Id of the task group
     @return boolean
   */
    function isGroupRunning(bytes32 groupId) internal view returns (bool) {
        return taskGroups[groupId].state == ExecutionState.Running;
    }

    /**
     @dev Returns true if the group is currently in Ready state
     @param groupId Id of the task group
     @return boolean
   */
    function isGroupReady(bytes32 groupId) internal view returns (bool) {
        return taskGroups[groupId].state == ExecutionState.Ready;
    }

    /**
     @dev Returns true if the task is currently un Running state
     @param taskId Id of the task
     @return boolean
   */
    function isTaskRunning(bytes32 taskId) internal view returns (bool) {
        return tasks[taskId].state == ExecutionState.Running;
    }

    // Leave a gap betweeen inherited contracts variables in order to be
    // able to add more variables in them later
    uint256[50] private upgradeGap;
}
