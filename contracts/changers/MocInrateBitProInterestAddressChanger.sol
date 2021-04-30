pragma solidity 0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MocInrate
 * with MoC --- governance.
 */
contract MocInrateBitProInterestAddressChanger is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  address payable public newBitProInterestAddress;

  constructor(
    MoCInrate _mocInrate,
    address payable _newBitProInterestAddress
  ) public {
    mocInrate = _mocInrate;
    newBitProInterestAddress = _newBitProInterestAddress;
  }

  function execute() external {
    mocInrate.setBitProInterestAddress(newBitProInterestAddress);
  }

  function setBitProInterestAddress(address payable _newBitProInterestAddress) public onlyOwner(){
    newBitProInterestAddress = _newBitProInterestAddress;
  }

}
