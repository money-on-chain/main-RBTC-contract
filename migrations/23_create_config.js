/* eslint-disable no-console */
const path = require('path');
const utils = require('./utils');
const allConfigs = require('./configs/config');

module.exports = async (deployer, currentNetwork, [owner]) => {
  const { saveConfig } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );

  let filePath = `../scripts/deploy/20210308/deployConfig-${currentNetwork}.json`;
  filePath = path.join(__dirname, filePath);
  console.log(`--- Saving deploy configuration to ${filePath} ---`);
  return saveConfig(filePath, allConfigs[currentNetwork]);
};
