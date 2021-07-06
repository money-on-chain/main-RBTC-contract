pragma solidity ^0.5.8;
import "moc-governance/contracts/Governance/IGovernor.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../MoC.sol";

/**
 * @dev This contract is used to update the configuration of MoC
 * with MoC --- governance.
 */
contract MocChanger is ChangeContract, Ownable{
  MoC public moc;
  address public governor;
  address public stopper;
  bool public isStoppable;

  constructor(MoC _moc, address _governor, address _stopper) public {
    moc = _moc;
    isStoppable = true;
    governor = _governor;
    stopper = _stopper;
  }

  function execute() external {
    moc.setStopper(stopper);
    moc.changeIGovernor(IGovernor(governor));
    if (!isStoppable){
      moc.makeUnstoppable();
    }
    else{
      moc.makeStoppable();
    }
  }

  function setGovernor(address _governor) public onlyOwner(){
    governor = _governor;
  }

  function setStopper(address _stopper) public onlyOwner(){
    stopper = _stopper;
  }

  function setStoppable(bool _stoppable) public onlyOwner() {
    isStoppable = _stoppable;
  }
}

