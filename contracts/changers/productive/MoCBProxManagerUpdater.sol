pragma solidity ^0.5.8;
import "moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol";
import "../../MoCBProxManager.sol";
/**
 * @dev This contract is used to update the MoCBProxManager to fix the governor variable
 */
contract MoCBProxManagerUpdater is UpgraderTemplate {

  AdminUpgradeabilityProxy public proxy;
  UpgradeDelegator public upgradeDelegator;
  address public newImplementation;

  /**
    @dev Constructor
    @param _proxy Address of the proxy to be upgraded
    @param _upgradeDelegator Address of the upgradeDelegator in charge of that proxy
    @param _newImplementation Address of the contract the proxy will delegate to
  */
  constructor(AdminUpgradeabilityProxy _proxy, UpgradeDelegator _upgradeDelegator, address _newImplementation)
  public
  UpgraderTemplate(_proxy, _upgradeDelegator, _newImplementation){
  }

}
