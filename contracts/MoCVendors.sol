pragma solidity 0.5.8;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "./MoCLibConnection.sol";
import "./base/MoCBase.sol";
import "./MoC.sol";
import "./token/MoCToken.sol";
import "./MoCExchange.sol";
import "./MoCState.sol";

contract MoCVendorsEvents {
  event VendorRegistered(
    address account
  );
  event VendorUnregistered(
    address account
  );
  event VendorStakeAdded(
    address account,
    uint256 staking
  );
  event VendorStakeRemoved(
    address account,
    uint256 staking
  );
  event TotalPaidInMoCReset(
    address account
  );
}

contract MoCVendors is MoCVendorsEvents, MoCBase, MoCLibConnection, Governed {
  using Math for uint256;
  using SafeMath for uint256;

  // Structs
  struct VendorDetails {
    bool isActive;
    uint256 markup;
    uint256 totalPaidInMoC;  // TopeMoc
    uint256 staking;  // provisorio - lo que le retienen
    uint256 paidMoC; // MocaCobrar
    uint256 paidRBTC; // RBTCaCobrar
  }

  // Contracts
  MoC internal moc;
  MoCState internal mocState;
  MoCExchange internal mocExchange;

  // Constants
  uint8 public constant VENDORS_LIST_ARRAY_MAX_LENGTH = 100;

  // Variables
  mapping(address => VendorDetails) public vendors;
  address[] public vendorsList;

  function initialize(
    address connectorAddress,
    address _governor
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor);
  }

  function getVendorsCount() public view returns(uint vendorsCount) {
    return vendorsList.length;
  }

  function registerVendor(address account, uint256 markup) public onlyAuthorizedChanger() returns (bool isActive) {
    // Change the error message according to the value of the VENDORS_LIST_ARRAY_MAX_LENGTH constant
    require(vendorsList.length + 1 <= VENDORS_LIST_ARRAY_MAX_LENGTH, "vendorsList length must be between 1 and 100");

    // Map vendor details to vendor address
    vendors[account].isActive = true;
    vendors[account].markup = markup;

    vendorsList.push(account) - 1;

    emit VendorRegistered(account);

    return vendors[account].isActive;
  }

  function unregisterVendor(address account) public onlyAuthorizedChanger() onlyActiveVendor(account) returns (bool isActive) {
    vendors[account].isActive = false;

    for (uint8 i = 0; i < vendorsList.length; i++) {
      if (vendorsList[i] == account) {
        delete vendorsList[i];
      }
    }

    emit VendorUnregistered(account);

    return vendors[account].isActive;
  }

  function addStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());
    (uint256 mocBalance, uint256 mocAllowance) = mocExchange.getMoCTokenBalance(msg.sender, address(this));

    require(staking > 0, "Staking should be greater than 0");
    require(staking <= mocBalance && staking <= mocAllowance, "MoC balance or MoC allowance are not enough to add staking");

    mocToken.transferFrom(msg.sender, address(this), staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeAdded(msg.sender, staking);
  }

  function removeStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());
    (uint256 mocBalance, uint256 mocAllowance) = mocExchange.getMoCTokenBalance(msg.sender, address(this));

    require(staking > 0, "Staking should be greater than 0");
    require(staking <= vendors[msg.sender].staking && staking <= mocBalance && staking <= mocAllowance, "Not enough MoCs in system");
    require(staking <= vendors[msg.sender].totalPaidInMoC, "Vendor total paid is not enough");

    mocToken.transfer(msg.sender, staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeRemoved(msg.sender, staking);
  }

  function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount)
  public
  onlyWhitelisted(msg.sender) {
    vendors[account].totalPaidInMoC = vendors[account].totalPaidInMoC.add(totalMoCAmount);
    vendors[account].paidMoC = vendors[account].paidMoC.add(mocAmount);
    vendors[account].paidRBTC = vendors[account].paidRBTC.add(rbtcAmount);
  }

  function getVendorDetails(address account) public view
  returns (bool isActive, uint256 markup, uint256 totalPaidInMoC, uint256 staking, uint256 paidMoC, uint256 paidRBTC) {
    isActive = vendors[account].isActive;
    markup = vendors[account].markup;
    totalPaidInMoC = vendors[account].totalPaidInMoC;
    staking = vendors[account].staking;
    paidMoC = vendors[account].paidMoC;
    paidRBTC = vendors[account].paidRBTC;

    return (isActive, markup, totalPaidInMoC, staking, paidMoC, paidRBTC);
  }

  function getIsActive(address account) public view
  returns (bool) {
    return vendors[account].isActive;
  }
  function getMarkup(address account) public view
  returns (uint256) {
    return vendors[account].markup;
  }

  function getTotalPaidInMoC(address account) public view
  returns (uint256) {
    return vendors[account].totalPaidInMoC;
  }
  function getStaking(address account) public view
  returns (uint256) {
    return vendors[account].staking;
  }

  function getPaidMoC(address account) public view
  returns (uint256) {
    return vendors[account].paidMoC;
  }

  function getPaidRBTC(address account) public view
  returns (uint256) {
    return vendors[account].paidRBTC;
  }

  function resetTotalPaidInMoC() public onlyWhitelisted(msg.sender) {
    // Triggered by settlement
    for (uint8 i = 0; i < vendorsList.length; i++) {
      address account = vendorsList[i];

      // Reset only if vendor is active
      if (vendors[account].isActive == true) {
        vendors[account].totalPaidInMoC = 0;

        emit TotalPaidInMoCReset(account);
      }
    }
  }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    mocState = MoCState(connector.mocState());
    mocExchange = MoCExchange(connector.mocExchange());
  }

  function initializeValues(address _governor) internal {
    governor = IGovernor(_governor);
  }

  modifier onlyActiveVendor(address account) {
    require(vendors[account].isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
