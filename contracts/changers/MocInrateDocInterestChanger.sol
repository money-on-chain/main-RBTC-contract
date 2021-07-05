pragma solidity ^0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MocInrate Doc Interest
 * with MoC --- governance.
 */
contract MocInrateDocInterestChanger is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  uint256 public docTmin;
  uint256 public docTmax;
  uint256 public docPower;

  constructor(
    MoCInrate _mocInrate,
    uint256 _docTmin,
    uint256 _docTmax,
    uint256 _docPower
  ) public {
    mocInrate = _mocInrate;
    docTmin = _docTmin;
    docTmax = _docTmax;
    docPower = _docPower;
  }

  function execute() external {
    mocInrate.setDoCTmin(docTmin);
    mocInrate.setDoCTmax(docTmax);
    mocInrate.setDoCPower(docPower);
  }

  function setDoCTmin(uint256 _docTmin) public onlyOwner(){
    docTmin = _docTmin;
  }

  function setDoCTmax(uint256 _docTmax) public onlyOwner(){
    docTmax = _docTmax;
  }

  function setDoCPower(uint256 _docPower) public onlyOwner(){
    docPower = _docPower;
  }

}
