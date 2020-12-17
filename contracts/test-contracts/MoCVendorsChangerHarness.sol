pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

import "../../contracts/changers/MoCVendorsChanger.sol";

contract MoCVendorsChangerHarness is MoCVendorsChanger {
  constructor(MoCVendors _mocVendors)
    MoCVendorsChanger(
      _mocVendors,
      new MoCVendorsChanger.VendorToRegister[](0),
      new address[](0))
  public {}

  function setVendorsToRegisterEmptyArray() public onlyOwner(){
    MoCVendorsChanger.VendorToRegister[] memory _vendorsToRegister = new MoCVendorsChanger.VendorToRegister[](0);
    setVendorsToRegisterInternal(_vendorsToRegister);
  }

  function setVendorsToUnregisterEmptyArray() public onlyOwner(){
    address[] memory _vendorsToUnregister = new address[](0);
    setVendorsToUnregisterInternal(_vendorsToUnregister);
  }
}