# Upgrade version v0.1.13

This release include the upgrade of:

* MoC Token added to use in the platform to pay commissions alternative to RBTC.
* Added MoC Token price provider from exchange.
* Added MoC Vendors to platform
* Added Protected State. If Global Coverage < 1.5 no operations allowed. Except btcx mint and redeem operations.
* Disable automatic liquidation of the contract. Do not automatically liquidate if it falls under the threshold in case of abrupt BTC price fall. With a changer we can disable this protection in order to liquidate the contract.
* Refactor contracts to implement interfaces to avoid circular dependencies, only affect source contract verification.
* Update to use Soldity 0.5.17 with optimizer enabled. To reduce gas used by operations.
* Refactor contracts to reduce their size and to reduce gas used by operations. Also remove functions not used anymore. Burnout contracts
* Refactor dev documentation: https://docs.moneyonchain.com/main-contract/
* New upgrade process. All contracts updated in one change.
* No force upgrade, old compatibility with third parties.
* 10 Contracts updated.

**Batch Upgrade Changer**: [0x58933D29430b79780F54d1E97CB70eA9558360BE](https://explorer.rsk.co/address/0x58933d29430b79780f54d1e97cb70ea9558360be?__ctab=Code). 

You can verify the changer running:

```js
cd scripts/deploy/upgrade_v0.1.12
truffle exec 11_verification_changer.js --network rskMocMainnet2
```

return

```
Using network 'rskMocMainnet2'.

Configuration path:  /home/martin/Proyectos/Public_Moc_Contract/scripts/deploy/upgrade_v0.1.12/deployConfig-rskMocMainnet2.json
BatchChanger Deploy at: 0x58933D29430b79780F54d1E97CB70eA9558360BE
Length Data:  26
Length Target:  26
OK! length of arrays
OK! STEP 0. MoC.sol [0xf773B590aF754D597770937Fa8ea7AbDf2668370] Upgrade to implementation [0x9965C3B0fDcb9145AdFd4C0535716b109F450f9F].
OK! STEP 1. MoCExchange.sol [0x6aCb83bB0281FB847b43cf7dd5e2766BFDF49038] Upgrade to implementation [0x36D1Dc7b41a18c2455ad7C3844a3C711712f6F14].
OK! STEP 2. MoCSettlement.sol [0x609dF03D8a85eAffE376189CA7834D4C35e32F22] Upgrade to implementation [0x3B5F29F815675902324727F194f6B3F39e8B05f9].
OK! STEP 3. CommissionSplitter.sol [0xa5467535851263122ef1476e24C529CFc6CFc086] Upgrade to implementation [0xc60b5050552e35B1af3026A44465c058B77861dc].
OK! STEP 4. MoCInrate.sol [0xc0f9B54c41E3d0587Ce0F7540738d8d649b0A3F3] Upgrade to implementation [0xE9B15be6e7Cd575B15a197DE6A536f39B32Ac918].
OK! STEP 5. MoCState.sol [0xb9C42EFc8ec54490a37cA91c423F7285Fa01e257] Upgrade to implementation [0x436930E882DFf853344275067235a0FfE5c1F112].
OK! STEP 6. Prepare moCSettlement.sol execute: [fixTasksPointer()]
OK! STEP 7. Prepare commissionSplitter.sol execute: [setMocToken(0x9AC7fE28967B30E3A4e6e03286d715b42B453D10)]
OK! STEP 8. Prepare commissionSplitter.sol execute: [setMocTokenCommissionAddress(0x7002dD3027947aB98cA3DDC28F93F2450281453A)]
OK! STEP 9. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(1, 1000000000000000)]
OK! STEP 10. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(2, 1000000000000000)]
OK! STEP 11. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(3, 1000000000000000)]
OK! STEP 12. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(4, 1000000000000000)]
OK! STEP 13. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(5, 1000000000000000)]
OK! STEP 14. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(6, 1000000000000000)]
OK! STEP 15. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(7, 500000000000000)]
OK! STEP 16. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(8, 500000000000000)]
OK! STEP 17. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(9, 500000000000000)]
OK! STEP 18. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(10, 500000000000000)]
OK! STEP 19. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(11, 500000000000000)]
OK! STEP 20. Prepare MoCInrate.sol execute: [setCommissionRateByTxType(12, 500000000000000)]
OK! STEP 21. Prepare moCState.sol execute: [setMoCPriceProvider(0x72835fDc4F73cb33b1E7e03bFe067AAfED2BDB9C)]
OK! STEP 22. Prepare moCState.sol execute: [setMoCToken(0x9AC7fE28967B30E3A4e6e03286d715b42B453D10)]
OK! STEP 23. Prepare moCState.sol execute: [setMoCVendors(0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA)]
OK! STEP 24. Prepare moCState.sol execute: [setLiquidationEnabled(false)]
OK! STEP 25. Prepare moCState.sol execute: [setProtected(1.5)]
```

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
|  MoCVendors  | [0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA](https://explorer.rsk.co/address/0x2d442aA5D391475b6Af3ad361eA3b9818fb35BcA) |
|  CommissionSplitter  | [0xa5467535851263122ef1476e24C529CFc6CFc086](https://explorer.rsk.co/address/0xa5467535851263122ef1476e24C529CFc6CFc086) |



**Implementations**

|  Contract  |  Address |  
|:---|:---|
|  MoCHelperLib  | [0x592b84710955C9561008D137a5403E1dd9A222D8](https://explorer.rsk.co/address/0x592b84710955C9561008D137a5403E1dd9A222D8) |
|  MoC  | [0x9965C3B0fDcb9145AdFd4C0535716b109F450f9F](https://explorer.rsk.co/address/0x9965C3B0fDcb9145AdFd4C0535716b109F450f9F?__ctab=general) |
|  MoCConnector  | [0x437221b50b0066186e58412b0ba940441a7b7df5](https://explorer.rsk.co/address/0x437221b50b0066186e58412b0ba940441a7b7df5?__ctab=general) |
|  MoCBProxManager  | [0xee35b51edf623533a83d3aef8f1518ff67da4e89](https://explorer.rsk.co/address/0xee35b51edf623533a83d3aef8f1518ff67da4e89) |
|  MoCSettlement  | [0x3B5F29F815675902324727F194f6B3F39e8B05f9](https://explorer.rsk.co/address/0x3B5F29F815675902324727F194f6B3F39e8B05f9?__ctab=general) |
|  MocState  | [0x436930E882DFf853344275067235a0FfE5c1F112](https://explorer.rsk.co/address/0x436930E882DFf853344275067235a0FfE5c1F112) |
|  MocExchange  | [0x36D1Dc7b41a18c2455ad7C3844a3C711712f6F14](https://explorer.rsk.co/address/0x36D1Dc7b41a18c2455ad7C3844a3C711712f6F14?__ctab=Code) |
|  MocInrate  | [0xE9B15be6e7Cd575B15a197DE6A536f39B32Ac918](https://explorer.rsk.co/address/0xE9B15be6e7Cd575B15a197DE6A536f39B32Ac918) |
|  MoCVendors  | [0x2C393B9484B1D15519031F14d9FafEb999A6A811](https://explorer.rsk.co/address/0x2C393B9484B1D15519031F14d9FafEb999A6A811) |
|  CommissionSplitter  | [0xc60b5050552e35B1af3026A44465c058B77861dc](https://explorer.rsk.co/address/0xc60b5050552e35B1af3026A44465c058B77861dc) |
|  MoCPriceProvider  | [0x72835fDc4F73cb33b1E7e03bFe067AAfED2BDB9C](https://explorer.rsk.co/address/0x72835fDc4F73cb33b1E7e03bFe067AAfED2BDB9C) |
|  MoCToken  | [0x9AC7fE28967B30E3A4e6e03286d715b42B453D10](https://explorer.rsk.co/address/0x9AC7fE28967B30E3A4e6e03286d715b42B453D10) |


