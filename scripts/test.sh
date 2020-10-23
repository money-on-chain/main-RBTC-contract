#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

if [ "$SOLIDITY_COVERAGE" = true ]; then
  ganache_port=8555
else
  ganache_port=8545
fi

ganache_running() {
  nc -z localhost "$ganache_port"
}

start_ganache() {
  # Gas Limit on RSK TestNet 03 July 2019: 6800000 - 0x67C280
  if [ "$SOLIDITY_COVERAGE" = true ]; then
    touch allFiredEvents
    node_modules/.bin/testrpc-sc --gasLimit 0xfffffffffff --port "$ganache_port" -i 1564754684494 --accounts 500 --defaultBalanceEther 100000000000000000 > /dev/null &
  else
    node_modules/.bin/ganache-cli --gasLimit 0xfffffffffff -i 1564754684494 --accounts 500 --defaultBalanceEther 100000000000000000 > /dev/null &
  fi

  ganache_pid=$!
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

truffle version

if [ "$SOLIDITY_COVERAGE" = true ]; then
  node_modules/.bin/solidity-coverage
else
  node_modules/.bin/truffle test "$@"
fi
