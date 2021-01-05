const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCVendorsChangerHarness = artifacts.require('MoCVendorsChangerHarness.sol');
const MoCVendors = artifacts.require('MoCVendors.sol');

module.exports = async deployer => {
  // Get deployed contract from artifact
  const mocVendors = await MoCVendors.deployed();
  // If script fails, use const mocVendors = await MoCVendors.at('<address>');

  const mocVendorsChangerHarness = await MoCVendorsChangerHarness.new(
    mocVendors.address
  );

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');

  // Add new vendor
  const vendor = [{
    address: '0x9032F510A5B54A005f04e81B5C98B7f201C4daC1',
    markup: '10000000000000000000'
  }];
  console.log("vendor: ", vendor);

  // Set changer contract
  await this.mocVendorsChangerHarness.setVendorsToRegister(vendor);
  await this.mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();

  // Execute changes
  await governor.executeChange(mocVendorsChangerHarness.address);
};
