pragma solidity 0.5.8;
import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCState
 * with MoC --- governance.
 */
contract PriceProviderChanger is ChangeContract, Ownable {
  MoCState public mocState;
  address public btcPriceProvider;

  constructor(
    MoCState _mocState,
    address _btcPriceProvider
  ) public {
    mocState = _mocState;
    btcPriceProvider = _btcPriceProvider;
  }

  function execute() external {
    mocState.setBtcPriceProvider(btcPriceProvider);
  }

  function setBtcPriceProvider(address _btcPriceProvider) public onlyOwner() {
    btcPriceProvider = _btcPriceProvider;
  }
}
