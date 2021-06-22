pragma solidity ^0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MocInrate v017
 * with MoC --- governance.
 */
contract MocInrateChanger_v019 is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  uint256 public bitProInterestBlockSpan;
  uint256 public btxcTmin;
  uint256 public btxcTmax;
  uint256 public btxcPower;
  uint256 public newBitProRate;
  uint256 public newCommissionRate;
  address payable public newBitProInterestAddress;
  address payable public newCommissionsAddress;
  uint256 public docTmin;
  uint256 public docTmax;
  uint256 public docPower;

  constructor(
    MoCInrate _mocInrate,
    uint256 _bProIntBlockSpan,
    uint256 _btxcTmin,
    uint256 _btxcTmax,
    uint256 _btxcPower,
    uint256 _newBProRate,
    uint256 _newComRate,
    uint256 _docTmin,
    uint256 _docTmax,
    uint256 _docPower
  ) public {
    mocInrate = _mocInrate;
    bitProInterestBlockSpan = _bProIntBlockSpan;
    btxcTmin = _btxcTmin;
    btxcTmax = _btxcTmax;
    btxcPower = _btxcPower;
    newBitProRate = _newBProRate;
    newCommissionRate = _newComRate;
    docTmin = _docTmin;
    docTmax = _docTmax;
    docPower = _docPower;
  }

  function execute() external {
    mocInrate.setBitProInterestBlockSpan(bitProInterestBlockSpan);
    mocInrate.setBtcxTmin(btxcTmin);
    mocInrate.setBtcxTmax(btxcTmax);
    mocInrate.setBtcxPower(btxcPower);

    mocInrate.setBitProRate(newBitProRate);
    if (address(0) != newCommissionsAddress){
      mocInrate.setCommissionsAddress(newCommissionsAddress);
    }
    if (address(0) != newBitProInterestAddress){
      mocInrate.setBitProInterestAddress(newBitProInterestAddress);
    }

    mocInrate.setCommissionRate(newCommissionRate);

    mocInrate.setDoCTmin(docTmin);
    mocInrate.setDoCTmax(docTmax);
    mocInrate.setDoCPower(docPower);
  }

  function setBitProInterestBlockSpan(uint256 _bitProInterestBlockSpan) public onlyOwner(){
    bitProInterestBlockSpan = _bitProInterestBlockSpan;
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

  function setBitProInterestAddress(address payable _newBitProInterestAddress) public onlyOwner(){
    newBitProInterestAddress = _newBitProInterestAddress;
  }

  function setBitProRate(uint256 _newBitProRate) public onlyOwner(){
    newBitProRate = _newBitProRate;
  }

  function setCommissionsAddress(address payable _newCommissionsAddress) public onlyOwner(){
    newCommissionsAddress = _newCommissionsAddress;
  }

  function setCommissionRate(uint256 _newCommissionRate) public onlyOwner(){
    newCommissionRate = _newCommissionRate;
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
