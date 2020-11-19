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
    //address redeemAddress;
    bool isActive;
    uint256 markup;
    uint256 totalPaidInMoC;  // TopeMoc
    uint256 staking;  // provisorio - lo que le retienen
    uint256 paidMoC; // MocaCobrar
    uint256 paidRBTC; // RBTCaCobrar
  }

  // Variables
  mapping(address => VendorDetails) public vendors;

  function initialize(address connectorAddress) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
  }

  //function registerVendor(address account, uint256 markup) public onlyOwner returns (bool isActive) {
  function registerVendor(address account, uint256 markup) public returns (bool isActive) {
    VendorDetails memory details = vendors[account];

    details.isActive = true;
    details.markup = markup;

    vendors[account] = details;

    emit VendorRegistered(account);

    return details.isActive;
  }

  function addStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    VendorDetails memory details = vendors[msg.sender];

    MoCToken mocToken = MoCToken(mocState.getMoCToken());
    mocToken.transferFrom(msg.sender, address(this), staking);
    details.staking = details.staking.add(staking);
    //vendors[msg.sender] = details;

    emit VendorStakeAdded(msg.sender, staking);
  }

  function removeStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    VendorDetails memory details = vendors[msg.sender];
    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    require(details.totalPaidInMoC.sub(staking) > 0, "Vendor total paid is not enough");
    require(staking <= mocToken.balanceOf(address(this)), "Not enough MoCs in system");

    mocToken.transfer(msg.sender, staking);
    details.staking = details.staking.add(staking);
    //vendors[msg.sender] = details;

    emit VendorStakeRemoved(msg.sender, staking);
  }

  function updatePaidMarkup(address vendorAccount, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount)
  public
  onlyWhitelisted(msg.sender)
  returns (uint256 markup, uint256 totalPaidInMoC, uint256 staking) {
    VendorDetails memory details = vendors[vendorAccount];
    details.totalPaidInMoC = details.totalPaidInMoC.add(mocAmount).add(totalMoCAmount);
    details.paidMoC = details.paidMoC.add(mocAmount);
    details.paidRBTC = details.paidRBTC.add(rbtcAmount);
    //vendors[msg.sender] = details;

    return getVendorDetails(vendorAccount);
  }

  function getVendorDetails(address vendorAccount) public onlyWhitelisted(msg.sender)
  returns (uint256, uint256, uint256) {
    VendorDetails memory details = vendors[vendorAccount];
    return (details.markup, details.totalPaidInMoC, details.staking);
  }

  // function resetTotalPaidInMoC() public {
  //   VendorDetails memory details = vendors[vendorAccount];
  //   details.totalPaidInMoC = 0;

  //   //emit TotalPaidInMoCReset();
  // }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    mocState = MoCState(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
    mocInrate = MoCInrate(connector.mocInrate());
  }

  modifier onlyActiveVendor(address account) {
    VendorDetails memory details = vendors[account];
    require(details.isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
