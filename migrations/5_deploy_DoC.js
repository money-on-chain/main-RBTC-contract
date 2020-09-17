const DocToken = artifacts.require('./token/DocToken.sol');

module.exports = async deployer => {
  await deployer.deploy(DocToken);
};
