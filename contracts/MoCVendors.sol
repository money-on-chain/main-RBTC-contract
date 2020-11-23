pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

import "moc-governance/contracts/Governance/Governed.sol";
import "./MoCLibConnection.sol";
import "./MoCInrate.sol";
import "./base/MoCBase.sol";
import "./MoC.sol";
import "./token/MoCToken.sol";

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
}

contract MoCVendors is MoCVendorsEvents, MoCBase, MoCLibConnection {
  using Math for uint256;
  using SafeMath for uint256;

  // Contracts
  MoC internal moc;
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCInrate internal mocInrate;

  // Structs
  struct VendorDetails {
    bool isActive;
    uint256 markup;
    uint256 totalPaidInMoC;  // TopeMoc
    uint256 staking;  // provisorio - lo que le retienen
    uint256 paidMoC; // MocaCobrar
    uint256 paidRBTC; // RBTCaCobrar
  }

  // Variables
  mapping(address => VendorDetails) public vendors;
  uint8 private daysToResetVendor;

  function initialize(
    address connectorAddress,
    uint8 _daysToResetVendor
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_daysToResetVendor);
  }

  //function registerVendor(address account, uint256 markup) public onlyOwner returns (bool isActive) {
  function registerVendor(address account, uint256 markup) public returns (bool isActive) {
    // Map vendor details to vendor address
    vendors[account].isActive = true;
    vendors[account].markup = markup;

    emit VendorRegistered(account);

    return vendors[account].isActive;
  }

  function unregisterVendor(address account) public returns (bool isActive) {
    vendors[account].isActive = false;

    emit VendorUnregistered(account);

    return vendors[account].isActive;
  }

  function addStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());
    mocToken.transferFrom(msg.sender, address(this), staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeAdded(msg.sender, staking);
  }

  function removeStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    require(vendors[msg.sender].totalPaidInMoC.sub(staking) > 0, "Vendor total paid is not enough");
    require(staking <= vendors[msg.sender].staking && staking <= mocToken.balanceOf(address(this)), "Not enough MoCs in system");

    mocToken.transfer(msg.sender, staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeRemoved(msg.sender, staking);
  }

  function updatePaidMarkup(address vendorAccount, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount)
  public
  onlyWhitelisted(msg.sender)
  returns (uint256 markup, uint256 totalPaidInMoC, uint256 staking) {
    vendors[vendorAccount].totalPaidInMoC = vendors[vendorAccount].totalPaidInMoC.add(totalMoCAmount);
    vendors[vendorAccount].paidMoC = vendors[vendorAccount].paidMoC.add(mocAmount);
    vendors[vendorAccount].paidRBTC = vendors[vendorAccount].paidRBTC.add(rbtcAmount);

    return getVendorDetails(vendorAccount);
  }

  function getVendorDetails(address vendorAccount) public view onlyWhitelisted(msg.sender)
  returns (uint256, uint256, uint256) {
    return (vendors[vendorAccount].markup, vendors[vendorAccount].totalPaidInMoC, vendors[vendorAccount].staking);
  }

  // function resetTotalPaidInMoC() public {
  //   vendors[vendorAccount].totalPaidInMoC = 0;

  //   //emit TotalPaidInMoCReset();
  // }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    mocState = MoCState(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
    mocInrate = MoCInrate(connector.mocInrate());
  }

  function initializeValues(uint8 _daysToResetVendor) internal {
    //governor = IGovernor(_governor);
    daysToResetVendor = _daysToResetVendor;
  }

  modifier onlyActiveVendor(address account) {
    require(vendors[account].isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
