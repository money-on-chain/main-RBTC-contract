/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MaxGasPriceChanger = artifacts.require('./changers/MaxGasPriceChanger.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log('MaxGasPriceChanger Deploy');
    const maxGasPriceChanger = await MaxGasPriceChanger.new(
      config.governanceImplementationAddresses.UpgradeDelegator,
      config.mocProxyAddresses.MoC,
      config.mocImplementationAddresses.MoC,
      config.rocProxyAddresses.MoC,
      config.rocImplementationAddresses.MoC,
      config.governanceImplementationAddresses.Stopper,
      config.valuesToAssign.maxGasPrice
    );
    console.log('MaxGasPriceChanger address: ', maxGasPriceChanger.address);

    // Save changer address to config file
    config.changerAddresses.MaxGasPriceChanger = maxGasPriceChanger.address;
    saveConfig(config, configPath);

    // if (shouldExecuteChanges(network)) {
    //   // Execute changes in contracts
    //   console.log('Execute change - Changer');
    //   const governor = await Governor.at(config.mocImplementationAddresses.Governor);
    //   await governor.executeChange(maxGasPriceChanger.address);
    // } else {
    //   console.log('Executing test governor execute change');
    //   const governor = await Governor.at(config.mocImplementationAddresses.Governor);
    //   await governor.contract.methods
    //     .executeChange(config.changerAddresses.Changer)
    //     .call({ from: config.governorOwnerAddress });
    // }
  } catch (error) {
    callback(error);
  }

  callback();
};
