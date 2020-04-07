const Web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');
const abiDecoder = require('abi-decoder');
const _ = require('lodash');
const jsonfile = require('jsonfile');
const { scripts, ConfigVariablesInitializer } = require('zos');
const truffleConfig = require('../../truffle');
const config = require('./script-config.json');

const { add, push, create, setAdmin } = scripts;

const getDefaultProvider = network =>
  truffleConfig.networks[network].provider || truffleConfig.networks[network].endpoint;
const getNetworkHost = network => truffleConfig.networks[network].host;

const getWeb3 = (network, options) => {
  const provider = network
    ? getDefaultProvider(network)
    : new HDWalletProvider(options.pk, options.host);
  return new Web3(provider, null, {
    transactionConfirmationBlocks: 1
  });
};

const currentTimestamp = async web3 => {
  const lastBlock = await web3.eth.getBlock('latest');
  return lastBlock.timestamp;
};

const getConfig = network => config[network];

const decodeLog = async (web3, contractJson, eventName, tx) => {
  abiDecoder.addABI(contractJson.abi);
  const txReceipt = await new web3.eth.getTransactionReceipt(tx);
  console.log('Decoding Tx receipt', _.pick(txReceipt, ['transactionHash', 'from', 'to']));

  const decoded = abiDecoder.decodeLogs(txReceipt.logs);
  const event = decoded.find(it => it && it.name === eventName);

  console.log(`${eventName} event:`, event.events);
  return event;
};

const deployProxyContract = async ({ network, contractAlias, newAdmin }, constructorArguments) => {
  const web3 = getWeb3(network);
  const [owner] = await web3.eth.getAccounts();
  console.log(
    'Deploy proxy contract',
    network,
    contractAlias,
    newAdmin,
    Object.values(constructorArguments)
  );

  const { txParams } = await ConfigVariablesInitializer.initNetworkConfiguration({
    network,
    from: owner
  });

  const options = { network, txParams };
  console.log('Adding contract to zos tracking system');
  add({ contractsData: [contractAlias] });
  // This may cause problems if there are too many implementations
  // being pushed. Try removing them in zos.json if you are having this issue
  console.log('Pushing implementations');
  await push({ force: true, ...options });
  console.log('Creating proxy');
  const proxySplitter = await create({
    contractAlias,
    ...options
  });
  console.log('Initializing');
  proxySplitter.methods.initialize(Object.values(constructorArguments));
  console.log('Setting admin');
  await setAdmin({
    contractAlias,
    ...options,
    newAdmin
  });
  console.log('Finished deployinh Proxy');
};

const deployContract = async (newContract, network, constructorArguments) => {
  const web3 = getWeb3(network);
  const [owner] = await web3.eth.getAccounts();
  const NewContractConstructor = await new web3.eth.Contract(newContract.abi);
  console.log('Deploying');
  console.log('constructorArguments', constructorArguments);
  return NewContractConstructor.deploy({
    data: newContract.bytecode,
    arguments: constructorArguments
  })
    .send({ from: owner })
    .on('transactionHash', hash => console.log('TxHash:', hash))
    .on('confirmation', confirmationNumber => console.log('Tx confirmation:', confirmationNumber))
    .on('receipt', receipt => console.log('Tx receipt:', receipt))
    .on('error', err => console.error(`ERROR DEPLOYING: ${err}`));
};

// Theory behind
// https://ethereum.stackexchange.com/questions/11030/how-can-i-deploy-a-contract-with-reference-to-a-library-contract-without-using-a
// Important: libraryAddress must be without the initial a 0x
const linkLibrary = (contract, libraryName, libraryAddress) => {
  // eslint-disable-next-line no-param-reassign
  contract.bytecode = contract.bytecode.replace(new RegExp(`_*${libraryName}_*`), libraryAddress);
};

module.exports = {
  getWeb3,
  getNetworkHost,
  currentTimestamp,
  getConfig,
  decodeLog,
  deployContract,
  linkLibrary,
  deployProxyContract
};
