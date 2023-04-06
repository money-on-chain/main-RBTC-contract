/* eslint-disable no-console */
/* eslint-disable camelcase */

const { getConfig, getNetwork, saveConfig, deployProxyContract, getProxies } = require('../helper');
const CommissionSplitterV3Abi = require('../../../build/contracts/CommissionSplitterV3.json');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const [owner] = await web3.eth.getAccounts();

    const { outputAddress_1, outputAddress_2, outputProportion_1 } = config.CommissionSplitterV3;

    const proxyAdmin = config.implementationAddresses.ProxyAdmin;
    const governor = config.implementationAddresses.Governor;

    console.log('Deploying Commission Splitter v3 ...');
    const proxyContract = await deployProxyContract(
      {
        network,
        contractAlias: 'CommissionSplitterV3',
        newAdmin: proxyAdmin,
        owner
      },
      {
        governor,
        outputAddress_1,
        outputAddress_2,
        outputProportion_1
      }
    );

    const proxies = getProxies(network);
    console.log('Initializing contract deployed...');
    const commissionSplitterV3Address =
      proxies.proxies['money-on-chain/CommissionSplitterV3'][0].address;

    const CommissionSplitterV3Deployed = await new web3.eth.Contract(
      CommissionSplitterV3Abi.abi,
      commissionSplitterV3Address
    );

    await CommissionSplitterV3Deployed.methods
      .initialize(governor, outputAddress_1, outputAddress_2, outputProportion_1)
      .send({ from: owner, gas: 1e6 })
      .on('transactionHash', hash => console.log('TxHash:', hash))
      .on('confirmation', confirmationNumber => console.log('Tx confirmation:', confirmationNumber))
      .on('receipt', receipt => console.log('Tx receipt:', receipt))
      .on('error', console.error);

    console.log('Initializing contract deployed Done!!');

    console.log(
      'Commission Splitter V3 implementation address: ',
      proxies.proxies['money-on-chain/CommissionSplitterV3'][0].implementation
    );
    console.log(
      'Commission Splitter V3 proxy address: ',
      proxies.proxies['money-on-chain/CommissionSplitterV3'][0].address
    );

    config.implementationAddresses.CommissionSplitterV3 =
      proxies.proxies['money-on-chain/CommissionSplitterV3'][0].implementation;
    config.proxyAddresses.CommissionSplitterV3 =
      proxies.proxies['money-on-chain/CommissionSplitterV3'][0].address;
    saveConfig(config, configPath);
  } catch (error) {
    callback(error);
  }

  callback();
};
