/* eslint-disable no-console */
/* eslint-disable func-names */

const fs = require('fs');

const getConfig = (network, path) => {
  console.log('Configuration path: ', path);
  let config;

  if (fs.existsSync(path)) {
    const rawdata = fs.readFileSync(path);
    config = JSON.parse(rawdata);
  } else {
    throw new Error(`Missing configuration for network '${network}'.`);
  }
  return config;
};

const getNetwork = processArgs => {
  let network = 'development';
  for (let i = 0; i < processArgs.length; i++) {
    if (processArgs[i] === '--network') {
      network = processArgs[i + 1];
      break;
    }
  }
  return network;
};

const saveConfig = (config, path) => {
  // console.log('saveConfig path: ', path);
  fs.writeFileSync(path, JSON.stringify(config, null, 2));
};

const shouldExecuteChanges = currentNetwork =>
  currentNetwork === 'development' ||
  currentNetwork === 'coverage' ||
  currentNetwork === 'regtest' ||
  currentNetwork === 'prueba';

module.exports = {
  getConfig,
  getNetwork,
  saveConfig,
  shouldExecuteChanges
};
