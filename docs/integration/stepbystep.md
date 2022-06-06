# Vendors integration

## Become partner with money on chain earning up to 1% commission on all your sales.

Vendors are third parties who want to integrate their platform with the MoC ecosystem. Vendors can charge a markup of up to 1% of the value to mint/redeem operations, and receive this value as MoC tokens. These tokens neither receive rewards nor vote nor can they participate as an oracle or as no other function that MoC stakeholders have in the Staking Machine.

## Step by step guide.

### 1 Step One: Choose your Markup
Choose what percentage of commission you want to receive (maximum 1%) and prepare an address to receive the earnings. Once you are ready, contact the team so that we can register you as a vendor.

Contact the [Money on Chain team](https://moneyonchain.com/)
* Send DM via [Twitter](https://twitter.com/moneyonchainok)
* Send DM via [Telegram](https://t.me/MoneyOnChainCommunity)
 

 ### 2 Step Two: Approve the allowance


Before start please make sure that someone of the team has activated your address as a vendor For starting operations with MoCVendor we need to allow to MoCVendors.sol and MoC.sol using MoC Token.
With this same address that you chose for receiving vendor’s comission, you must go to the contract moc.sol (link) and mocVendor.sol (link) and execute an allowance function. The approval transaction is used to grant permission for the smart contract to transfer a certain amount of the token, called allowance.
There is many ways to do this step.
A. Runing a script.js that interacts with The MocToken.sol  ABI
B. Interacting with the Remix Interface 
C. With one click Dapp UI.


You must interact with the following [contract](https://github.com/money-on-chain/main-RBTC-contract/blob/master-gitbook/contracts/MoCVendors.sol) 

**Moc Token**

| Environment | Contract | Contract address |
| --- | --- | --- |
| Testnet | MoCToken | 0x45A97b54021A3F99827641AFE1bFae574431E6ab |
| Mainnet | MoCToken | 0x9aC7Fe28967b30e3a4E6E03286D715B42B453d10 |



The next thing here is Allow moc.sol and mocVendors.sol to be able to interact with each other. And for this we will approach the allow function.


**Example Call approve:**

| Environment | Contract to allow | Address                                    | Amount in wei          |
| ---         | ---               | ---                                        | ---                    |
| Testnet     | MoC.sol           | 0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F | 1000000000000000000000 |
| Testnet     | MoCVendors.sol    | 0x84b895A1b7be8fAc64d43757479281Bf0b5E3719 | 1000000000000000000000 |

| Mainnet     | MoC.sol           | 0xf773B590aF754D597770937Fa8ea7AbDf2668370 | 1000000000000000000000 |
| Mainnet     | MoCVendors.sol    | 0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA | 1000000000000000000000 |


### 3 Step Three: Stake some MOC

Notice that MocVendors program have a limit in earning commissions , and thath limit is up to You. Let me explain : Let suppose that you staked 500 mocs on commissions , the maximum profit that you can reach is 500 mocs also, So the limit is up what you Stake

Be sure to stake the MOCs in the MocVendors.sol

Here is the [ABI:](https://docs.moneyonchain.com/main-rbtc-contract/smart-contracts/abis-documentation/mocvendors)

Here is the .sol [contract:] (https://github.com/money-on-chain/main-RBTC-contract/blob/master-gitbook/contracts/MoCVendors.sol)

**Go to the addStake function and stake some Mocs**
You can unstake it when ever you want


### 4 Step : Test its !!!


[Open this repo locally:](https://github.com/money-on-chain/moc-integration-js)

Create a .env file and fill your private information 

Run test mint docs

`npm run mint-doc`


Go to the contract MocVendors.sol again in the third step and interact 

Interact wit the function getTotalPaidInMoc and see how much you earned Thats it!

`getTotalPaidInMoc(address)`

**Thats it , now you can see how much Moc tokens you earned.**