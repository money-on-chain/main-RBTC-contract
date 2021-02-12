const MoCPriceProviderMock = artifacts.require('./mocks/MoCPriceProviderMock.sol');

module.exports = async (deployer) => {
  await deployer.deploy(MoCPriceProviderMock, '200000000000000000');
}