const { getWeb3, getConfig } = require('./changerHelper');
const GovernorAbi = require('../../build/contracts/Governor.json');

const input = {
  network: 'qaTestnet',
  changerAddress: '0xe9bE4c9E36E24134b6BBcbC0F1691120A116b0C2 '
};

const execute = async () => {
  const config = getConfig(input.network);
  const web3 = getWeb3(input.network);
  const [owner] = await web3.eth.getAccounts();
  const Governor = await new web3.eth.Contract(GovernorAbi.abi, config.governor);
  console.log(
    `Sending Governor (${config.governor}) executeChange with changer: ${input.changerAddress},
    , owner: ${owner}} on ${input.network}`
  );
  return Governor.methods
    .executeChange(input.changerAddress)
    .send({ from: owner, gas: 1e6 })
    .on('transactionHash', hash => console.log('TxHash:', hash))
    .on('confirmation', confirmationNumber => console.log('Tx confirmation:', confirmationNumber))
    .on('receipt', receipt => console.log('Tx receipt:', receipt))
    .on('error', console.error);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
