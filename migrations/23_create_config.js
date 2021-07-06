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

  let filePath = `../scripts/deploy/upgrade_v0.1.12/deployConfig-${currentNetwork}.json`;
  let filePathCopy = `../scripts/deploy/upgrade_v0.1.12/deployConfig-${currentNetwork}-original.json`;
  filePath = path.join(__dirname, filePath);
  filePathCopy = path.join(__dirname, filePathCopy);
  console.log(`--- Saving deploy configuration to ${filePath} ---`);
  await saveConfig(filePath, allConfigs[currentNetwork]);
  console.log(`--- Saving copy of deploy configuration to ${filePathCopy} ---`);
  // Save a copy of the file to use for checking after new deploy
  return saveConfig(filePathCopy, allConfigs[currentNetwork]);
};
