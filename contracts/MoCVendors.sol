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
    address account,
    uint256 markup
  );
  event VendorUpdated(
    address account,
    uint256 markup
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
  event VendorMoCDepositAddressChanged (
    address vendorMoCDepositAddress
  );
  event VendorRequiredMoCsChanged (
    uint256 vendorRequiredMoCs
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
  uint256 public constant VENDOR_MAX_MARKUP = 10000000000000000; // 0.01 = 1%

  // Variables
  mapping(address => VendorDetails) public vendors;
  address[] public vendorsList;
  address public vendorMoCDepositAddress;
  uint256 public vendorRequiredMoCs;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
  */
  function initialize(
    address connectorAddress,
    address _governor,
    address _vendorMoCDepositAddress,
    uint256 _vendorRequiredMoCs
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _vendorMoCDepositAddress, _vendorRequiredMoCs);
  }

  /**
    @dev Gets the count of active registered vendors
    @return Amount of active registered vendors
  */
  function getVendorsCount() public view returns(uint vendorsCount) {
    return vendorsList.length;
  }

  /**
    @dev Allows a vendor to register themselves
    @param markup Markup which vendor will perceive from mint/redeem operations
    @return true if vendor was registered successfully; otherwise false
  */
  function registerVendor(uint256 markup) public returns (bool isActive) {
    require(msg.sender != address(0), "Vendor account must not be 0x0");
    require(markup <= VENDOR_MAX_MARKUP, "Vendor markup must not be greater than 1%");
    // Change the error message according to the value of the VENDORS_LIST_ARRAY_MAX_LENGTH constant
    require(vendorsList.length < VENDORS_LIST_ARRAY_MAX_LENGTH, "vendorsList length must be between 1 and 100");

    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    if (vendors[msg.sender].isActive == false) {
      // Vendor needs to transfer MoCs to a configured address before registering
      // If vendor does not have enough funds in MoC (transfer fails), they cannot be registered
      mocToken.transferFrom(msg.sender, vendorMoCDepositAddress, vendorRequiredMoCs);

      // Map vendor details to vendor address
      vendors[msg.sender].isActive = true;
      vendors[msg.sender].markup = markup;

      vendorsList.push(msg.sender);

      emit VendorRegistered(msg.sender, markup);
    } else if (vendors[msg.sender].markup != markup) {
      vendors[msg.sender].markup = markup;

      emit VendorUpdated(msg.sender, markup);
    }

    return vendors[msg.sender].isActive;
  }

  /**
    @dev Allows a vendor to unregister themselves (msg.sender)
    @return false if vendor was unregistered successfully; otherwise false
  */
  function unregisterVendor() public onlyActiveVendor() returns (bool isActive) {
    uint8 i = 0;
    while (i < vendorsList.length && vendorsList[i] != msg.sender) {
      i++;
    }
    // If vendor is found, then unregister it
    if (i < vendorsList.length) {
      vendors[msg.sender].isActive = false;
      vendorsList[i] = vendorsList[vendorsList.length - 1];
      delete vendorsList[vendorsList.length - 1];
      vendorsList.length--;

      emit VendorUnregistered(msg.sender);
      return false;
    }

    return vendors[msg.sender].isActive;
  }

  /**
    @dev Allows an active vendor (msg.sender) to add staking
    @param staking Staking the vendor wants to add
  */
  function addStake(uint256 staking) public onlyActiveVendor() {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());
    (uint256 mocBalance, uint256 mocAllowance) = mocExchange.getMoCTokenBalance(msg.sender, address(this));

    require(staking > 0, "Staking should be greater than 0");
    require(staking <= mocBalance && staking <= mocAllowance, "MoC balance or MoC allowance are not enough to add staking");

    mocToken.transferFrom(msg.sender, address(this), staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeAdded(msg.sender, staking);
  }

  /**
    @dev Allows an active vendor (msg.sender) to remove staking
    @param staking Staking the vendor wants to add
  */
  function removeStake(uint256 staking) public onlyActiveVendor() {
    MoCToken mocToken = MoCToken(mocState.getMoCToken());

    require(staking > 0, "Staking should be greater than 0");
    require(staking <= vendors[msg.sender].totalPaidInMoC, "Vendor total paid is not enough");

    mocToken.transfer(msg.sender, staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.sub(staking);

    emit VendorStakeRemoved(msg.sender, staking);
  }

  /**
    @dev Allows to update paid markup to vendor
    @param account Vendor address
    @param mocAmount paid markup in MoC
    @param rbtcAmount paid markup in RBTC
    @param totalMoCAmount total paid in MoC
  */
  function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount, uint256 totalMoCAmount)
  public
  onlyWhitelisted(msg.sender) {
    vendors[account].totalPaidInMoC = vendors[account].totalPaidInMoC.add(totalMoCAmount);
    vendors[account].paidMoC = vendors[account].paidMoC.add(mocAmount);
    vendors[account].paidRBTC = vendors[account].paidRBTC.add(rbtcAmount);
  }

  /**
    @dev Gets if a vendor is active
    @param account Vendor address
    @return true if vendor is active; false otherwise
  */
  function getIsActive(address account) public view
  returns (bool) {
    return vendors[account].isActive;
  }

  /**
    @dev Gets vendor markup
    @param account Vendor address
    @return Vendor markup
  */
  function getMarkup(address account) public view
  returns (uint256) {
    return vendors[account].markup;
  }

  /**
    @dev Gets vendor total paid in MoC
    @param account Vendor address
    @return Vendor total paid in MoC
  */
  function getTotalPaidInMoC(address account) public view
  returns (uint256) {
    return vendors[account].totalPaidInMoC;
  }

  /**
    @dev Gets vendor staking
    @param account Vendor address
    @return Vendor staking
  */
  function getStaking(address account) public view
  returns (uint256) {
    return vendors[account].staking;
  }

  /**
    @dev Gets vendor paid in MoC
    @param account Vendor address
    @return Vendor paid in MoC
  */
  function getPaidMoC(address account) public view
  returns (uint256) {
    return vendors[account].paidMoC;
  }

  /**
    @dev Gets vendor paid in RBTC
    @param account Vendor address
    @return Vendor total paid in RBTC
  */
  function getPaidRBTC(address account) public view
  returns (uint256) {
    return vendors[account].paidRBTC;
  }

  /**
    @dev Allows to reset all active vendor's total paid in MoC during settlement
  */
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

  /**
    @dev Returns the address which will receive the initial amount of MoC required for a vendor to register.
  */
  function getVendorMoCDepositAddress() public view returns(address) {
    return vendorMoCDepositAddress;
  }

  /**
    @dev Sets the address which will receive the initial amount of MoC required for a vendor to register.
    @param _vendorMoCDepositAddress Address which will receive the initial MoC required for a vendor to register.
  */
  function setVendorMoCDepositAddress(address _vendorMoCDepositAddress) public onlyAuthorizedChanger() {
    require(_vendorMoCDepositAddress != address(0), "vendorMoCDepositAddress must not be 0x0");

    vendorMoCDepositAddress = _vendorMoCDepositAddress;

    emit VendorMoCDepositAddressChanged(_vendorMoCDepositAddress);
  }

  /**
    @dev Returns the initial amount of MoC required for a vendor to register.
  */
  function getVendorRequiredMoCs() public view returns (uint256){
    return vendorRequiredMoCs;
  }

  /**
    @dev Sets the initial amount of MoC required for a vendor to register.
    @param _vendorRequiredMoCs Initial amount of MoC required for a vendor to register.
  */
  function setVendorRequiredMoCs(uint256 _vendorRequiredMoCs) public onlyAuthorizedChanger() {
    vendorRequiredMoCs = _vendorRequiredMoCs;

    emit VendorRequiredMoCsChanged(_vendorRequiredMoCs);
  }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    mocState = MoCState(connector.mocState());
    mocExchange = MoCExchange(connector.mocExchange());
  }

  function initializeValues(address _governor, address _vendorMoCDepositAddress, uint256 _vendorRequiredMoCs) internal {
    governor = IGovernor(_governor);
    setVendorMoCDepositAddress(_vendorMoCDepositAddress);
    setVendorRequiredMoCs(_vendorRequiredMoCs);
  }

  /**
    @dev Checks if vendor (msg.sender) is active
  */
  modifier onlyActiveVendor() {
    require(vendors[msg.sender].isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
