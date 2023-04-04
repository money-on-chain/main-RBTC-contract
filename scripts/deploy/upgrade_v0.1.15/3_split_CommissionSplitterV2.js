/* eslint-disable no-console */
/* eslint-disable camelcase */

const { getConfig, getNetwork } = require('../helper');
const CommissionSplitterV2Abi = require('../../../build/contracts/CommissionSplitterV2.json');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const [owner] = await web3.eth.getAccounts();

    const commissionSplitterV2Address = config.proxyAddresses.CommissionSplitterV2;

    console.log('Executing split ....');

    const CommissionSplitterV2Deployed = await new web3.eth.Contract(
      CommissionSplitterV2Abi.abi,
      commissionSplitterV2Address
    );

    await CommissionSplitterV2Deployed.methods
      .split()
      .send({ from: owner, gas: 1e6 })
      .on('transactionHash', hash => console.log('TxHash:', hash))
      .on('confirmation', confirmationNumber => console.log('Tx confirmation:', confirmationNumber))
      .on('receipt', receipt => console.log('Tx receipt:', receipt))
      .on('error', console.error);

    console.log('Executing split Done!!');
  } catch (error) {
    callback(error);
  }

  callback();
};
