const SetCommissionMocProportion = require('../../build/contracts/SetCommissionMocProportionChanger.json');
const { deployContract, getConfig } = require('./changerHelper');

/**
 * Script for setting the proportion of the commissions that
 * will be injected back into MoC's reserves
 */

const input = {
  network: 'qaTestnet',
  mocProportion: '500000000000000000' // 0.5
};

const execute = async () => {
  const config = getConfig(input.network);
  return deployContract(SetCommissionMocProportion, input.network, [
    config.commissionSplitter,
    input.mocProportion
  ]);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
