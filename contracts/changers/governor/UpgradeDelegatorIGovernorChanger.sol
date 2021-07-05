pragma solidity 0.5.8;
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "moc-governance/contracts/Upgradeability/UpgradeDelegator.sol";

/**
 * @dev This contract is used to update the configuration
 * with MoC --- governance.
 */
contract UpgradeDelegatorIGovernorChanger is ChangeContract {
  UpgradeDelegator public upgradeDelegator;
  IGovernor public newGovernor;

  constructor(
    UpgradeDelegator _upgradeDelegator,
    IGovernor _newGovernor
  ) public {
    upgradeDelegator = _upgradeDelegator;
    newGovernor = _newGovernor;
  }

  function execute() external {
    upgradeDelegator.changeIGovernor(newGovernor);
  }

}
