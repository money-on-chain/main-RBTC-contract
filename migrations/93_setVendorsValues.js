const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCVendorsChangerHarness = artifacts.require('MoCVendorsChangerHarness.sol');
const MoCVendors = artifacts.require('MoCVendors.sol');

module.exports = async deployer => {
  const mocVendors = await MoCVendors.at('');

  const mocVendorsChangerHarness = await MoCVendorsChangerHarness.new(
    mocVendors.address
  );

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');
  // Execute changes in MoCVendors
  // (set vendors to register/unregister arrays to dynamic array of size 0)
  await governor.executeChange(mocVendorsChangerHarness.address);
};
