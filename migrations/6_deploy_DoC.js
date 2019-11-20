const DocToken = artifacts.require('./token/DocToken.sol');

module.exports = async deployer => {
  return deployer.then(() => deployer.deploy(DocToken));
};
