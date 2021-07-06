pragma solidity ^0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MocInrate Btcx interst
 * with MoC --- governance.
 */
contract MocInrateBtcxInterestChanger is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  uint256 public btxcTmin;
  uint256 public btxcTmax;
  uint256 public btxcPower;

  constructor(
    MoCInrate _mocInrate,
    uint256 _btxcTmin,
    uint256 _btxcTmax,
    uint256 _btxcPower
  ) public {
    mocInrate = _mocInrate;
    btxcTmin = _btxcTmin;
    btxcTmax = _btxcTmax;
    btxcPower = _btxcPower;
  }

  function execute() external {
    mocInrate.setBtcxTmin(btxcTmin);
    mocInrate.setBtcxTmax(btxcTmax);
    mocInrate.setBtcxPower(btxcPower);
  }

  function setBtcxTmin(uint256 _btxcTmin) public onlyOwner(){
    btxcTmin = _btxcTmin;
  }

  function setBtcxTmax(uint256 _btxcTmax) public onlyOwner(){
    btxcTmax = _btxcTmax;
  }

  function setBtcxPower(uint256 _btxcPower) public onlyOwner(){
    btxcPower = _btxcPower;
  }

}
