# Getting started

## Install dependencies

- Use nodejs v8.12: `nvm install 8.12 && nvm alias default 8.12`
- Install local dependencies: `npm install`

## Node

You need a node to run contracts. Use `ganache-cli` for developing purposes.

- Install Ganache globally:

```sh
npm install -g ganache-cli;
npm run ganache-cli
```

- Or using Docker:

```sh
docker pull trufflesuite/ganache-cli;
docker run -d -p 8545:8545 trufflesuite/ganache-cli:latest
```

## Run RSK Local Node

- With Docker:

  See this repo: https://github.com/rsksmart/artifacts/tree/master/Dockerfiles/RSK-Node

## Run Tests

- run: `npm run test`

**Tests With Coverage**

Coverage tests use their own node, so there is no need to run Ganache separately.
- run: `npm run coverage`
- browse: `./coverage/index.html` inside the project's folder.

## Deploy

[Truffle suite](https://github.com/trufflesuite/truffle) is recommended to compile and deploy the contracts. There are a set of scripts to easy this process for the different known environments. Each environment (and network) might defer in its configuration settings, you can adjust this values in the the `migrations/config/config.json` file.

At the end of the deployment the addresses of the most relevant contracts will be displayed. If you are interested in another contracts you should look inside some files depending if the contracts is upgradeable or not.

The addresses of the deployed proxies will be in a file called `zos.<network-id>.json` . There you will have to look inside the proxies object and look for the `address` of the proxy you are interested in. If you are interested in the address of a contract that has not a proxy you should look for it in the prints of the deployment or inside the `builds/<contract-name>.json` file.

1.  Edit truffle.js and change add network changes and point to your
    `ganache-cli` or RSK node.

2.  Edit `migrations/config/config.json` and make changes

3.  Run `npm run truffle-compile` to compile the code

4.  Run `npm run migrate-development` to deploy the contracts

## Security and Audits

- [Deployed contracts](../contracts-verification.md)
- [Audits](https://github.com/money-on-chain/Audits)

For more technical information you can see our [ABI documentation](../abis/abi-documentation.md).

## Settings

- _initialPrice_: Bitcoin initial (current) price
- _initialEma_: Bitcoin initial EMA (exponential moving average) price
- _dayBlockSpan_: Average amount of blocks expected to be mined in a calendar day in this network.
- _settlementDays_: Amount of days in between settlement to allowed executions
- _gas_: Gas to use on MoC.sol contract deploy.
- _oracle_: Moc Price Provider compatible address (see `contracts/interface/PriceProvider.sol`). You can deploy this contract using the `oracle` project or (in development) the mock:`contracts/mocks/BtcPriceProviderMock.sol` (which is deployed on development migration by default).
- _startStoppable_: If set to true, the MoC contract can be stopped after the deployment. If set to false, before pausing the contract you should make it stoppable with governance(this together with the blockage of the governance system can result in a blockage of the pausing system too).
- _commissionSplitter_: Defines an address for an existing CommissionSplitter. If none is set, then the CommissionSplitter will be deployed.
- _mocCommissionProportion_: Defines the proportion of commissions that will be injected as collateral to MoC. This configuration only works if no _commissionSplitter_ address is set.
