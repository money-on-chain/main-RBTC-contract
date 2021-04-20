const NewTask = artifacts.require('./contracts/NewTask.sol');
const OldTask = artifacts.require('./contracts/OldTask.sol');
const AdminUpgradeabilityProxy = artifacts.require(
  'zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol'
);
const ProxyAdmin = artifacts.require(
    'zos-lib/contracts/upgradeability/ProxyAdmin.sol'
  );

contract('Test solidity function pointers', function([owner]) {
  it('Remains pointer after upgrade', async function() {
    const newTask = await NewTask.new();
    const oldTask = await OldTask.new();
    const proxyAdmin = await ProxyAdmin.new(owner);
    console.log('oldTask', oldTask.address)
    const proxy = await AdminUpgradeabilityProxy.new(oldTask.address, proxyAdmin.address, '0x');
    console.log('after proxy', proxy.address)
    const oldTaskContract = await OldTask.at(proxy.address);
    console.log('getTaskId')
    let taskId = await oldTaskContract.getTaskId();
    console.log('taskId', taskId);
    console.log('initializeTasks')
    await oldTaskContract.initializeTasks();
    console.log('after initializeTasks')
    taskId = await oldTaskContract.getTaskId();
    console.log('taskId', taskId);
    console.log('runSettlement')
    let result = await oldTaskContract.runSettlement();
    console.log('result logs', result.logs);
    await proxyAdmin.upgrade(proxy.address, newTask.address);
    console.log('upgrade', newTask.address);
    const newTaskContract = await NewTask.at(proxy.address);
    console.log('after upgrade')
    taskId = await newTaskContract.getTaskId();
    console.log('taskId', taskId);
    // result = await newTaskContract.fixTasksPointer();
    // console.log('fixed pointers');
    result = await newTaskContract.runSettlement();
    console.log('newTaskContract logs', result.logs);
  });
});
