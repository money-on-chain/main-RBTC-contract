const MoCLib = artifacts.require('./MoCHelperLib.sol');
const Moc = artifacts.require('./MoC.sol');
const MoCExchange = artifacts.require('./MoCExchange.sol');
const ProxyAdmin = artifacts.require('ProxyAdmin');
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');


module.exports = async deployer => {
  const mocLib = await MoCLib.at('0x71811394c7Fb1C4cbF9D25970A0f7001E58Cf55F');
  const proxyAdmin = await ProxyAdmin.at('0x03cE6B189F63563BFfA070f9E1768413CE1D0f36');
  const proxyMoc = await AdminUpgradeabilityProxy.at('0x71d0921010CA8367835D34F7F3d215047E307581');
  const proxyMocExchange = await AdminUpgradeabilityProxy.at(
    '0x9516644aAFb05a13C97C575d1890aF2A50B8EE6A'
  );
  const upgradeDelegatorAddress = '0xc7393c6bcF99C526352174FD1bBD9bE9C25523Ef';
  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');

  console.log("Linking library");
  //await Moc.link('MoCHelperLib', mocLib.address);
  //await MoCExchange.link('MoCHelperLib', mocLib.address);

  console.log("Deploying contracts");
  //const moc = await deployer.deploy(Moc);
  //const mocExchange = await deployer.deploy(MoCExchange);

  console.log("Upgrading contracts");
  console.log("- Upgrade MoC");
  const upgradeMoc = await deployer.deploy(UpgraderChanger, proxyMoc.address, upgradeDelegatorAddress, '0xAAa75F81CBa0A1c38202E6ACA49D6627b8CA23ef');
  console.log("- Upgrade MoCExchange");
  const upgradeMocExchange = await deployer.deploy(UpgraderChanger, proxyMocExchange.address, upgradeDelegatorAddress, '0x3135A008f8D95A02A76b0f65D6D4077a47eCb519');

  // buscar address governor
  // instanciar governor
  // governor execute changes upgradeMoc
  console.log("Execute change - MoC");
  await governor.executeChange(upgradeMoc.address);
  // governor upgradeMocExchange
  console.log("Execute change - MoCExchange");
  await governor.executeChange(upgradeMocExchange.address);
};
