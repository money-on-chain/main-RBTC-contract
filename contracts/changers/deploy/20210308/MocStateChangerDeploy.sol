pragma solidity 0.5.8;

import "../../MocStateChanger.sol";

/**
 * @dev This contract is used to update the configuration of MoCState v017
 * with MoC --- governance.
 * Use for deploy only
 */
contract MocStateChangerDeploy is MocStateChanger {
  constructor(
      MoCState _mocState,
      address _mocPriceProvider,
      address _mocTokenAddress,
      address _mocVendorsAddress,
      bool _liquidationEnabled,
      uint256 _protected
    )
    MocStateChanger(
      _mocState,
      _mocPriceProvider, // passing other address instead
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      _mocPriceProvider,
      _mocTokenAddress,
      _mocVendorsAddress,
      _liquidationEnabled,
      _protected
    )
  public { }

  function execute() external {
    mocState.setMoCPriceProvider(mocPriceProvider);
    mocState.setMoCToken(mocToken);
    mocState.setMoCVendors(mocVendors);
    mocState.setLiquidationEnabled(liquidationEnabled);
    mocState.setProtected(protected);
  }
}
