# Example code redeeming BTCx

In the following script example we will learn how to:

- Get BTCx balance of an account.
- Redeem BTCx.

We will use **truffle** and **testnet** network.
You can find code examples into _/examples_ dir.

First we create a new node project.

```
mkdir example-redeem-btc2x
cd example-redeem-btc2x
npm init
```

Let's add the necessary dependencies to run the project.

```
npm install --save web3
```

**Example**

```js
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the repository
const MoC = require('../../build/contracts/MoC.json');
const MoCBProxManager = require('../../build/contracts/MoCBProxManager.json');
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
const mocBProxManagerAddress = '<contract-address>';

const execute = async () => {
  web3.eth.defaultGas = 2000000;

  /**
   * Loads an specified contract
   * @param {ContractABI} abi
   * @param {String} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);
  const strToBytes32 = bucket => web3.utils.asciiToHex(bucket, 32);
  const bucketX2 = 'X2';

  // Loading Moc contract
  const moc = await getContract(MoC.abi, mocContractAddress);
  if (!moc) {
    throw Error('Can not find MoC contract.');
  }

  // Loading MoCBProxManager contract. It is necessary to compute user BTC2X balance
  const mocBproxManager = await getContract(MoCBProxManager.abi, mocBProxManagerAddress);
  if (!mocBproxManager) {
    throw Error('Can not find MoCBProxManager contract.');
  }

  const [from] = await web3.eth.getAccounts();

  const redeemBtc2x = async (btc2xAmount, vendorAccount) => {
    const weiAmount = web3.utils.toWei(btc2xAmount, 'ether');

    console.log(`Calling redeem BTC2X with account: ${from}, amount: ${weiAmount}.`);
    moc.methods
      .redeemBProxVendors(strToBytes32(bucketX2), weiAmount, vendorAccount)
      .send({ from, gasPrice }, function(error, transactionHash) {
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

  const userBalance = await mocBproxManager.methods
    .bproxBalanceOf(strToBytes32(bucketX2), from)
    .call();
  console.log('=== User BTC2X Balance: '.concat(userBalance.toString()));

  const btc2xAmount = '0.00001';
  const vendorAccount = '<vendor-address>';

  // Call redeem
  await redeemBtc2x(btc2xAmount, vendorAccount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
