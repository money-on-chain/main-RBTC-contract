/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const CommissionSplitterFixOutputRevAuc = artifacts.require('./changers/proposal_commission_splitter_revauc_fix/CommissionSplitterFixOutputRevAuc.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log('CommissionSplitterFixOutputRevAuc Deploy');
    const commissionSplitterFixOutputRevAuc = await CommissionSplitterFixOutputRevAuc.new(
      config.CommissionSplitterFixOutputRevAuc.commissionSplitterV2,
      config.CommissionSplitterFixOutputRevAuc.commissionSplitterV3,
      config.CommissionSplitterFixOutputRevAuc.revAucBTC2MOC,
      config.CommissionSplitterFixOutputRevAuc.revAucMOC2BTC
    );
    console.log('CommissionSplitterFixOutputRevAuc address: ', commissionSplitterFixOutputRevAuc.address);

    // Save changer address to config file
    config.CommissionSplitterFixOutputRevAuc.changer = commissionSplitterFixOutputRevAuc.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - Changer');
      const governor = await Governor.at(config.Governor);
      await governor.executeChange(commissionSplitterFixOutputRevAuc.address);
    } else {
      console.log('Executing test governor execute change');
      const governor = await Governor.at(config.Governor);
      await governor.contract.methods
        .executeChange(config.commissionSplitterFixOutputRevAuc.changer)
        .call({ from: config.governorOwnerAddress });
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
