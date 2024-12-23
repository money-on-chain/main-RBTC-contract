/* eslint-disable no-console */
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const FlowChangeProposal = artifacts.require('./changers/FlowChangeProposal.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('../helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);

    console.log('FlowChangeProposal Deploy');
    const flowChangeProposal = await FlowChangeProposal.new(
      config.FlowChangeProposal.mocInrate,
      config.FlowChangeProposal.mocState,
      config.FlowChangeProposal.mocSettlement,
      config.CommissionSplitterV2.proxy,
      config.CommissionSplitterV3.proxy,
      config.FlowChangeProposal.mocProviderAddress,
      config.FlowChangeProposal.blockSpan,
      config.FlowChangeProposal.blockSpanBitProInterest,
      config.FlowChangeProposal.blockSpanSettlement,
      config.FlowChangeProposal.blockSpanEMA
    );
    console.log('FlowChangeProposal address: ', flowChangeProposal.address);

    // Save changer address to config file
    config.FlowChangeProposal.changer = flowChangeProposal.address;
    saveConfig(config, configPath);

    if (shouldExecuteChanges(network)) {
      // Execute changes in contracts
      console.log('Execute change - Changer');
      const governor = await Governor.at(config.Governor);
      await governor.executeChange(flowChangeProposal.address);
    } else {
      console.log('Executing test governor execute change');
      const governor = await Governor.at(config.Governor);
      await governor.contract.methods
        .executeChange(config.FlowChangeProposal.changer)
        .call({ from: config.governorOwnerAddress });
    }
  } catch (error) {
    callback(error);
  }

  callback();
};
