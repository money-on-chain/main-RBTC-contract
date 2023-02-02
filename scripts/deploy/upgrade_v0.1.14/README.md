# Upgrade version v0.1.14 - Disable of mint leveraged position

This release include the upgrade of:

* MoC.sol Disable of mint Leveraged position. See: http://bit.ly/3XPiKUA

**Changer**: [Changer contract](https://explorer.rsk.co/address/0x58933d29430b79780f54d1e97cb70ea9558360be?__ctab=Code). 

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
OK. Proxy MoC.sol contract:  0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F
OK. Upgrade Delegator:  0xCDAbFbF334A5F6BCe900D2f73470D1e6722365d8
OK. New Implementation:  0xf7845D6991EEc3931a5aBb90b39857527d6e622e

```

**Proxies**

|  Contract  |  Address |  
|:---|:---|
|  MoC  | [0xf773B590aF754D597770937Fa8ea7AbDf2668370](https://explorer.rsk.co/address/0xf773B590aF754D597770937Fa8ea7AbDf2668370) |


**Implementations**

|  Contract  |  Address |  
|:---|:---|
|  MoCHelperLib  | [0x592b84710955C9561008D137a5403E1dd9A222D8](https://explorer.rsk.co/address/0x592b84710955C9561008D137a5403E1dd9A222D8) |
|  MoC  | [0x9965C3B0fDcb9145AdFd4C0535716b109F450f9F](https://explorer.rsk.co/address/0x9965C3B0fDcb9145AdFd4C0535716b109F450f9F?__ctab=general) |

