# Official Money on Chain ABIs

In the Money on Chain repository you can find the [official ABIs of the platform](https://github.com/money-on-chain/web-billfold-app/tree/develop/contracts/moc). You can use them to build your own decentralized applications to invoke the functions of smart contracts.

We can also compile the contracts to generate the ABIS that will be saved in the _./build/contracts_
dir. You can do this with the following commands:

```
git clone https://github.com/money-on-chain/main-RBTC-contract.git
cd main-RBTC-contract
npm install
npm run truffle-compile
```

Then we can check the abis

```
cd build/contracts/
ls -la
```

```
drwxrwxr-x 2 user user    4096 abr 24 18:15 .
drwxrwxr-x 3 user user    4096 abr 24 18:15 ..
-rw-rw-r-- 1 user user   58622 abr 24 18:15 AdminUpgradeabilityProxy.json
-rw-rw-r-- 1 user user  172799 abr 24 18:15 BaseAdminUpgradeabilityProxy.json
-rw-rw-r-- 1 user user   62097 abr 24 18:15 BaseUpgradeabilityProxy.json
-rw-rw-r-- 1 user user   91558 abr 24 18:15 BProToken.json
-rw-rw-r-- 1 user user   17711 abr 24 18:15 BtcPriceFeed.json
-rw-rw-r-- 1 user user    9360 abr 24 18:15 BtcPriceProvider.json
...
```
