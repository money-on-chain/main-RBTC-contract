pragma solidity 0.5.8;
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration
 * with MoC --- governance.
 */
contract ProxyAdminIGovernorChanger is ChangeContract, Ownable {
  Governed private mocContract;
  IGovernor public newGovernor;

  constructor(
    Governed _mocContract,
    IGovernor _newGovernor
  ) public {
    mocContract = _mocContract;
    newGovernor = _newGovernor;
  }

  function execute() external {
    mocContract.changeIGovernor(newGovernor);
  }

}