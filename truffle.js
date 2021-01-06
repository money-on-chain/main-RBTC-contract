const HDWalletProvider = require('truffle-hdwallet-provider');

// Change mnemonic according to who is deploying
const mnemonic =
  process.env.MNEMONIC || 'lab direct float merit wall huge wheat loyal maple cup battle butter';

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
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
      network_id: '*',
      gas: 6721975,
      gasPrice: 20000000000
    },
    regtest: {
      host: '127.0.0.1',
      port: 4444,
      network_id: '*',
      gas: 6001975,
      gasPrice: 65000000
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    rskAlphaTestnet: {
      host: 'https://public-node.testnet.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co'),
      network_id: '*',
      gas: 6700000,
      gasPrice: 69000000,
      skipDryRun: true,
      confirmations: 1
    },
    rskMocTestnet: {
      host: 'https://public-node.testnet.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co'),
      network_id: '*',
      gas: 6700000,
      gasPrice: 69000000,
      skipDryRun: true,
      confirmations: 1
    },
    rskMocMainnet2: {
      host: 'https://public-node.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.rsk.co'),
      network_id: '*',
      gas: 6700000,
      gasPrice: 60000000,
      skipDryRun: true,
      confirmations: 1
    },
    prueba: {
      // host: '127.0.0.1',
      // port: 8545,
      // endpoint: 'http://127.0.0.1:8545',
      // network_id: '*',
      // gas: 6721975,
      // gasPrice: 20000000000
      host: 'https://public-node.testnet.rsk.co',
      provider: new HDWalletProvider(mnemonic, 'https://public-node.testnet.rsk.co'),
      network_id: '31',
      gas: 6700000,
      gasPrice: 69000000,
      skipDryRun: true,
      confirmations: 1
    }
  },
  mocha: {
    useColors: true,
    bail: false
  }
};