#!/usr/bin/env bash

NODO_DIRECTORY="${HOME}/nodo-dir/money-on-chain/"
GANACHE_PORT=8545

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

ganache_running() {
  nc -z localhost "$GANACHE_PORT"
}

start_ganache() {
  if [ ! -d "$NODO_DIRECTORY" ]; then
    mkdir -p "$NODO_DIRECTORY"
  fi

  node_modules/.bin/ganache-cli --db "$NODO_DIRECTORY" --gasLimit 0xfffffffffff --accounts 500 -i 1564754684494 --port $GANACHE_PORT --defaultBalanceEther 100000000000000000

  ganache_pid=$!
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

ganache-cli --version
truffle version
