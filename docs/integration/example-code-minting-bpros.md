# Example code minting BPros

In the following example we will show how to invoke the mintBproVendors function of the Money on Chain contract in **testnet** with **truffle**.

You can find code examples into _/examples_ dir.

```js
const BigNumber = require('bignumber.js');
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the repository
const MocAbi = require('../../build/contracts/MoC.json');
const MoCInrateAbi = require('../../build/contracts/MoCInrate.json');
const MoCExchangeAbi = require('../../build/contracts/MoCExchange.json');
const MoCStateAbi = require('../../build/contracts/MoCState.json');
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
const mocExchangeAddress = '<contract-address>';
const mocStateAddress = '<contract-address>';

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

  // Loading mocInrate contract. It is necessary to get fees for transaction types
  const mocInrate = await getContract(MoCInrateAbi.abi, mocInrateAddress);
  if (!mocInrate) {
    throw Error('Can not find MoC Inrate contract.');
  }

  // Loading mocExchange contract. It is necessary to compute commissions and vendor markup
  const mocExchange = await getContract(MoCExchangeAbi.abi, mocExchangeAddress);
  if (!mocExchange) {
    throw Error('Can not find MoC Exchange contract.');
  }

  // Loading mocState contract. It is necessary to compute max BPRO available to mint
  const mocState = await getContract(MoCStateAbi.abi, mocStateAddress);
  if (!mocState) {
    throw Error('Can not find MoCState contract.');
  }

  const mintBpro = async (btcAmount, vendorAccount) => {
    const [from] = await web3.eth.getAccounts();
    const weiAmount = web3.utils.toWei(btcAmount, 'ether');
    let btcCommission;
    let mocCommission;
    let btcMarkup;
    let mocMarkup;
    // Set transaction types
    const txTypeFeesRBTC = await mocInrate.methods.MINT_BPRO_FEES_RBTC();
    const txTypeFeesMOC = await mocInrate.methods.MINT_BPRO_FEES_MOC();
    // Compute fees
    const params = {
      account: from,
      amount: toContractBN(weiAmount).toString(),
      txTypeFeesMOC: txTypeFeesMOC.toString(),
      txTypeFeesRBTC: txTypeFeesRBTC.toString(),
      vendorAccount
    };

    ({
      btcCommission,
      mocCommission,
      btcMarkup,
      mocMarkup
    } = await mocExchange.methods.calculateCommissionsWithPrices(params, { from }));
    // Computes totalBtcAmount to call mintBproVendors
    const totalBtcAmount = toContract(btcCommission.plus(btcMarkup).plus(weiAmount));
    console.log(`Calling Bpro minting with account: ${from} and amount: ${weiAmount}.`);
    moc.methods
      .mintBProVendors(weiAmount, vendorAccount)
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

  const bproPriceInRBTC = await mocState.methods.bproTecPrice().call();
  console.log('=== BPRO in RBTC: '.concat(bproPriceInRBTC.toString()));
  const btcAmount = '0.00001';
  const vendorAccount = '<vendor-address>';

  // Call mint
  await mintBpro(btcAmount, vendorAccount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
