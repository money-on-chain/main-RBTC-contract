pragma solidity ^0.5.8;

import "zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "moc-governance/contracts/Upgradeability/UpgradeDelegator.sol";
import "../MoC.sol";

/**
  @title MaxGasPriceChanger
  @notice This contract is an upgradeChanger to add a gas price limit on
  mint and redeem operation for MoC and RoC protocols
 */
contract MaxGasPriceChanger is ChangeContract {

  AdminUpgradeabilityProxy public MOC_proxy;
  UpgradeDelegator public MOC_upgradeDelegator;
  address public MOC_newImplementation;

  AdminUpgradeabilityProxy public ROC_proxy;
  UpgradeDelegator public ROC_upgradeDelegator;
  address public ROC_newImplementation;

  uint256 public maxGasPrice;

  /**
    @notice Constructor
    @param _MOC_proxy Address of the MOC proxy to be upgraded
    @param _MOC_upgradeDelegator Address of the MOC upgradeDelegator in charge of that proxy
    @param _MOC_newImplementation Address of the contract the MOC proxy will delegate to
    @param _ROC_proxy Address of the ROC proxy to be upgraded
    @param _ROC_upgradeDelegator Address of the ROC upgradeDelegator in charge of that proxy
    @param _ROC_newImplementation Address of the contract the ROC proxy will delegate to
    @param _maxGasPrice gas price limit to mint and redeem operations
  */
  constructor(
    AdminUpgradeabilityProxy _MOC_proxy,
    UpgradeDelegator _MOC_upgradeDelegator,
    address _MOC_newImplementation,
    AdminUpgradeabilityProxy _ROC_proxy,
    UpgradeDelegator _ROC_upgradeDelegator,
    address _ROC_newImplementation,
    uint256 _maxGasPrice
    ) public {
    MOC_proxy = _MOC_proxy;
    MOC_upgradeDelegator = _MOC_upgradeDelegator;
    MOC_newImplementation = _MOC_newImplementation;
    ROC_proxy = _ROC_proxy;
    ROC_upgradeDelegator = _ROC_upgradeDelegator;
    ROC_newImplementation = _ROC_newImplementation;
    maxGasPrice = _maxGasPrice;
  }
  /**
    @notice Execute the changes.
    @dev Should be called by the governor, but this contract does not check that explicitly because it is not its responsability in
    the current architecture
    IMPORTANT: This function should not be overriden, you should only redefine the _beforeUpgrade and _afterUpgrade to use this template
   */
  function execute() external {
    _beforeUpgrade();
    _upgrade();
    _afterUpgrade();
  }

  /**
    @notice Upgrade the proxy to the newImplementation
    @dev IMPORTANT: This function should not be overriden
   */
  function _upgrade() internal {
    // upgrade MoC
    MOC_upgradeDelegator.upgrade(MOC_proxy, MOC_newImplementation);
    // upgrade RoC
    ROC_upgradeDelegator.upgrade(ROC_proxy, ROC_newImplementation);
  }

  /**
    @notice Intended to prepare the system for the upgrade
    @dev This function can be overriden by child changers to upgrade contracts that require some preparation before the upgrade
   */
  function _beforeUpgrade() internal {
  }

  /**
    @notice Intended to do the final tweaks after the upgrade, for example initialize the contract
    @dev This function can be overriden by child changers to upgrade contracts that require some changes after the upgrade
   */
  function _afterUpgrade() internal {
    // set max gas price to MoC
    MoC(address(MOC_proxy)).setMaxGasPrice(maxGasPrice);
    // set max gas price to RoC
    MoC(address(ROC_proxy)).setMaxGasPrice(maxGasPrice);
  }
}