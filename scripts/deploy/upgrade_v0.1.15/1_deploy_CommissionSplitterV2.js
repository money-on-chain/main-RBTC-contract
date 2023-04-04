/* eslint-disable no-console */
/* eslint-disable camelcase */

const { getConfig, getNetwork, saveConfig, deployProxyContract, getProxies } = require('../helper');
const CommissionSplitterV2Abi = require('../../../build/contracts/CommissionSplitterV2.json');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const configPath = `${__dirname}/deployConfig-${network}.json`;
    const config = getConfig(network, configPath);
    const [owner] = await web3.eth.getAccounts();

    const {
      outputAddress_1,
      outputAddress_2,
      outputAddress_3,
      outputProportion_1,
      outputProportion_2,
      outputTokenGovernAddress_1,
      outputTokenGovernAddress_2,
      outputProportionTokenGovern_1,
      tokenGovern
    } = config.CommissionSplitterV2;

    const proxyAdmin = config.implementationAddresses.ProxyAdmin;
    const governor = config.implementationAddresses.Governor;

    console.log('Deploying Commission Splitter v2 ...');
    const proxyContract = await deployProxyContract(
      {
        network,
        contractAlias: 'CommissionSplitterV2',
        newAdmin: proxyAdmin,
        owner
      },
      {
        governor,
        outputAddress_1,
        outputAddress_2,
        outputAddress_3,
        outputProportion_1,
        outputProportion_2,
        outputTokenGovernAddress_1,
        outputTokenGovernAddress_2,
        outputProportionTokenGovern_1,
        tokenGovern
      }
    );

    const proxies = getProxies(network);
    console.log('Initializing contract deployed...');
    const commissionSplitterV2Address =
      proxies.proxies['money-on-chain/CommissionSplitterV2'][0].address;

    const CommissionSplitterV2Deployed = await new web3.eth.Contract(
      CommissionSplitterV2Abi.abi,
      commissionSplitterV2Address
    );

    await CommissionSplitterV2Deployed.methods.initialize(
        governor,
        outputAddress_1,
        outputAddress_2,
        outputAddress_3,
        outputProportion_1,
        outputProportion_2,
        outputTokenGovernAddress_1,
        outputTokenGovernAddress_2,
        outputProportionTokenGovern_1,
        tokenGovern
      )
      .send({ from: owner, gas: 1e6 })
      .on('transactionHash', hash => console.log('TxHash:', hash))
      .on('confirmation', confirmationNumber => console.log('Tx confirmation:', confirmationNumber))
      .on('receipt', receipt => console.log('Tx receipt:', receipt))
      .on('error', console.error);

    console.log('Initializing contract deployed Done!!');

    console.log(
      'Commission Splitter V2 implementation address: ',
      proxies.proxies['money-on-chain/CommissionSplitterV2'][0].implementation
    );
    console.log(
      'Commission Splitter V2 proxy address: ',
      proxies.proxies['money-on-chain/CommissionSplitterV2'][0].address
    );

    config.implementationAddresses.CommissionSplitterV2 =
      proxies.proxies['money-on-chain/CommissionSplitterV2'][0].implementation;
    config.proxyAddresses.CommissionSplitterV2 =
      proxies.proxies['money-on-chain/CommissionSplitterV2'][0].address;
    saveConfig(config, configPath);

  } catch (error) {
    callback(error);
  }

  callback();
};
