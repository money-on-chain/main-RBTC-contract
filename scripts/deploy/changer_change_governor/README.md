# Change current governor to new gobernanza

Deploy the batch changer

```js
cd scripts/deploy/changer_change_governor
export MNEMONIC=YOUR_PK
truffle exec 1_batch_changer.js --network rskMocMainnet2
```

Verification

```js
cd scripts/deploy/changer_change_governor
truffle exec 2_verification_changer.js --network rskMocMainnet2
```

return

```
martin@martin-desktop:~/Proyectos/Public_Moc_Contract/scripts/deploy/changer_change_governor$ truffle exec 2_verification_changer.js --network rskMocMainnet2
Using network 'rskMocMainnet2'.

Configuration path:  /home/martin/Proyectos/Public_Moc_Contract/scripts/deploy/changer_change_governor/deployConfig-rskMocMainnet2.json
BatchChanger Deploy at: 0x457895c086c67D575Ce147Ed21b8441d367D3DAa
Length Data:  8
Length Target:  8
OK! length of arrays
OK! STEP 0. MoC.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 1. MoCBProxManager.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 2. MoCSettlement.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 3. MoCInrate.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 4. MoCState.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 5. MoCVendors.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 6. CommissionSplitter.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
OK! STEP 7. UpgradeDelegator.sol : [ChangeIGovernor(0x3b8853DF65AfBd94853E6D77ee0Ab5590F41bB08)]
```
