/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const BatchChanger = artifacts.require('./changers/BatchChanger.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = 'rskMocMainnet2';
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const governorAddress = config.implementationAddresses.Governor;
    const { governorOwnerAddress } = config;
    console.log('Governor Address', governorAddress);
    console.log('Governor Owner', governorOwnerAddress);
    const governor = await Governor.at(governorAddress);

    console.log('BatchChanger Deploy');
    const batchChanger = await BatchChanger.at('0xb98200A3b89dD692E6F28AC7c5b8EBD35d1F7B1C');
    console.log('MoCSettlement');
    const moCSettlement = await MoCSettlement.at(config.proxyAddresses.MoCSettlement);

    await moCSettlement.contract.methods.fixTasksPointer().call();
    console.log('Call successfull to FixTaskPointer');

    await governor.contract.methods
      .executeChange(batchChanger.address)
      .call({ from: governorOwnerAddress, gasLimit: 3500000 });

    console.log('BatchChanger address: ', batchChanger.address);
  } catch (error) {
    callback(error);
  }

  callback();
};
