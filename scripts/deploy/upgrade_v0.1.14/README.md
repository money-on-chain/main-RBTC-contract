# Upgrade version v0.1.14 - Disable of mint leveraged position

This release include the upgrade of:

* MoC.sol Disable of mint Leveraged position. See: http://bit.ly/3XPiKUA

**Changer**: [Changer contract at 0x5B1D...D28eA](https://explorer.rsk.co/address/0x5B1D03983D6b59641274CB759d5fbd4C3BBD28eA?__ctab=Code). 

1. Deploy new MoC.sol implementation:

```js
cd scripts/deploy/upgrade_v0.1.14
truffle exec 1_deploy_MoC.js --network rskMocMainnet2
```

2. Deploy Changer implementation:

```js
cd scripts/deploy/upgrade_v0.1.14
truffle exec 2_deploy_changer.js --network rskMocMainnet2
```

You can verify the changer running:

```js
cd scripts/deploy/upgrade_v0.1.14
truffle exec 3_verification_changer.js --network rskMocMainnet2
```

result

```
Using network 'rskMocMainnet2'.

Changer contract parameters
OK. Proxy MoC.sol contract:  0xf773B590aF754D597770937Fa8ea7AbDf2668370
OK. Upgrade Delegator:  0x5cE577f6Ec969CE9a282838D350206C52A6F338C
OK. New Implementation:  0x2ef12B6488600D46Bb271A6eA5ba08dd980e60C5
```

**Proxies**

|  Contract  |  Address |  
|:---|:---|
|  MoC  | [0xf773B590aF754D597770937Fa8ea7AbDf2668370](https://explorer.rsk.co/address/0xf773B590aF754D597770937Fa8ea7AbDf2668370) |


**Implementations**

|  Contract  |  Address |  
|:---|:---|
|  MoCHelperLib  | [0x592b84710955C9561008D137a5403E1dd9A222D8](https://explorer.rsk.co/address/0x592b84710955C9561008D137a5403E1dd9A222D8) |
|  MoC  | [0x2ef12B6488600D46Bb271A6eA5ba08dd980e60C5](https://explorer.rsk.co/address/0x2ef12B6488600D46Bb271A6eA5ba08dd980e60C5?__ctab=general) |

