# Example code redeeming Free DoC

In the following example we will show how to invoke redeemFreeDocVendors from Money on Chain contract. This method allows to redeem DOC outside the settlement and they are limited by user balance. Check the [DOC redeemption section](redeeming-docs.md) for more details.

We will learn how to:

- Get the maximum amount of DoCs available to redeem.
- Get DoC balance of an account.
- Redeem DoCs.

You can find code examples into _/examples_ dir.
We will use **truffle** and **testnet** network.
First we create a new node project.

```
mkdir example-redeem-free-doc
cd example-redeem-free-doc
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
const MocState = require('../../build/contracts/MoCState.json');
const DocToken = require('../../build/contracts/DocToken.json');
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
const mocAddress = '<contract-address>';
const mocStateAddress = '<contract-address>';
const docTokenAddress = '<contract-address>';

const execute = async () => {
  web3.eth.defaultGas = 2000000;

  /**
   * Loads an specified contract
   * @param {ContractABI} abi
   * @param {String} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);

  // Loading MoC contract
  const moc = await getContract(MoC.abi, mocAddress);
  if (!moc) {
    throw Error('Can not find MoC contract.');
  }

  // Loading mocState contract. It is necessary to compute freeDoc
  const mocState = await getContract(MocState.abi, mocStateAddress);
  if (!mocState) {
    throw Error('Can not find MoCState contract.');
  }

  // Loading DocToken contract. It is necessary to compute user balance
  const docToken = await getContract(DocToken.abi, docTokenAddress);
  if (!docToken) {
    throw Error('Can not find DocToken contract.');
  }

  const [from] = await web3.eth.getAccounts();

  const redeemFreeDoc = async (docAmount, vendorAccount) => {
    const weiAmount = web3.utils.toWei(docAmount, 'ether');

    console.log(`Calling redeem Doc request, account: ${from}, amount: ${weiAmount}.`);
    moc.methods
      .redeemFreeDocVendors(weiAmount, vendorAccount)
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

  const docAmount = '10000';
  const freeDoc = await mocState.methods.freeDoc().call();
  const userDocBalance = await docToken.methods.balanceOf(from).call();
  const finalDocAmount = Math.min(freeDoc, userDocBalance);
  const vendorAccount = '<vendor-address>';

  console.log('User DOC balance: ', userDocBalance.toString());
  console.log('=== Max Available DOC to redeem: ', finalDocAmount);

  // Call redeem
  await redeemFreeDoc(docAmount, vendorAccount);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
