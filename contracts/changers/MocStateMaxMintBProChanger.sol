pragma solidity ^0.5.8;
import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCState v017
 * with MoC --- governance.
 */
contract MocStateMaxMintBProChanger is ChangeContract, Ownable{
  MoCState public mocState;
  uint256 public maxMintBPro;

  constructor(
    MoCState _mocState,
    uint256 _maxMintBPro
  ) public {
    mocState = _mocState;
    maxMintBPro = _maxMintBPro;
  }

  function execute() external {
    mocState.setMaxMintBPro(maxMintBPro);
  }

  function setMaxMintBPro(uint256 _maxMintBPro) public onlyOwner() {
    maxMintBPro = _maxMintBPro;
  }


}
