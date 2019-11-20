const BProToken = artifacts.require('./token/BProToken.sol');

module.exports = async deployer => {
  return deployer.then(() => deployer.deploy(BProToken));
};
