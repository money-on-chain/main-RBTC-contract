pragma solidity 0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MoCInrateRiskProRateChanger
 * with MoC --- governance.
 */
contract MoCInrateRiskProRateChanger is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  uint256 public newBitProRate;

  constructor(
    MoCInrate _mocInrate,
    uint256 _newBProRate
  ) public {
    mocInrate = _mocInrate;
    newBitProRate = _newBProRate;
  }

  function execute() external {
    mocInrate.setBitProRate(newBitProRate);
  }

  function setBitProRate(uint256 _newBitProRate) public onlyOwner(){
    newBitProRate = _newBitProRate;
  }

}
