pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../MoCVendors.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCVendors
 * with MoC --- governance.
 */
contract MoCVendorsChanger is ChangeContract, Ownable {
  MoCVendors private mocVendors;
  address public vendorGuardianAddress;

  constructor(
    MoCVendors _mocVendors,
    address _vendorGuardianAddress
  ) public {
    mocVendors = _mocVendors;
    setVendorGuardianAddressInternal(_vendorGuardianAddress);
  }

  function execute() external {
    mocVendors.setVendorGuardianAddress(vendorGuardianAddress);
  }

  /**
    @dev Sets the address which will be authorized to register and unregister vendors.
    @param _vendorGuardianAddress Address which will be authorized to register and unregister vendors.
  */
  function setVendorGuardianAddress(address _vendorGuardianAddress) public onlyOwner() {
    setVendorGuardianAddressInternal(_vendorGuardianAddress);
  }

  function setVendorGuardianAddressInternal(address _vendorGuardianAddress) internal {
    require(_vendorGuardianAddress != address(0), "vendorGuardianAddress must not be 0x0");
    vendorGuardianAddress = _vendorGuardianAddress;
  }
}