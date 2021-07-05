# Official Money on Chain ABIs

You can use the official ABIs of the Money on Chain platform to build your own decentralized applications to invoke the functions of smart contracts.

You can compile the contracts to generate the ABIs that will be saved in the _./build/contracts_ dir running the following commands:

```
git clone https://github.com/money-on-chain/main-RBTC-contract.git
cd main-RBTC-contract
npm install
npm run truffle-compile
```

Then you can check the ABIs:

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
