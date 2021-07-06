pragma solidity ^0.5.8;
import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCState
 * with MoC --- governance.
 */
contract MoCStateMoCPriceProviderChanger is ChangeContract, Ownable {
  MoCState public mocState;
  address public mocPriceProvider;

  constructor(
    MoCState _mocState,
    address _mocPriceProvider
  ) public {
    mocState = _mocState;
    mocPriceProvider = _mocPriceProvider;
  }

  function execute() external {
    mocState.setMoCPriceProvider(mocPriceProvider);
  }

  function setMoCPriceProvider(address _mocPriceProvider) public onlyOwner() {
    mocPriceProvider = _mocPriceProvider;
  }

}

