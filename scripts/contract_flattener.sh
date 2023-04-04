#!/usr/bin/env bash

FLATTENER="/usr/bin/env python3 scripts/flattener.py"
OUTPUTDIR="scripts/contract_flatten/"
CONTRACTS=(
    "contracts/MoCHelperLib.sol"
    "contracts/MoCVendors.sol"
    "contracts/MoC.sol"
    "contracts/MoCExchange.sol"
    "contracts/MoCSettlement.sol"
    "contracts/auxiliar/CommissionSplitter.sol"
    "contracts/auxiliar/CommissionSplitterV2.sol"
    "contracts/auxiliar/CommissionSplitterV3.sol"
    "contracts/MoCInrate.sol"
    "contracts/MoCState.sol"
    "contracts/changers/MoCSettlementChanger.sol"
    "contracts/changers/proposal_fee_increase/FeeIncreaseProposal.sol"
    "contracts/changers/BatchChanger.sol"
    "contracts/changers/UpgraderChanger.sol"
    "zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol"
)

# Working directory: the root of the project
cd "$(dirname "$0")/.."

echo "Starting to flatten our contracts"

# Iterate the contract list 
for CONTRACT in "${CONTRACTS[@]}"; do

    echo File: $(basename "$CONTRACT")

    # Output file
    OUTPUTFILE=$OUTPUTDIR$(basename "$CONTRACT" .sol)_flat.sol

    # Flattener...
    $FLATTENER $CONTRACT > $OUTPUTFILE

done

echo "Finished! Take a look into folder $OUTPUTDIR..."
