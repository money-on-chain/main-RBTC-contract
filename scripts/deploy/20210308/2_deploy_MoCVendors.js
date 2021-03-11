/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCVendors = artifacts.require('./MoCVendors.sol');

const { getConfig, getNetwork, saveConfig, shouldExecuteChanges } = require('./helper');

module.exports = async callback => {
  try {
    const network = getNetwork(process.argv);
    const config = getConfig(network);

    // Deploy new MoCVendors implementation
    const mocVendors = await MoCVendors.new();

    // Save implementation address to config file
    config.implementationAddresses.MoCVendors = mocVendors.address;
    saveConfig(network, config);

    // Initialize contract
    const initData = await mocVendors.contract.methods
      .initialize(
        config.proxyAddresses.MoCVendors,
        config.implementationAddresses.Governor,
        config.valuesToAssign.vendorMoCDepositAddress,
        config.valuesToAssign.vendorRequiredMoCs
      )
      .encodeABI();
    console.log('MoCVendors Initialized');

    const proxyMocVendors = await AdminUpgradeabilityProxy.new(
      mocVendors.address,
      config.implementationAddresses.ProxyAdmin,
      initData
    );

    // Save proxy address to config file
    config.proxyAddresses.MoCVendors = proxyMocVendors.address;
    saveConfig(network, config);

    console.log('MoCVendors proxy address: ', proxyMocVendors.address);
    console.log('MoCVendors implementation address: ', mocVendors.address);

    /*
      COMMENT LINES 16-44 IN CASE OF UPGRADE OF MoCVendors
      UNCOMMENT LINES 50-74 IN CASE OF UPGRADE OF MoCVendors
    */
    // // Deploy contract implementation
    // console.log('Deploy MoCVendors');
    // const mocVendors = await MoCVendors.new();

    // // Upgrade contracts with proxy (using the contract address of contract just deployed)
    // console.log('Upgrade MoCVendors');
    // const upgradeMocVendors = await UpgraderChanger.new(
    //   config.proxyAddresses.MoCVendors,
    //   config.implementationAddresses.UpgradeDelegator,
    //   mocVendors.address
    // );

    // // Save implementation address and changer address to config file
    // config.implementationAddresses.MoCVendors = mocVendors.address;
    // config.changerAddresses['2_MoCVendors'] = upgradeMocVendors.address;
    // saveConfig(network, config);

    // if (shouldExecuteChanges(network)) {
    //   // Execute changes in contracts
    //   console.log('Execute change - MoCVendors');
    //   const governor = await Governor.at(config.implementationAddresses.Governor);
    //   await governor.executeChange(upgradeMocVendors.address);
    // }

    // console.log('MoCVendors implementation address: ', mocVendors.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
