const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCStateChanger = artifacts.require('MoCStateChanger.sol');
const MoCState = artifacts.require('MoCState.sol');
const MoCVendors = artifacts.require('MoCVendors.sol');
const { toContract } = require('../utils/numberHelper.js');
const utils = require('./utils');
const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  const { getContractAddresses } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );

  // Get deployed contract from artifact
  const mocState = await MoCState.deployed();
  // If script fails, use const mocState = await MoCState.at('<address>');

  const btcPriceProviderAddress = '0xe19df38ac824e2189ac3b67be1aefba9ee27d002'; // mock
  const peg = 1;  // relation between DOC and dollar. By default it is 1
  const utpdu = toContract(2 * 10 ** 18);
  const maxDiscountRate = toContract(0.5 * 10 ** 18);
  const dayBlockSpan = 2880;
  const liq = toContract(1.04 * 10 ** 18);
  const smoothingFactor = toContract(0.01653 * 10 ** 18);
  const emaBlockSpan = 2880;
  const maxMintBPro = toContract(20 * 10 ** 18);
  const mocPriceProviderAddress = '0xc5a3d6cbe0eef0cf20cf7ca5540deaac19b2129e'; // mock
  const mocTokenAddress = '0x1dc4bec7ce1ca27ba16f419c514b62c88b9cb567';
  const mocVendors = await MoCVendors.deployed();

  const mocStateChanger = await MoCStateChanger.new(
    mocState.address,
    btcPriceProviderAddress,
    peg,
    utpdu,
    maxDiscountRate,
    dayBlockSpan,
    liq,
    smoothingFactor,
    emaBlockSpan,
    maxMintBPro,
    mocPriceProviderAddress,
    mocTokenAddress,
    mocVendors.address,
    { from: owner }
  );

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');

  // Execute changes
  await governor.executeChange(mocStateChanger.address);

  console.log('------------CONTRACTS DEPLOYED-----------------');
  console.log(`${JSON.stringify(await getContractAddresses())}`);
};
