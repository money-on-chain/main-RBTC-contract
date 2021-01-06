const utils = require('./utils');

const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCSettlementMock = artifacts.require('./mocks/MoCSettlementMock.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoCVendors = artifacts.require('./MoCVendors.sol');

const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { deployUpgradable } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );
  const index = 11;
  if (utils.isDevelopment(currentNetwork))
    await deployUpgradable(MoCSettlementMock, MoCStateMock, index);
  else await deployUpgradable(MoCSettlement, MoCState, index);

  // Proxy addresses
  const mocConnectorAddress = '0x143d20f6688b64D0762692A6eC90E1E8650D4e07';
  const governorAddress = '0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e';

  //const mocVendors = await MoCVendors.at('0x748C0ccbDFeb85DF79fE978e9BADe1c4aaE8c757');
  const addresses = await getContractAddresses();
  const mocVendors = await MoCVendors.at(addresses.mocVendors);

  // Initialize contract
  await mocVendors.initialize(
    mocConnectorAddress,
    governorAddress
  );
  console.log('Vendors Initialized');
};
