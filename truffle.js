const HDWalletProvider = require("truffle-hdwallet-provider");

const mnemonic =
  process.env.MNEMONIC ||
  "lab direct float merit wall huge wheat loyal maple cup battle butter";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  compilers: {
    solc: {
      version: "0.5.8",
      evmVersion: "byzantium",
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
      host: "127.0.0.1",
      port: 8545,
      endpoint: "http://127.0.0.1:8545",
      network_id: "*",
      gas: 6721975,
      gasPrice: 20000000000
    },
    coverage: {
      host: "localhost",
      network_id: "*", // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    qaTestnet: {
      host: "http://45.79.72.117:4445/",
      provider: new HDWalletProvider(mnemonic, "http://45.79.72.117:4445/"),
      network_id: "*",
      gasPrice: 8e8
    }
  },
  mocha: {
    useColors: true,
    bail: true
  }
};
