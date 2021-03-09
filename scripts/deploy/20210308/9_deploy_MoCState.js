/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCState = artifacts.require('./MoCState.sol');
const MoCStateChangerDeploy = artifacts.require('./MoCStateChangerDeploy.sol');

const deployConfig = require('./deployConfig.json');

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocState = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCState
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCState');
    const mocState = await deployer.deploy(MoCState);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCState');
    const upgradeMocState = await deployer.deploy(
      UpgraderChanger,
      proxyMocState.address,
      upgradeDelegatorAddress,
      mocState.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCState');
    await governor.executeChange(upgradeMocState.address);

    // Use changer contract
    const mocStateChangerDeploy = await MoCStateChangerDeploy.new(
      deployConfig[currentNetwork].addresses.MoCPriceProvider,
      deployConfig[currentNetwork].addresses.MoCToken,
      deployConfig[currentNetwork].addresses.MoCVendorsAddress, // NEWLY DEPLOYED
      deployConfig[currentNetwork].valuesToAssign.liquidationEnabled,
      deployConfig[currentNetwork].valuesToAssign.protected,
      { from: owner }
    );

    // Execute changes in MoCState
    console.log('Execute change - MoCStateChangerDeploy');
    await governor.executeChange(mocStateChangerDeploy.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
