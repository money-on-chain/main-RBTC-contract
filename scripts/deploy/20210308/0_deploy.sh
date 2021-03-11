#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

NETWORK=$1

if [[ -z "$NETWORK" ]]; then
    NETWORK="development"
fi

echo "Using network '$NETWORK'"

SCRIPTS="
1_deploy_MoCLib.js
2_deploy_MoCVendors.js
3_deploy_MoCConnector.js
4_deploy_MoC.js
5_deploy_MoCExchange.js
6_deploy_MoCSettlement.js
7_deploy_MoCInrate.js
8_deploy_MoCConverter.js
9_deploy_MoCState.js
"

for S in $SCRIPTS; do
    echo "------------------------------------------------------------"
    echo "Running: $S"
    truffle exec $DIR/$S --network $NETWORK
    echo "------------------------------------------------------------"
done
