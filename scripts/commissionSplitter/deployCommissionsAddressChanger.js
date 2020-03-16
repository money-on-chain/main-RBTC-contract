const { deployContract, getConfig } = require('./changerHelper');
const changerAbi = require('../../build/contracts/CommissionsAddressChanger.json');

/**
 * Script for changing CommissionsAddress in MoCInrate
 */
const input = {
  network: 'qaTestnet',
  commissionsAddress: '0xAA98297F2ed80B44883AAC572386B710a71af594'
};

const execute = async () => {
  const config = getConfig(input.network);
  deployContract(changerAbi, input.network, [config.mocInrate, input.commissionsAddress]);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
