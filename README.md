This is the main RBTC-collateralized stablecoin contract

# Introduction

Money On Chain is a suite of smart contracts dedicated to providing a bitcoin-collateralized stable-coin, Dollar On Chain, (DoC); a passive income hodler-targeted token, BitPro (BPRO), and a leveraged Bitcoin investment instrument (BTCX series).
The rationale behind this is that deposits of Rootstock-BTC (RBTC) help collateralize the DoCs, BitPro absorbs the USD-BTC rate fluctuations, and BTC2X is leveraged borrowing value from BitPro and DoC holders, with a daily interest rate being paid to the former.


[Full explanation](MOC.md)

# Getting Started

## Install dependencies

- Use nodejs v8.12: `nvm install 8.12 && nvm alias default 8.12`
- Install local dependencies: `npm install`

## Run Ganache-cli

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

## Run Rsk Local Node

- With Docker:
  See this repo: https://github.com/rsksmart/artifacts/tree/master/Dockerfiles/RSK-Node

## Run Tests

- run: `npm test`

### With Coverage

- `npm run coverage`
- browse: [./coverage/index.html](./coverage/index.html)

## Deploy

(Truffle suit)[https://github.com/trufflesuite/truffle] is recommended to compile and deploy the contracts.
 
1.  Edit truffle.js and change add network changes and point to your
    ganache cli or rsk node.
    
2. Edit migrations/config/config.json and make changes

3. Run `npm run truffle-compile` to compile the code

4. Run `npm run migrate-development` to deploy the contracts
  
## Main contracts

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
