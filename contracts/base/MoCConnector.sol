pragma solidity 0.5.8;

import "zos-lib/contracts/Initializable.sol";

import "./MoCWhitelist.sol";

/**
  @dev Provides access control between all MoC Contracts
 */
contract MoCConnector is MoCWhitelist, Initializable {
  // References
  address payable public moc;
  address public docToken;
  address public bproToken;
  address public bproxManager;
  address public mocState;
  address public mocConverter;
  address public mocSettlement;
  address public mocExchange;
  address public mocInrate;
  address public mocBurnout;
  address public mocToken;

  bool internal initialized;

  event MoCTokenChanged (
    address mocTokenAddress
  );

  function initialize(
    address payable mocAddress,
    address docAddress,
    address bproAddress,
    address bproxAddress,
    address stateAddress,
    address settlementAddress,
    address converterAddress,
    address exchangeAddress,
    address inrateAddress,
    address burnoutBookAddress,
    address mocTokenAddress
  ) public initializer {
    moc = mocAddress;
    docToken = docAddress;
    bproToken = bproAddress;
    bproxManager = bproxAddress;
    mocState = stateAddress;
    mocSettlement = settlementAddress;
    mocConverter = converterAddress;
    mocExchange = exchangeAddress;
    mocInrate = inrateAddress;
    mocBurnout = burnoutBookAddress;
    mocToken = mocTokenAddress;

    // Add to Whitelist
    add(mocAddress);
    add(docAddress);
    add(bproAddress);
    add(bproxAddress);
    add(stateAddress);
    add(settlementAddress);
    add(converterAddress);
    add(exchangeAddress);
    add(inrateAddress);
    add(burnoutBookAddress);

    setMoCToken(mocTokenAddress);
  }

  // TODO: this is public, should be changed by governance
  // Suggestion: create a "MoCConnectorChanger" contract
  function setMoCToken(address mocTokenAddress) public {
    address oldMoCTokenAddress = mocToken;
    mocToken = mocTokenAddress;

    if (address(mocTokenAddress) != address(0)) {
      add(mocTokenAddress);
    } else {
      remove(oldMoCTokenAddress);
    }

    emit MoCTokenChanged(mocTokenAddress);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}