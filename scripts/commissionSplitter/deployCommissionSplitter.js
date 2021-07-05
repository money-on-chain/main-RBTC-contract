/* eslint-disable import/no-unresolved */
const CommissionSplitter = require('../../build/contracts/CommissionSplitter.json');
const { deployContract, getConfig, deployProxyContract } = require('./changerHelper');

/**
 * Script for deploying a CommissionSplitter contract
 */
const input = {
  network: 'rskMocMainnet2'
};

const execute = async () => {
  const config = getConfig(input.network);
  const { network } = input;
  const {
    mocProportion,
    commissionAddress,
    proxyAdmin,
    moc,
    governor,
    mocToken,
    mocTokenCommissionAddress
  } = config;

  return deployProxyContract(
    {
      network,
      contractAlias: 'CommissionSplitter',
      newAdmin: proxyAdmin
    },
    {
      mocAddress: moc,
      commissionAddress,
      mocProportion,
      governor,
      mocToken,
      mocTokenCommissionAddress
    }
  );
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
