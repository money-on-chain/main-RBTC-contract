pragma solidity 0.5.8;
import "moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol";
import "../../MoC.sol";
/**
 * @dev This contract is used to update the MoC to v019
 */
contract MoC_v019_Updater is UpgraderTemplate {

  AdminUpgradeabilityProxy public proxy;
  UpgradeDelegator public upgradeDelegator;
  address public newImplementation;

  /**
    @notice Constructor
    @param _proxy Address of the proxy to be upgraded
    @param _upgradeDelegator Address of the upgradeDelegator in charge of that proxy
    @param _newImplementation Address of the contract the proxy will delegate to
  */
  constructor(AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation)
  public
  UpgraderTemplate(_proxy, _upgradeDelegator, _newImplementation){
  }

}
