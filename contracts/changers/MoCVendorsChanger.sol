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
  uint8 public constant VENDORS_TO_REGISTER_ARRAY_MAX_LENGTH = 100;
  uint8 public constant VENDORS_TO_UNREGISTER_ARRAY_MAX_LENGTH = 100;

  MoCVendors private mocVendors;
  VendorToRegister[] private vendorsToRegister;
  address[] private vendorsToUnregister;

  struct VendorToRegister{
    address account;
    uint256 markup;
  }

  constructor(
    MoCVendors _mocVendors,
    VendorToRegister[] memory _vendorsToRegister,
    address[] memory _vendorsToUnregister
  ) public {
    mocVendors = _mocVendors;
    setVendorsToRegisterInternal(_vendorsToRegister);
    setVendorsToUnregisterInternal(_vendorsToUnregister);
  }

  function execute() external {
    initializeVendorsToRegister();
    initializeVendorsToUnregister();
  }

  function setVendorsToRegister(VendorToRegister[] memory _vendorsToRegister) public onlyOwner(){
    setVendorsToRegisterInternal(_vendorsToRegister);
  }

  function setVendorsToUnregister(address[] memory _vendorsToUnregister) public onlyOwner(){
    setVendorsToUnregisterInternal(_vendorsToUnregister);
  }

  /**
    @dev initializes the vendors to register in the MoCVendors contract
  */
  function initializeVendorsToRegister() internal {
    // Change the error message according to the value of the VENDORS_TO_REGISTER_ARRAY_MAX_LENGTH constant
    require(vendorsToRegister.length <= VENDORS_TO_REGISTER_ARRAY_MAX_LENGTH, "vendorsToRegister length must be between 1 and 100");

    for (uint256 i = 0; i < vendorsToRegister.length; i++) {
      mocVendors.registerVendor(vendorsToRegister[i].account, vendorsToRegister[i].markup);
    }
  }

  function setVendorsToRegisterInternal(VendorToRegister[] memory _vendorsToRegister) internal {
    // Change the error message according to the value of the VENDORS_TO_REGISTER_ARRAY_MAX_LENGTH constant
    require(_vendorsToRegister.length <= VENDORS_TO_REGISTER_ARRAY_MAX_LENGTH, "vendorsToRegister length must be between 1 and 100");

    delete vendorsToRegister;

    for (uint256 i = 0; i < _vendorsToRegister.length; i++){
      vendorsToRegister.push(_vendorsToRegister[i]);
    }
  }

  /**
    @dev initializes the vendors to unregister in the MoCVendors contract
  */
  function initializeVendorsToUnregister() internal {
    // Change the error message according to the value of the VENDORS_TO_UNREGISTER_ARRAY_MAX_LENGTH constant
    require(vendorsToUnregister.length <= VENDORS_TO_UNREGISTER_ARRAY_MAX_LENGTH, "vendorsToUnregister length must be between 1 and 100");

    for (uint256 i = 0; i < vendorsToUnregister.length; i++) {
      mocVendors.unregisterVendor(vendorsToUnregister[i]);
    }
  }

  function setVendorsToUnregisterInternal(address[] memory _vendorsToUnregister) internal {
    // Change the error message according to the value of the VENDORS_TO_UNREGISTER_ARRAY_MAX_LENGTH constant
    require(_vendorsToUnregister.length <= VENDORS_TO_UNREGISTER_ARRAY_MAX_LENGTH, "vendorsToUnregister length must be between 1 and 100");

    delete vendorsToUnregister;

    for (uint256 i = 0; i < _vendorsToUnregister.length; i++){
      vendorsToUnregister.push(_vendorsToUnregister[i]);
    }
  }
}