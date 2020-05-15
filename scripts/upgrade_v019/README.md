# Upgrade Smart Contract

## Upgrade v019

**Requirements**

1. Python >= 3.6
2. `pip install moneyonchain==0.04`

**Steps:**

 1. Compile contracts: `npm run truffle-compile`

 2. Edit scripts/upgrade_v019/config.json
 
```
"develop": {
      "uri": "http://127.0.0.1:8545",
      "chain_id": null,
      "accounts": [
        {
          "address": "0x0e424e9a8598a55918e12de47172f3180c4b4e13",
          "private_key":  ""
        }
      ],
      "addresses": {
        "governor": "0x4B7250eE63F09dF3312d6B0E59B062Eb73fBAB18",
        "upgradeDelegator": "0xa0474c9c745Bf66bd8848f478764700f18e183c4",
        "MoC": "0xdeD5F72c57E7A9d336ef9C9B5e22727Ac391C1ED",
        "MoCSettlement": "0xa0dA80B5E5bdf96F9e99630Fa333821fB741A308",
        "MoCHelperLib": "0x2556a2509Fb3C5bb8102Bc876358f0A3c1BA3E8B"
      }

    },
```

Edit and change network you are going to use, also addresses of governor, upgradeDelegator, MoC and MoCHelperlib. Note MoCHelperlib is usually in zos.dev-*

3. Edit upgrade_moc_v019.py and change **network** to desire avalaible in config.json

```
import os
from web3 import Web3
from moneyonchain.manager import ConnectionManager

network = 'develop' 
```

4. run env with your account private key: `export ACCOUNT_PK_SECRET=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200`

5. run python: `python upgrade_moc_v019.py`

We get this:

```
Connecting to mocTestnetAlpha...
Connected: True
Deploying new contract MoC version 019...
....
New Deploy Contract Address: 0xEe319505F1BE7E05203E2dA5d2ecd79a127ceE6C
...
Finish upgrading contract!.
Contract address to execute change: 0x617aD9e49EB40B5c844fD02172bbFeF0e4A4a004
```

6. run python: `python upgrade_moc_settlement_v019.py`

```
Connecting to mocTestnetAlpha...
Connected: True
Deploying new contract MoC Settlement version 019...
...
Finish deploying contract!.
New Deploy Contract Address: 0xc704769B016Ebb463173159Ed62c37517cB3E077
Upgrading old implementation: 0xa0dA80B5E5bdf96F9e99630Fa333821fB741A308 to newone 0xc704769B016Ebb463173159Ed62c37517cB3E077
...
Finish upgrading contract!.
Contract address to execute change: 0x0f9aBc50d3FBcF5f090CA584a7956FCB52F5d7d1
```

7. run python: `python upgrade_moc_settlement_fix.py`

