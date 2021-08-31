#!/usr/bin/env bash
echo "Starting to flatten our contracts"
node_modules/.bin/truffle-flattener contracts/MoCHelperLib.sol > scripts/contract_flatten/MoCHelperLib_flat.sol
node_modules/.bin/truffle-flattener contracts/MoCVendors.sol > scripts/contract_flatten/MoCVendors_flat.sol
node_modules/.bin/truffle-flattener contracts/MoC.sol > scripts/contract_flatten/MoC_flat.sol
node_modules/.bin/truffle-flattener contracts/MoCExchange.sol > scripts/contract_flatten/MoCExchange_flat.sol
node_modules/.bin/truffle-flattener contracts/MoCSettlement.sol > scripts/contract_flatten/MoCSettlement_flat.sol
node_modules/.bin/truffle-flattener contracts/auxiliar/CommissionSplitter.sol > scripts/contract_flatten/CommissionSplitter_flat.sol
node_modules/.bin/truffle-flattener contracts/MoCInrate.sol > scripts/contract_flatten/MoCInrate_flat.sol
node_modules/.bin/truffle-flattener contracts/MoCState.sol > scripts/contract_flatten/MoCState_flat.sol
node_modules/.bin/truffle-flattener zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol > scripts/contract_flatten/AdminUpgradeabilityProxy_flat.sol
node_modules/.bin/truffle-flattener contracts/changers/MoCSettlementChanger.sol > scripts/contract_flatten/MoCSettlementChanger_flat.sol
node_modules/.bin/truffle-flattener contracts/changers/BatchChanger.sol > scripts/contract_flatten/BatchChanger_flat.sol
echo "Finish successfully! Take a look in folder scripts/contract_flatten/..."