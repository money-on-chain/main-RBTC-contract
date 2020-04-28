const BigNumber = require('bignumber.js');
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the //repository
const MocAbi = require('../../build/contracts/MoC.json');
const MoCInrateAbi = require('../../build/contracts/MoCInrate.json');
const MoCStateAbi = require('../../build/contracts/MoCState.json');
const MoCConverterAbi = require('../../build/contracts/MoCConverter.json');
const truffleConfig = require('../../truffle');

/**
 * Get a provider from truffle.js file
 * @param {String} network
 */
const getDefaultProvider = network =>
  truffleConfig.networks[network].provider || truffleConfig.networks[network].endpoint;

/**
 * Get a gasPrice from truffle.js file
 * @param {String} network
 */
const getGasPrice = network => truffleConfig.networks[network].gasPrice || 60000000;

/**
 * Get a new web3 instance from truffle.js file
 */
const getWeb3 = network => {
  const provider = getDefaultProvider(network);
  return new Web3(provider, null, {
    transactionConfirmationBlocks: 1
  });
};

const web3 = getWeb3('rskTestnet');
const gasPrice = getGasPrice('rskTestnet');

//Contract addresses on testnet
const mocContractAddress = '<contract-address>';
const mocInrateAddress = '<contract-address>';
const mocStateAddress = '<contract-address>';
const mocConverterAddress = '<contract-address>';

const execute = async () => {
  web3.eth.defaultGas = 2000000;

  /**
   * Loads an specified contract
   * @param {ContractABI} abi
   * @param {String} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);

  /**
   * Transforms BigNumbers into
   * @param {BigNumber} number
   */
  const toContract = number => new BigNumber(number).toFixed(0);

  // Loading moc contract
  const moc = await getContract(MocAbi.abi, mocContractAddress);
  if (!moc) {
    throw Error('Can not find MoC contract.');
  }

  // Loading mocInrate contract. It is necessary to compute commissions
  const mocInrate = await getContract(MoCInrateAbi.abi, mocInrateAddress);
  if (!mocInrate) {
    throw Error('Can not find MoC Inrate contract.');
  }

  // Loading mocState contract. It is necessary to compute max BPRO available to mint
  const mocState = await getContract(MoCStateAbi.abi, mocStateAddress);
  if (!mocState) {
    throw Error('Can not find MoCState contract.');
  }

  // Loading mocConverter contract. It is necessary to convert BTC into DOC
  const mocConverter = await getContract(MoCConverterAbi.abi, mocConverterAddress);
  if (!mocConverter) {
    throw Error('Can not find MoCConverter contract.');
  }

  const mintDoc = async btcAmount => {
    const [from] = await web3.eth.getAccounts();
    const weiAmount = web3.utils.toWei(btcAmount, 'ether');
    // Computes commision value
    const commissionValue = new BigNumber(
      await mocInrate.methods.calcCommissionValue(weiAmount).call()
    );
    // Computes totalBtcAmount to call mintBpro
    const totalBtcAmount = toContract(commissionValue.plus(weiAmount));
    console.log(`Calling Doc minting with account: ${from} and amount: ${weiAmount}.`);
    moc.methods
      .mintDoc(weiAmount)
      .send({ from, value: totalBtcAmount, gasPrice }, function(error, transactionHash) {
        if (error) console.log(error);
        if (transactionHash) console.log('txHash: '.concat(transactionHash));
      })
      .on('transactionHash', function(hash) {
        console.log('TxHash: '.concat(hash));
      })
      .on('receipt', function(receipt) {
        console.log(receipt);
      })
      .on('error', console.error);
  };

  // Gets max BPRO available to mint
  const getAbsoluteMaxDoc = await mocState.methods.absoluteMaxDoc().call();
  console.log('=== Max doc amount to mint: ', getAbsoluteMaxDoc.toString());
  const btcAmount = '0.00001';
  console.log('=== BTCs to mint:  ', btcAmount);
  console.log('=== converted to DOC amount: ', mocConverter.methods.btcToDoc(btcAmount).call());

  // Call mint
  await mintDoc(btcAmount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
