const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCVendorsChangerHarness = artifacts.require('MoCVendorsChangerHarness.sol');
const MoCVendors = artifacts.require('MoCVendors.sol');

module.exports = async deployer => {
  // Get deployed contract from artifact
  const mocVendors = await MoCVendors.deployed();
  console.log("MoCVendors address: ", mocVendors.address);
  // If script fails, use const mocVendors = await MoCVendors.at('<address>');

  const mocVendorsChangerHarness = await MoCVendorsChangerHarness.new(
    mocVendors.address
  );

  console.log("MoCVendorsChangerHarness instanced");

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');

  // Add new vendor
  const vendor = [{
    account: '0x9032f510a5b54a005f04e81b5c98b7f201c4dac1',
    markup: '10000000000000000'
  }];
  // Vendor account address in to lower because of checksum
  console.log("vendor: ", vendor);

  // Set changer contract
  await mocVendorsChangerHarness.setVendorsToRegister(vendor);
  await mocVendorsChangerHarness.setVendorsToUnregisterEmptyArray();

  // Execute changes
  console.log("Executing changes");
  await governor.executeChange(mocVendorsChangerHarness.address);
};
