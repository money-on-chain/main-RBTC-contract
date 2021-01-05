const ProxyAdmin = artifacts.require('ProxyAdmin');
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
// Contracts to update
const Moc = artifacts.require('./MoC.sol');
const MoCExchange = artifacts.require('./MoCExchange.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCConverter = artifacts.require('./MoCConverter.sol');
const MoCState = artifacts.require('./MoCState.sol');

module.exports = async deployer => {
  // Get proxy addresses of every contract to upgrade (view shared document in Drive with addresses list)
  const proxyMoc = await AdminUpgradeabilityProxy.at('0x71d0921010CA8367835D34F7F3d215047E307581');
  const proxyMocExchange = await AdminUpgradeabilityProxy.at(
    '0x9516644aAFb05a13C97C575d1890aF2A50B8EE6A'
  );
  const proxyMocSettlement = await AdminUpgradeabilityProxy.at(
    '0xC7cC226Ed15A0a189e3Ea709028081Eb8BefcE46'
  );
  const proxyMocInrate = await AdminUpgradeabilityProxy.at(
    '0x3A11535315682780e096a3369E31dd84d9A32aF8'
  );
  const proxyMocConverter = await AdminUpgradeabilityProxy.at(
    '0xD266243a9C940B31f406720693e94af74d73CBcd'
  );
  const proxyMocState = await AdminUpgradeabilityProxy.at(
    '0x56b4A2ebcDA50a014F9a5f3D050C49B92badB81d'
  );

  // Upgrade delegator and Governor addresses (used to make changes to contracts)
  const upgradeDelegatorAddress = '0xc7393c6bcF99C526352174FD1bBD9bE9C25523Ef';
  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');

  // Deploy contracts implementation
  console.log("Deploying contracts implementations");
  console.log("- Deploy MoC");
  const moc = await deployer.deploy(Moc);
  console.log("- Deploy MoCExchange");
  const mocExchange = await deployer.deploy(MoCExchange);
  console.log("- Deploy MoCSettlement");
  const mocSettlement = await deployer.deploy(MoCSettlement);
  console.log("- Deploy MoCInrate");
  const mocInrate = await deployer.deploy(MoCInrate);
  console.log("- Deploy MoCConverter");
  const mocConverter = await deployer.deploy(MoCConverter);
  console.log("- Deploy MoCState");
  const mocState = await deployer.deploy(MoCState);

  // Upgrade contracts with proxy (using the contract address of contracts just deployed)
  console.log("Upgrading contracts");
  console.log("- Upgrade MoC");
  const upgradeMoc = await deployer.deploy(UpgraderChanger, proxyMoc.address, upgradeDelegatorAddress, moc.address);
  console.log("- Upgrade MoCExchange");
  const upgradeMocExchange = await deployer.deploy(UpgraderChanger, proxyMocExchange.address, upgradeDelegatorAddress, mocExchange.address);
  console.log("- Upgrade MoCSettlement");
  const upgradeMocSettlement = await deployer.deploy(UpgraderChanger, proxyMocSettlement.address, upgradeDelegatorAddress, mocSettlement.address);
  console.log("- Upgrade MoCInrate");
  const upgradeMocInrate = await deployer.deploy(UpgraderChanger, proxyMocInrate.address, upgradeDelegatorAddress, mocInrate.address);
  console.log("- Upgrade MoCConverter");
  const upgradeMocConverter = await deployer.deploy(UpgraderChanger, proxyMocConverter.address, upgradeDelegatorAddress, mocConverter.address);
  console.log("- Upgrade MoCState");
  const upgradeMocState = await deployer.deploy(UpgraderChanger, proxyMocState.address, upgradeDelegatorAddress, mocState.address);

  // Execute changes in contracts
  console.log("Execute change - MoC");
  await governor.executeChange(upgradeMoc.address);
  console.log("Execute change - MoCExchange");
  await governor.executeChange(upgradeMocExchange.address);
  console.log("Execute change - MoCSettlement");
  await governor.executeChange(upgradeMocSettlement.address);
  console.log("Execute change - MoCInrate");
  await governor.executeChange(upgradeMocInrate.address);
  console.log("Execute change - MoCConverter");
  await governor.executeChange(upgradeMocConverter.address);
  console.log("Execute change - MoCState");
  await governor.executeChange(upgradeMocState.address);
};
