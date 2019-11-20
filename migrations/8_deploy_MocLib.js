const MoCLib = artifacts.require('./MoCHelperLib.sol');

module.exports = async deployer => {
  return deployer.then(() => deployer.deploy(MoCLib));
};
