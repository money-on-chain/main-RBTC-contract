const MoCLib = artifacts.require('./MoCHelperLib.sol');

module.exports = async deployer => {
  await deployer.deploy(MoCLib);
};
