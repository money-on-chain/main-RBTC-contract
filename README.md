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

(Truffle suit)[https://github.com/trufflesuite/truffle] is recommended to compile and deploy the contracts.
 
1.  Edit truffle.js and change add network changes and point to your
    ganache cli or rsk node.
    
2. Edit migrations/config/config.json and make changes

3. Run `npm run truffle-compile` to compile the code

4. Run `npm run migrate-development` to deploy the contracts
  
## Contracts

* Network: **RSK Mainnet**
* Type: **Production**

**Tokens**

|  Contract  |  Address |  
|:---|:---|
|  DoC  | [0xe700691da7b9851f2f35f8b8182c69c53ccad9db](https://explorer.rsk.co/address/0xe700691da7b9851f2f35f8b8182c69c53ccad9db?__ctab=general) |
|  BitPRO  | [0x440cd83c160de5c96ddb20246815ea44c7abbca8](https://explorer.rsk.co/address/0x440cd83c160de5c96ddb20246815ea44c7abbca8) |


**Implementations**

|  Contract  |  Address |  
|:---|:---|
|  MoCHelperLib  | [0x4e1894debd18b470706a20ac8fe0cc2d9e904218](https://explorer.rsk.co/address/0x4e1894debd18b470706a20ac8fe0cc2d9e904218?__ctab=general) |
|  MoC  | [0x8e065bf32bb68c1a32e37d7276f8c8dd5545e029](https://explorer.rsk.co/address/0x8e065bf32bb68c1a32e37d7276f8c8dd5545e029?__ctab=general) |
|  MoCConnector  | [0x437221b50b0066186e58412b0ba940441a7b7df5](https://explorer.rsk.co/address/0x437221b50b0066186e58412b0ba940441a7b7df5?__ctab=general) |
|  MoCBProxManager  | [0x2745652c5e765777779ddb9799e8bc1add892c43](https://explorer.rsk.co/address/0x2745652c5e765777779ddb9799e8bc1add892c43?__ctab=general) |
|  MoCBurnout  | [0x1d1bee3a56c01cae266bfb62dd6fef53e3f5e508](https://explorer.rsk.co/address/0x1d1bee3a56c01cae266bfb62dd6fef53e3f5e508?__ctab=general) |
|  MoCSettlement  | [0xe3abce2b0ee0d7ea48a5bcd0442d5505ae5b6334](https://explorer.rsk.co/address/0xe3abce2b0ee0d7ea48a5bcd0442d5505ae5b6334?__ctab=general) |
|  MoCConverter  | [0x0CFc08501780bc02Ca4c16324D22F32511B309a9](https://explorer.rsk.co/address/0x0CFc08501780bc02Ca4c16324D22F32511B309a9?__ctab=general) |
|  MocState  | [0x08817f585A9F2601fB7bFFfE913Dac305Aaf2dDd](https://explorer.rsk.co/address/0x08817f585A9F2601fB7bFFfE913Dac305Aaf2dDd) |
|  MocExchange  | [0x785814724324C63ec52e6675C899508E74850046](https://explorer.rsk.co/address/0x785814724324C63ec52e6675C899508E74850046) |
|  MocInrate  | [0x56e327FA971572828f846BE9E37FB850e5852822](https://explorer.rsk.co/address/0x56e327FA971572828f846BE9E37FB850e5852822) |
|  Medianizer  | [0x7b19bb8e6c5188ec483b784d6fb5d807a77b21bf](https://explorer.rsk.co/address/0x7b19bb8e6c5188ec483b784d6fb5d807a77b21bf) |

**Proxies**

|  Contract  |  Address |  
|:---|:---|
|  MoC  | [0xf773B590aF754D597770937Fa8ea7AbDf2668370](https://explorer.rsk.co/address/0xf773B590aF754D597770937Fa8ea7AbDf2668370) |
|  MoCConnector  | [0xcE2A128cC73e5d98355aAfb2595647F2D3171Faa](https://explorer.rsk.co/address/0xcE2A128cC73e5d98355aAfb2595647F2D3171Faa?__ctab=general) |
|  MoCBProxManager  | [0xC4fBFa2270Be87FEe5BC38f7a1Bb6A9415103b6c](https://explorer.rsk.co/address/0xC4fBFa2270Be87FEe5BC38f7a1Bb6A9415103b6c?__ctab=general) |
|  MoCBurnout  | [0xE69fB8C8fE9dCa08350AF5C47508f3E688D0CDd1](https://explorer.rsk.co/address/0xE69fB8C8fE9dCa08350AF5C47508f3E688D0CDd1?__ctab=general) |
|  MoCSettlement  | [0x609dF03D8a85eAffE376189CA7834D4C35e32F22](https://explorer.rsk.co/address/0x609dF03D8a85eAffE376189CA7834D4C35e32F22?__ctab=general) |
|  MoCConverter  | [0x0B7507032f140f5Ae5C0f1dA2251a0cd82c82296](https://explorer.rsk.co/address/0x0B7507032f140f5Ae5C0f1dA2251a0cd82c82296?__ctab=general) |
|  MocState  | [0xb9C42EFc8ec54490a37cA91c423F7285Fa01e257](https://explorer.rsk.co/address/0xb9C42EFc8ec54490a37cA91c423F7285Fa01e257) |
|  MocExchange  | [0x6aCb83bB0281FB847b43cf7dd5e2766BFDF49038](https://explorer.rsk.co/address/0x6aCb83bB0281FB847b43cf7dd5e2766BFDF49038) |
|  MocInrate  | [0xc0f9B54c41E3d0587Ce0F7540738d8d649b0A3F3](https://explorer.rsk.co/address/0xc0f9B54c41E3d0587Ce0F7540738d8d649b0A3F3) |
|  Medianizer  | [0x7b19bb8e6c5188ec483b784d6fb5d807a77b21bf](https://explorer.rsk.co/address/0x7b19bb8e6c5188ec483b784d6fb5d807a77b21bf) |


### Security and Audits


[Audits](https://github.com/money-on-chain/Audits)
