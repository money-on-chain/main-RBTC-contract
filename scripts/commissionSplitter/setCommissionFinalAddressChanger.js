const SetCommissionFinalAddressChanger = require('../../build/contracts/SetCommissionFinalAddressChanger.json');
const { deployContract, getConfig } = require('./changerHelper');

/**
 * Script for setting address that will receive
 * the commissions after the splitting in CommissionSplitter
 */
const input = {
  network: 'qaTestnet',
  finalCommissionAddress: ''
};

const execute = async () => {
  const config = getConfig(input.network);
  return deployContract(SetCommissionFinalAddressChanger, input.network, [
    config.commissionSplitter,
    input.finalCommissionAddress
  ]);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
