pragma solidity ^0.5.8;
import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MocInrate v017
 * with MoC --- governance.
 */
contract MocInrateBitProInterestChanger is ChangeContract, Ownable{
  MoCInrate private mocInrate;
  uint256 public bitProInterestBlockSpan;

  constructor(
    MoCInrate _mocInrate,
    uint256 _bProIntBlockSpan
  ) public {
    mocInrate = _mocInrate;
    bitProInterestBlockSpan = _bProIntBlockSpan;
  }

  function execute() external {
    mocInrate.setBitProInterestBlockSpan(bitProInterestBlockSpan);
  }

  function setBitProInterestBlockSpan(uint256 _bitProInterestBlockSpan) public onlyOwner(){
    bitProInterestBlockSpan = _bitProInterestBlockSpan;
  }

}
