#!/usr/bin/env bash

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
  node_modules/.bin/ganache-cli --gasLimit 0xfffffffffff -i 1564754684494 --accounts 500 --defaultBalanceEther 100000000000000000 --port $GANACHE_PORT

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
