# Example code minting BTCx

In the following script example we will learn how to:

- Get the maximum amount of BTCx available to mint.
- Mint BTCx.

We will use **truffle** and **testnet** network.
You can find code examples into _/examples_ dir.

First we create a new node project.

```
mkdir example-mint-btc2x
cd example-mint-btc2x
npm init
```

Let's add the necessary dependencies to run the project.

```
npm install --save web3
npm install --save bignumber.js
```

**Example**

```js
const BigNumber = require('bignumber.js');
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the repository
const Moc = require('../../build/contracts/MoC.json');
const MoCInrate = require('../../build/contracts/MoCInrate.json');
const MoCExchangeAbi = require('../../build/contracts/MoCExchange.json');
const MoCState = require('../../build/contracts/MoCState.json');
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
  const strToBytes32 = bucket => web3.utils.asciiToHex(bucket, 32);
  const bucketX2 = 'X2';

  // Loading moc contract
  const moc = await getContract(Moc.abi, mocContractAddress);
  if (!moc) {
    throw Error('Can not find MoC contract.');
  }

  // Loading mocInrate contract. It is necessary to get fees for transaction types
  const mocInrate = await getContract(MoCInrate.abi, mocInrateAddress);
  if (!mocInrate) {
    throw Error('Can not find MoC Inrate contract.');
  }

  // Loading mocExchange contract. It is necessary to compute commissions and vendor markup
  const mocExchange = await getContract(MoCExchangeAbi.abi, mocExchangeAddress);
  if (!mocExchange) {
    throw Error('Can not find MoC Exchange contract.');
  }

  // Loading mocState contract. It is necessary to compute max BTC2X available to mint
  const mocState = await getContract(MoCState.abi, mocStateAddress);
  if (!mocState) {
    throw Error('Can not find MoCState contract.');
  }

  const mintBtc2x = async (btcAmount, vendorAccount) => {
    const [from] = await web3.eth.getAccounts();
    const weiAmount = web3.utils.toWei(btcAmount, 'ether');
    const btcInterestAmount = await mocInrate.methods.calcMintInterestValues(strToBytes32(bucketX2), weiAmount).call();
    let btcCommission;
    let mocCommission;
    let btcMarkup;
    let mocMarkup;
    // Set transaction types
    const txTypeFeesRBTC = await mocInrate.methods.MINT_BTCX_FEES_RBTC();
    const txTypeFeesMOC = await mocInrate.methods.MINT_BTCX_FEES_MOC();
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
    // Computes totalBtcAmount to call mintBProxVendors
    const totalBtcAmount = toContract(btcInterestAmount.plus(btcCommission).plus(btcMarkup).plus(weiAmount));
    console.log(`Calling mint BTC2X with ${btcAmount} Btcs with account: ${from}.`);
    moc.methods
      .mintBProxVendors(strToBytes32(bucketX2), weiAmount, vendorAccount)
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

  const btcToMint = '0.00001';
  // Gets max BTC2X amount available to mint
  const maxBtc2x = await mocState.methods.maxBProx(strToBytes32(bucketX2)).call();

  console.log('=== Max Available BTC2X to mint: '.concat(maxBtc2x.toString()));

  const vendorAccount = '<vendor-address>';

  // Call mint
  await mintBtc2x(btcToMint, vendorAccount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
