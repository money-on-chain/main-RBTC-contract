const BProToken = artifacts.require('./token/BProToken.sol');

module.exports = async deployer => {
  await deployer.deploy(BProToken);
};
