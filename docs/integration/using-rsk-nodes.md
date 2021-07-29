# Using RSK nodes

Money on Chain contracts are executed on the RSK blockchain whose public nodes are testnet (testing environment) and mainnet (production environment). You can use a public node or install a node in your own server.

## Public node: RSK Testnet

- URL: https://public-node.testnet.rsk.co
- chainID: 31
- Cryptocurrency symbol: RBTC
- Explorer: https://explorer.testnet.rsk.co/

## Public node: RSK Mainnet

- URL: https://public-node.rsk.co
- chainID: 30
- Cryptocurrency symbol: RBTC
- Explorer: https://explorer.rsk.co/

## Truffle config: truffle.js

If you use truffle then you can use the following settings in your **truffle.js** file

```js
const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = 'YOUR_MNEMO_PRHASE';

module.exports = {
  compilers: {
    solc: {
      version: '0.5.8',
      evmVersion: 'byzantium',
      settings: {
        optimizer: {
          enabled: true,
          runs: 1
        }
      }
    }
  },
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'
    },
    rskTestnet: {
      host: 'https://public-node.testnet.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co'),
      network_id: '31',
      gasPrice: 60000000
    },
    rskMainnet: {
      host: 'https://public-node.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.rsk.co'),
      network_id: '30',
      gasPrice: 60000000
    }
  }
};
```

## Installing your own node

The RSK node can be installed on different operating systems such as Linux, Windows and Mac. It is also possible to run them in environments running docker and in cloud service providers such as AWS, Azure and Google. For more information check the [official RSK documentation](https://developers.rsk.co/rsk/node/install/)
