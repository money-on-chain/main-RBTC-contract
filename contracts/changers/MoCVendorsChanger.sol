pragma solidity 0.5.8;
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
  address public vendorMoCDepositAddress;
  uint256 public vendorRequiredMoCs;

  constructor(
    MoCVendors _mocVendors,
    address _vendorMoCDepositAddress,
    uint256 _vendorRequiredMoCs
  ) public {
    mocVendors = _mocVendors;
    setVendorMoCDepositAddressInternal(_vendorMoCDepositAddress);
    setVendorRequiredMoCsInternal(_vendorRequiredMoCs);
  }

  function execute() external {
    mocVendors.setVendorMoCDepositAddress(vendorMoCDepositAddress);
    mocVendors.setVendorRequiredMoCs(vendorRequiredMoCs);
  }

  /**
    @dev Sets the address which will receive the initial amount of MoC required for a vendor to register.
    @param _vendorMoCDepositAddress Address which will receive the initial MoC required for a vendor to register.
  */
  function setVendorMoCDepositAddress(address _vendorMoCDepositAddress) public onlyOwner() {
    setVendorMoCDepositAddressInternal(_vendorMoCDepositAddress);
  }

  /**
    @dev Sets the initial amount of MoC required for a vendor to register.
    @param _vendorRequiredMoCs Initial amount of MoC required for a vendor to register.
  */
  function setVendorRequiredMoCs(uint256 _vendorRequiredMoCs) public onlyOwner() {
    setVendorRequiredMoCsInternal(_vendorRequiredMoCs);
  }

  function setVendorMoCDepositAddressInternal(address _vendorMoCDepositAddress) internal {
    vendorMoCDepositAddress = _vendorMoCDepositAddress;
  }

  function setVendorRequiredMoCsInternal(uint256 _vendorRequiredMoCs) internal {
    vendorRequiredMoCs = _vendorRequiredMoCs;
  }
}