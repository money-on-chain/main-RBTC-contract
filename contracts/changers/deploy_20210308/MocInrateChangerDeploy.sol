pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

import "../MocInrateChanger.sol";

/**
 * @dev This contract is used to update the configuration of MocInrate
 * with MoC --- governance.
 * Use for deploy only
 */
contract MocInrateChangerDeploy is MocInrateChanger {
  MoCInrate private mocInrate;

  constructor(
    MoCInrate _mocInrate,
    CommissionRates[] memory _commissionRates
  ) public {
    mocInrate = _mocInrate;
    setCommissionRatesInternal(_commissionRates);
  }

  function execute() external {
    /** UPDATE V0110: 24/09/2020 - Upgrade to support multiple commission rates **/
    initializeCommissionRates();
  }
}