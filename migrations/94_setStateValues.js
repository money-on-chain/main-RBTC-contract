const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCStateChanger = artifacts.require('MocStateChanger.sol');
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

  // Contracts proxy address
  const mocStateAddress = '0x56b4A2ebcDA50a014F9a5f3D050C49B92badB81d';

  const btcPriceProviderAddress = '0xE19Df38aC824E2189aC3b67bE1AefbA9eE27D002'; // mock
  const peg = 1;  // relation between DOC and dollar. By default it is 1
  const utpdu = toContract(2 * 10 ** 18);
  const maxDiscountRate = toContract(0.5 * 10 ** 18);
  const dayBlockSpan = 2880;
  const liq = toContract(1.04 * 10 ** 18);
  const smoothingFactor = toContract(0.01653 * 10 ** 18);
  const emaBlockSpan = 2880;
  const maxMintBPro = toContract(20 * 10 ** 18);
  const mocPriceProviderAddress = '0xEeae0B52Ac1F0D7D139898997b8367Dd67E3527c'; // mock
  const mocTokenAddress = '0x1dc4Bec7ce1ca27bA16F419c514b62c88B9Cb567';
  const mocVendorsAddress = '0x748C0ccbDFeb85DF79fE978e9BADe1c4aaE8c757';
  const liquidationEnabled = false;
  const _protected = toContract(1.5 * 10 ** 18);

  const mocStateChanger = await MoCStateChanger.new(
    mocStateAddress,
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
    mocVendorsAddress,
    liquidationEnabled,
    _protected,
    { from: owner }
  );

  //const mocStateChanger = await MoCStateChanger.at('0x7d8c1a7eedFf6Be544eE172336aDE78e91B369aC');

  console.log("MoCStateChanger instanced");
  console.log("MoCStateChanger address: ", mocStateChanger.address);

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');
  //console.log("governor: ", governor);

  // Execute changes
  console.log("Executing changes");
  await governor.executeChange(mocStateChanger.address);
  //console.log("estimateGas: ", await governor.contract.methods.executeChange(mocStateChanger.address).estimateGas());
  //console.log(await governor.contract.methods.executeChange(mocStateChanger.address).call({from: owner}));

  //console.log('------------CONTRACTS DEPLOYED-----------------');
  //console.log(`${JSON.stringify(await getContractAddresses())}`);
};
