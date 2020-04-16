This is the main RBTC-collateralized stablecoin contract

# Introduction

Money On Chain is a suite of smart contracts dedicated to providing a
bitcoin-collateralized stable-coin, Dollar On Chain, (DoC); a passive
income holder-targeted token, BitPro (BPRO), and a leveraged Bitcoin
investment instrument (BTCX series). The rationale behind this is that
deposits of Rootstock-BTC (RBTC) help collateralize the DoCs, BitPro
absorbs the USD-BTC rate fluctuations, and BTC2X is leveraged borrowing
value from BitPro and DoC holders, with a daily interest rate being paid
to the former.


[Full explanation](MOC.md)

# Getting Started

## Install dependencies

- Use nodejs v8.12: `nvm install 8.12 && nvm alias default 8.12`
- Install local dependencies: `npm install`

## Node

You need a node to run contracts. Ganache cli for developing purpose

1. Ganache-cli

- Globally:

```sh
npm install -g ganache-cli;
ganache-cli
```

- Using Docker:

```sh
docker pull trufflesuite/ganache-cli;
docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest
```

2. Rsk Local Node

- With Docker:
  See this repo: https://github.com/rsksmart/artifacts/tree/master/Dockerfiles/RSK-Node

## Tests

**Node**

First run test node example:

- run test node: `npm run ganache-cli`

**Tests**


- run: `npm run test`

**Tests With Coverage**

- `npm run coverage`
- browse: [./coverage/index.html](./coverage/index.html)

## Deploy

[Truffle suit](https://github.com/trufflesuite/truffle) is recommended to compile and deploy the contracts.
 
1.  Edit truffle.js and change add network changes and point to your
    ganache cli or rsk node.
    
2. Edit migrations/config/config.json and make changes

3. Run `npm run truffle-compile` to compile the code

4. Run `npm run migrate-development` to deploy the contracts
 


### Security and Audits

[Deployed Contracts](https://github.com/money-on-chain/main-RBTC-contract/blob/master/Contracts%20verification.md)
[Audits](https://github.com/money-on-chain/Audits)

For more technical information you can see our [abi documentation](smart-contracts-abi.md)
