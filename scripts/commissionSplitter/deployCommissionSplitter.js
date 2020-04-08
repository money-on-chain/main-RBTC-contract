/* eslint-disable import/no-unresolved */
const CommissionSplitter = require('../../build/contracts/CommissionSplitter.json');
const { deployContract, getConfig, deployProxyContract } = require('./changerHelper');

/**
 * Script for deploying a CommissionSplitter contract
 */
const input = {
  network: 'qaTestnet',
  commissionAddress: '0xd51128F302755666c42e3920d72FF2FE632856a9',
  mocProportion: '500000000000000000'
};

// mocAddress: "0x9A9ad90344B854b03E82c0bdddf6BF1aB4BF37A1",
// commissionsAddress: "0xd51128F302755666c42e3920d72FF2FE632856a9",
// mocProportion: "500000000000000000",
// governor: "0xD63C0441b9A6c019917e9773992F7B5428542cbb"

const execute = async () => {
  const { network, mocProportion, commissionAddress } = input;
  return deployProxyContract(
    {
      network,
      contractAlias: 'CommissionSplitter',
      newAdmin: '0x93176E10a2962061D92617a06abE3F5850E18CD6'
    },
    {
      mocAddress: '0x9A9ad90344B854b03E82c0bdddf6BF1aB4BF37A1',
      commissionAddress,
      mocProportion,
      governor: '0xD63C0441b9A6c019917e9773992F7B5428542cbb'
    }
  );
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
