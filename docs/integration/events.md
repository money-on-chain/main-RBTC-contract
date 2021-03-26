# Events

When a transaction is mined, smart contracts can emit events and write logs to the blockchain that the frontend can then process. Click [here](https://media.consensys.net/technical-introduction-to-events-and-logs-in-ethereum-a074d65dd61e) for more information about events.

In the following example we will show you how to find events that are emitted by Money On Chain smart contract in **RSK Testnet** blockchain with **truffle**.


**Code example**

```js
const Web3 = require('web3');
//You must compile the smart contracts or use the official ABIs of the repository
const MocExchange = require('../../build/contracts/MoCExchange.json');
const truffleConfig = require('../../truffle');

/**
 * Get a provider from truffle.js file
 * @param {String} network
 */
const getDefaultProvider = network =>
  truffleConfig.networks[network].provider || truffleConfig.networks[network].endpoint;

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

//Contract address on testnet
const mocExchangeAddress = '<contract-address>';

const execute = async () => {
  web3.eth.defaultGas = 2000000;

  /**
   * Loads an specified contract
   * @param {ContractABI} abi
   * @param {String} contractAddress
   */
  const getContract = async (abi, contractAddress) => new web3.eth.Contract(abi, contractAddress);

  // Loading MoCExchange contract to get the events emitted by this
  const mocExchange = await getContract(MocExchange.abi, mocExchangeAddress);
  if (!mocExchange) {
    throw Error('Can not find MoCExchange contract.');
  }

  // In this example we are getting BPro Mint events from MoCExchange contract
  // in the interval of blocks passed by parameter
  const getEvents = () =>
    Promise.resolve(mocExchange.getPastEvents('RiskProMint', { fromBlock: 1000, toBlock: 1010 }))
      .then(events => console.log(events))
      .catch(err => console.log('Error getting past events ', err));

  await getEvents();
};

execute()
  .then(() => console.log('Completed'))
  .catch(err => {
    console.log('Error', err);
  });
```

See [getPastEvents](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html?highlight=getPastEvents#events-allevents) for parameters and event structure details.
