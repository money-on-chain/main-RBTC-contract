const MoCToken = artifacts.require('./token/MoCToken.sol');

module.exports = async deployer => {
  await deployer.deploy(MoCToken);
};