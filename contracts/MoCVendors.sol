pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

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

contract MoCVendors is MoCVendorsEvents, MoCBase, MoCLibConnection {
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

  // Variables
  mapping(address => VendorDetails) public vendors;
  uint8 private daysToResetVendor;
  uint256 public lastDay;

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
    (uint256 mocBalance, uint256 mocAllowance) = mocExchange.getMoCTokenBalance(msg.sender, address(this));

    require(staking <= mocBalance && staking <= mocAllowance, "MoC balance or MoC allowance are not enough to add staking");

    mocToken.transferFrom(msg.sender, address(this), staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeAdded(msg.sender, staking);
  }

  function removeStake(uint256 staking) public onlyActiveVendor(msg.sender) {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    require(staking <= vendors[msg.sender].totalPaidInMoC, "Vendor total paid is not enough");
    require(staking <= vendors[msg.sender].staking && staking <= mocToken.balanceOf(address(this)), "Not enough MoCs in system");

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

  function getMarkup(address account) public view onlyWhitelisted(msg.sender)
  returns (uint256) {
    return vendors[account].markup;
  }

  function getTotalPaidInMoC(address account) public view onlyWhitelisted(msg.sender)
  returns (uint256) {
    return vendors[account].totalPaidInMoC;
  }
  function getStaking(address account) public view onlyWhitelisted(msg.sender)
  returns (uint256) {
    return vendors[account].staking;
  }

  function resetTotalPaidInMoC(address account) public onlyWhitelisted(msg.sender) {
    // solium-disable-next-line security/no-block-members
    if (now > lastDay + daysToResetVendor * 1 days) {
      // solium-disable-next-line security/no-block-members
      lastDay = now;
      vendors[account].totalPaidInMoC = 0;

      emit TotalPaidInMoCReset(account);
    }
  }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    mocState = MoCState(connector.mocState());
    mocExchange = MoCExchange(connector.mocExchange());
  }

  function initializeValues(uint8 _daysToResetVendor) internal {
    //governor = IGovernor(_governor);
    daysToResetVendor = _daysToResetVendor;
    lastDay = now;  // First day of counting to reset vendor's total paid is the day of contract's initialization
  }

  modifier onlyActiveVendor(address account) {
    require(vendors[account].isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
