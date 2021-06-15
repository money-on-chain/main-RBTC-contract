pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "../../MoCState.sol";

/**
 * @dev This productive contract is used to set the address of the RBTC Medianizer contract of MoCState with moc---gobernanza.
 */
contract MedianizerChanger is ChangeContract {
  MoCState public mocState;
  address public newMedianizer;

  constructor(MoCState _mocState, address _newMedianizer) public {
    mocState = _mocState;
    newMedianizer = _newMedianizer;
  }

  function execute() external {
    mocState.setBtcPriceProvider(newMedianizer);
  }
}
