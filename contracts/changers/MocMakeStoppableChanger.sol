pragma solidity ^0.5.8;
import "moc-governance/contracts/Governance/IGovernor.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../MoC.sol";

/**
 * @dev This contract is used to update the configuration of MoC
 * with MoC --- governance.
 */
contract MocMakeStoppableChanger is ChangeContract, Ownable{
  MoC public moc;
  bool public isStoppable;

  constructor(MoC _moc, bool _isStoppable) public {
    moc = _moc;
    isStoppable = _isStoppable;
  }

  function execute() external {
    if (!isStoppable){
      moc.makeUnstoppable();
    }
    else{
      moc.makeStoppable();
    }
  }

  function setStoppable(bool _stoppable) public onlyOwner() {
    isStoppable = _stoppable;
  }
}

