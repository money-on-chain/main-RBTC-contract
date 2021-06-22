pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "moc-governance/contracts/Governance/Governed.sol";
import "./MoCLibConnection.sol";
import "./base/MoCBase.sol";
import "./interface/IMoC.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./interface/IMoCExchange.sol";
import "./interface/IMoCState.sol";
import "./interface/IMoCVendors.sol";

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
  event VendorGuardianAddressChanged (
    address vendorGuardianAddress
  );
  event VendorReceivedMarkup (
    address vendorAdress,
    uint256 paidMoC,
    uint256 paidRBTC
  );
}

contract MoCVendors is MoCVendorsEvents, MoCBase, MoCLibConnection, Governed, IMoCVendors {
  using Math for uint256;
  using SafeMath for uint256;

  // Structs
  struct VendorDetails {
    bool isActive;
    uint256 markup;
    uint256 totalPaidInMoC;
    uint256 staking; // temporarily retained
  }

  // Contracts
  IMoC internal moc;
  IMoCState internal mocState;
  IMoCExchange internal mocExchange;

  // Constants
  uint8 public constant VENDORS_LIST_ARRAY_MAX_LENGTH = 100;
  uint256 public constant VENDOR_MAX_MARKUP = 10000000000000000; // 0.01 = 1%

  // Variables
  address public vendorGuardianAddress;
  mapping(address => VendorDetails) public vendors;
  address[] public vendorsList;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
    @param _vendorGuardianAddress Address which will be authorized to register and unregister vendors.
  */
  function initialize(
    address connectorAddress,
    address _governor,
    address _vendorGuardianAddress
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _vendorGuardianAddress);
  }

  /**
    @dev Gets the count of active registered vendors
    @return Amount of active registered vendors
  */
  function getVendorsCount() public view returns(uint vendorsCount) {
    return vendorsList.length;
  }

  /**
    @dev Allows to register a vendor
    @param account Vendor address
    @param markup Markup which vendor will perceive from mint/redeem operations
    @return true if vendor was registered successfully; otherwise false
  */
  function registerVendor(address account, uint256 markup) public onlyVendorGuardian() returns (bool isActive) {
    require(account != address(0), "Vendor account must not be 0x0");
    require(markup <= VENDOR_MAX_MARKUP, "Vendor markup threshold exceeded");

    if (vendors[account].isActive == false) {
      // Change the error message according to the value of the VENDORS_LIST_ARRAY_MAX_LENGTH constant
      require(vendorsList.length < VENDORS_LIST_ARRAY_MAX_LENGTH, "vendorsList length out of range");

      // Map vendor details to vendor address
      vendors[account].isActive = true;
      vendors[account].markup = markup;

      vendorsList.push(account);

      emit VendorRegistered(account, markup);
    } else if (vendors[account].markup != markup) {
      vendors[account].markup = markup;

      emit VendorUpdated(account, markup);
    }

    return vendors[account].isActive;
  }

  /**
    @dev Allows to unregister a vendor
    @param account Vendor address
    @return false if vendor was unregistered successfully; otherwise false
  */
  function unregisterVendor(address account) public onlyVendorGuardian() returns (bool isActive) {
    uint8 i = 0;
    while (i < vendorsList.length && vendorsList[i] != account) {
      i++;
    }
    // If vendor is found, then unregister it
    if (i < vendorsList.length) {
      vendors[account].isActive = false;
      vendorsList[i] = vendorsList[vendorsList.length - 1];
      delete vendorsList[vendorsList.length - 1];
      vendorsList.length--;

      emit VendorUnregistered(account);
      return false;
    }

    return vendors[account].isActive;
  }

  /**
    @dev Allows an active vendor (msg.sender) to add staking
    @param staking Staking the vendor wants to add
  */
  function addStake(uint256 staking) public onlyActiveVendor() {
    IERC20 mocToken = IERC20(mocState.getMoCToken());
    (uint256 mocBalance, uint256 mocAllowance) = mocExchange.getMoCTokenBalance(msg.sender, address(this));

    require(staking > 0, "Staking should be greater than 0");
    require(staking <= mocBalance && staking <= mocAllowance, "MoC balance or MoC allowance are not enough to add staking");

    mocToken.transferFrom(msg.sender, address(this), staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.add(staking);

    emit VendorStakeAdded(msg.sender, staking);
  }

  /**
    @dev Allows an active vendor (msg.sender) to remove staking
    @param staking Staking the vendor wants to remove
  */
  function removeStake(uint256 staking) public onlyActiveVendor() {
    require(staking > 0, "Staking should be greater than 0");

    IERC20 mocToken = IERC20(mocState.getMoCToken());
    mocToken.transfer(msg.sender, staking);
    vendors[msg.sender].staking = vendors[msg.sender].staking.sub(staking);

    emit VendorStakeRemoved(msg.sender, staking);
  }

  /**
    @dev Allows to update paid markup to vendor
    @param account Vendor address
    @param mocAmount paid markup in MoC
    @param rbtcAmount paid markup in RBTC
  */
  function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount)
  public
  onlyWhitelisted(msg.sender)
  returns(bool) {
    VendorDetails memory vendorDetails = vendors[account];
    if (vendorDetails.isActive &&
          vendorDetails.totalPaidInMoC.add(mocAmount) <= vendorDetails.staking) {
      uint256 totalMoCAmount = mocAmount;
      if (rbtcAmount > 0) {
        uint256 btcPrice = mocState.getBitcoinPrice();
        uint256 mocPrice = mocState.getMoCPrice();
        totalMoCAmount = btcPrice.mul(rbtcAmount).div(mocPrice);
      }
      vendors[account].totalPaidInMoC = vendorDetails.totalPaidInMoC.add(totalMoCAmount);
      emit VendorReceivedMarkup(account, mocAmount, rbtcAmount);
      return true;
    }
    return false;
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
    @dev Returns the address is authorized to register and unregister vendors.
  */
  function getVendorGuardianAddress() public view returns(address) {
    return vendorGuardianAddress;
  }

  /**
    @dev Sets the address which will be authorized to register and unregister vendors.
    @param _vendorGuardianAddress Address which will be authorized to register and unregister vendors.
  */
  function setVendorGuardianAddress(address _vendorGuardianAddress) public onlyAuthorizedChanger() {
    setVendorGuardianAddressInternal(_vendorGuardianAddress);
  }

  function initializeContracts() internal {
    moc = IMoC(connector.moc());
    mocState = IMoCState(connector.mocState());
    mocExchange = IMoCExchange(connector.mocExchange());
  }

  function initializeValues(address _governor, address _vendorGuardianAddress) internal {
    governor = IGovernor(_governor);
    setVendorGuardianAddressInternal(_vendorGuardianAddress);
  }

  /**
    @dev Sets the address which will be authorized to register and unregister vendors.
    @param _vendorGuardianAddress Address which will be authorized to register and unregister vendors.
  */
  function setVendorGuardianAddressInternal(address _vendorGuardianAddress) internal {
    require(_vendorGuardianAddress != address(0), "vendorGuardianAddress must not be 0x0");

    vendorGuardianAddress = _vendorGuardianAddress;

    emit VendorGuardianAddressChanged(vendorGuardianAddress);
  }

  /**
    @dev Checks if vendor (msg.sender) is active
  */
  modifier onlyActiveVendor() {
    require(vendors[msg.sender].isActive == true, "Vendor is inexistent or inactive");
    _;
  }

  /**
    @dev Checks if address is allowed to call function
  */
  modifier onlyVendorGuardian() {
    require(msg.sender == vendorGuardianAddress, "Caller is not vendor guardian address");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
