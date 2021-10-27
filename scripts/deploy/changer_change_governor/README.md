# Change current governor to new gobernanza

Deploy the batch changer

```js
cd scripts/deploy/changer_change_governor
export MNEMONIC=YOUR_PK
truffle exec 1_batch_changer.js --network rskMocMainnet2
```

Verification

```js
cd scripts/deploy/changer_change_governor.1.12
truffle exec 2_verification_changer.js --network rskMocMainnet2
```

return

```
Using network 'rskAlphaTestnet'.

Configuration path:  /home/martin/Proyectos/Public_Moc_Contract/scripts/deploy/changer_change_governor/deployConfig-rskAlphaTestnet.json
BatchChanger Deploy at: 0x070bB7a71649baD59379A855266b135D8Cd5dFf5
Length Data:  8
Length Target:  8
OK! length of arrays
OK! STEP 0. MoC.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 1. MoCBProxManager.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 2. MoCSettlement.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 3. MoCInrate.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 4. MoCState.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 5. MoCVendors.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 6. CommissionSplitter.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]
OK! STEP 7. UpgradeDelegator.sol : [ChangeIGovernor(0x7b716178771057195bB511f0B1F7198EEE62Bc22)]

```
