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

  UpgradeDelegator public upgradeDelegator;
  AdminUpgradeabilityProxy public MOC_proxy;
  address public MOC_newImplementation;

  AdminUpgradeabilityProxy public ROC_proxy;
  address public ROC_newImplementation;

  AdminUpgradeabilityProxy public stopper_proxy;
  address public stopper_newImplementation;

  uint256 public maxGasPrice;

  /**
    @notice Constructor
    @param _upgradeDelegator Address of the upgradeDelegator in charge of that proxy
    @param _MOC_proxy Address of the MOC proxy to be upgraded
    @param _MOC_newImplementation Address of the contract the MOC proxy will delegate to
    @param _ROC_proxy Address of the ROC proxy to be upgraded
    @param _ROC_newImplementation Address of the contract the ROC proxy will delegate to
    @param _stopper_newImplementation Address of the contract the Stopper proxy will delegate to
    @param _maxGasPrice gas price limit to mint and redeem operations
  */
  constructor(
    UpgradeDelegator _upgradeDelegator,
    AdminUpgradeabilityProxy _MOC_proxy,
    address _MOC_newImplementation,
    AdminUpgradeabilityProxy _ROC_proxy,
    address _ROC_newImplementation,
    address _stopper_newImplementation,
    uint256 _maxGasPrice
    ) public {
    upgradeDelegator = _upgradeDelegator;
    MOC_proxy = _MOC_proxy;
    MOC_newImplementation = _MOC_newImplementation;
    ROC_proxy = _ROC_proxy;
    ROC_newImplementation = _ROC_newImplementation;
    maxGasPrice = _maxGasPrice;
    address mocStopper = MoC(address(_MOC_proxy)).stopper();
    address rocStopper = MoC(address(_ROC_proxy)).stopper();
    require(mocStopper == rocStopper, "MoC and RoC have different stopper address set");
    stopper_proxy = castToAdminUpgradeabilityProxy(address(mocStopper));
    stopper_newImplementation = _stopper_newImplementation;
  }

  /**
   * @notice cast non payable address to AdminUpgradebilityProxy
   * @param _address address to cast
   */
  function castToAdminUpgradeabilityProxy(address _address) internal returns (AdminUpgradeabilityProxy proxy) {
    return AdminUpgradeabilityProxy(address(uint160(_address)));
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
    upgradeDelegator.upgrade(MOC_proxy, MOC_newImplementation);
    // upgrade RoC
    upgradeDelegator.upgrade(ROC_proxy, ROC_newImplementation);
    // upgrade Stopper
    upgradeDelegator.upgrade(stopper_proxy, stopper_newImplementation);
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