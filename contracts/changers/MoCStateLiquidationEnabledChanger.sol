pragma solidity ^0.5.8;
import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCState
 * with MoC --- governance.
 */
contract MoCStateLiquidationEnabledChanger is ChangeContract, Ownable {
  MoCState public mocState;
  bool public liquidationEnabled;

  constructor(
    MoCState _mocState,
    bool _liquidationEnabled
  ) public {
    mocState = _mocState;
    liquidationEnabled = _liquidationEnabled;
  }

  function execute() external {
    mocState.setLiquidationEnabled(liquidationEnabled);
  }

  function setLiquidationEnabled(bool _liquidationEnabled) public onlyOwner() {
    liquidationEnabled = _liquidationEnabled;
  }


}
