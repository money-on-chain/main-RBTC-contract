# Example code minting BPros without Truffle

In the following example we will learn how to:

- Use the ABIs of Money on Chain.
- Get the maximum amount of BPRO available.
- Get the price of the BPRO in RBTC.
- Minting BPROs

We will use the **testnet** network

First we create a new node project.

```
mkdir example-mint-bpro
cd example-mint-bpro
npm init
```

Let's add the necessary dependencies to run the project.

```
npm install --save bignumber.js
npm install --save web3
npm install --save truffle-hdwallet-provider
```

Now we create a new script called **mintBpro.js** with the following code:

```js
const HDWalletProvider = require('truffle-hdwallet-provider');
const BigNumber = require('bignumber.js');
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the repository
const MocAbi = require('./contracts/moc/MoC.json');
const MoCInrateAbi = require('./contracts/moc/MoCInrate.json');
const MoCExchangeAbi = require('./contracts/moc/MoCExchange.json');
const MoCStateAbi = require('./contracts/moc/MoCState.json');

//Config params to TestNet
const endpoint = 'https://public-node.testnet.rsk.co';
//a mnemonic is 12 words instead of a single private key to sign the //transactions
const mnemonic = 'chase chair crew elbow uncle awful cover asset cradle pet loud puzzle';
const provider = new HDWalletProvider(mnemonic, endpoint);
const web3 = new Web3(provider);

//Contract addresses on testnet
const mocContractAddress = '<contract-address>';
const mocInrateAddress = '<contract-address>';
const mocExchangeAddress = '<contract-address>';
const mocStateAddress = '<contract-address>';
const gasPrice = 60000000;

const execute = async () => {
  /**
   * Loads an specified contract
   * @param {json ABI} abi
   * @param {localhost/testnet/mainnet} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);

  /**
   * Transforms BigNumbers into
   * @param {*} number
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
    web3.eth.getAccounts().then(console.log);
    const from = '0x088f4B1313D161D83B4D8A5EB90905C263ce0DbD';
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
    // Computes totalBtcAmount to call mintBpro. If commission is paid in RBTC, add it to value
    const totalBtcAmount = toContract(btcCommission.plus(btcMarkup).plus(weiAmount));
    console.log(`Calling Bpro minting with account: ${from} and amount: ${weiAmount}.`);
    const tx = moc.methods
      .mintBProVendors(weiAmount, vendorAccount)
      .send({ from, value: totalBtcAmount, gasPrice }, function(error, transactionHash) {
        if (error) console.log(error);
        if (transactionHash) console.log('txHash: '.concat(transactionHash));
      });

    return tx;
  };

  function logEnd() {
    console.log('End Example');
  }

  const btcAmount = '0.00005';
  const vendorAccount = '<vendor-address>';

  // Call mint
  await mintBpro(btcAmount, vendorAccount, logEnd);
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```
