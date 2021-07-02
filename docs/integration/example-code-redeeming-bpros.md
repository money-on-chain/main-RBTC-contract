# Example code redeeming BPros

In the following example we will learn how to:

- Get the maximum amount of BPRO available to redeem.
- Get BPRO balance of an account.
- Redeem BPROs.

We will use **truffle** and **testnet** network.

First we create a new node project.

```
mkdir example-redeem-bpro
cd example-redeem-bpro
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
const MocAbi = require('../../build/contracts/MoC.json');
const MoCStateAbi = require('../../build/contracts/MoCState.json');
const BProTokenAbi = require('../../build/contracts/BProToken.json');
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
const bproTokenAddress = '<contract-address>';

const execute = async () => {
  web3.eth.defaultGas = 2000000;

  /**
   * Loads an specified contract
   * @param {ContractABI} abi
   * @param {String} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);

  // Loading moc contract
  const moc = await getContract(MocAbi.abi, mocContractAddress);
  if (!moc) {
    throw Error('Can not find MoC contract.');
  }

  // Loading mocState contract. It is necessary to compute absolute max BPRO
  const mocState = await getContract(MoCStateAbi.abi, mocStateAddress);
  if (!mocState) {
    throw Error('Can not find MoCState contract.');
  }

  // Loading BProToken contract. It is necessary to compute user balance
  const bproToken = await getContract(BProTokenAbi.abi, bproTokenAddress);
  if (!bproToken) {
    throw Error('Can not find BProToken contract.');
  }

  const [from] = await web3.eth.getAccounts();

  const redeemBpro = async (bproAmount, vendorAccount) => {
    const weiAmount = web3.utils.toWei(bproAmount, 'ether');

    console.log(`Calling redeem Bpro with account: ${from} and amount: ${weiAmount}.`);
    moc.methods
      .redeemBProVendors(weiAmount, vendorAccount)
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

  const getAbsoluteMaxBpro = await mocState.methods.absoluteMaxBPro().call();
  const userAmount = await bproToken.methods.balanceOf(from).call();

  console.log('=== Max amount of BPro to redeem: ', getAbsoluteMaxBpro.toString());
  console.log('=== User BPro Balance: ', userAmount.toString());

  const bproAmount = '0.00001';
  const vendorAccount = '<vendor-address>';

  // Call redeem
  await redeemBpro(bproAmount, vendorAccount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
