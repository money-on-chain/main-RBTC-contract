/* eslint-disable no-console */
const MoCLib = artifacts.require('./MoCHelperLib.sol');

module.exports = async deployer =>
  // Workaround to get the link working on tests
  deployer.then(async () => {
    const deployPromise = deployer.deploy(MoCLib);
    console.log('Deploying MoCLib');
    return deployPromise;
  });
