// SPDX-License-Identifier: 
// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/base/MoCWhitelist.sol

pragma solidity ^0.5.8;

/**
  @dev Provides access control between all MoC Contracts
 */
contract MoCWhitelist {
  mapping(address => bool) whitelist;

  /**
   * @dev Check if an account is whitelisted
   * @return Bool
   */
  function isWhitelisted(address account)
    public
    view
    returns (bool)
  {
    require(account != address(0), "Account must not be 0x0");
    return whitelist[account];
  }

  /**
   * @dev Add account to whitelist
   */
  function add(address account) internal {
    require(account != address(0), "Account must not be 0x0");
    require(!isWhitelisted(account), "Account not allowed to add accounts into white list");
    whitelist[account] = true;
  }

  /**
   * @dev Remove account from whitelist
   */
  function remove(address account) internal {
    require(account != address(0), "Account must not be 0x0");
    require(isWhitelisted(account), "Account is not allowed to remove address from the white list");

    whitelist[account] = false;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/base/MoCConnector.sol

pragma solidity ^0.5.8;



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
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address public DEPRECATED_mocConverter;
  address public mocSettlement;
  address public mocExchange;
  address public mocInrate;
  /** DEPRECATED mocBurnout **/
  address public mocBurnout;

  bool internal initialized;

  /**
    @dev Initializes the contract
    @param mocAddress MoC contract address
    @param docAddress DoCToken contract address
    @param bproAddress BProToken contract address
    @param bproxAddress BProxManager contract address
    @param stateAddress MoCState contract address
    @param settlementAddress MoCSettlement contract address
    @param exchangeAddress MoCExchange contract address
    @param inrateAddress MoCInrate contract address
    @param burnoutBookAddress (DEPRECATED) MoCBurnout contract address. DO NOT USE.
  */
  function initialize(
    address payable mocAddress,
    address docAddress,
    address bproAddress,
    address bproxAddress,
    address stateAddress,
    address settlementAddress,
    address exchangeAddress,
    address inrateAddress,
    address burnoutBookAddress
  ) public initializer {
    moc = mocAddress;
    docToken = docAddress;
    bproToken = bproAddress;
    bproxManager = bproxAddress;
    mocState = stateAddress;
    mocSettlement = settlementAddress;
    mocExchange = exchangeAddress;
    mocInrate = inrateAddress;
    mocBurnout = burnoutBookAddress;

    // Add to Whitelist
    add(mocAddress);
    add(docAddress);
    add(bproAddress);
    add(bproxAddress);
    add(stateAddress);
    add(settlementAddress);
    add(exchangeAddress);
    add(inrateAddress);
    add(burnoutBookAddress);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/base/MoCConstants.sol

pragma solidity ^0.5.8;

/**
 * @dev Defines special constants to use along all the MoC System
 */
contract MoCConstants {
  bytes32 constant public BUCKET_X2 = "X2";
  bytes32 constant public BUCKET_C0 = "C0";
}

// File: contracts/base/MoCBase.sol

pragma solidity ^0.5.8;




/**
  @dev General usefull modifiers and functions
 */
contract MoCBase is MoCConstants, Initializable {
  // Contracts
  MoCConnector public connector;

  bool internal initialized;

  function initializeBase(address connectorAddress) internal initializer {
    connector = MoCConnector(connectorAddress);
  }

  modifier onlyWhitelisted(address account) {
    require(connector.isWhitelisted(account), "Address is not whitelisted");
    _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: moc-governance/contracts/Governance/ChangeContract.sol

pragma solidity ^0.5.8;

/**
  @title ChangeContract
  @notice This interface is the one used by the governance system.
  @dev If you plan to do some changes to a system governed by this project you should write a contract
  that does those changes, like a recipe. This contract MUST not have ANY kind of public or external function
  that modifies the state of this ChangeContract, otherwise you could run into front-running issues when the governance
  system is fully in place.
 */
interface ChangeContract {

  /**
    @notice Override this function with a recipe of the changes to be done when this ChangeContract
    is executed
   */
  function execute() external;
}

// File: moc-governance/contracts/Governance/IGovernor.sol

pragma solidity ^0.5.8;


/**
  @title Governor
  @notice Governor interface. This functions should be overwritten to
  enable the comunnication with the rest of the system
  */
interface IGovernor{

  /**
    @notice Function to be called to make the changes in changeContract
    @dev This function should be protected somehow to only execute changes that
    benefit the system. This decision process is independent of this architechture
    therefore is independent of this interface too
    @param changeContract Address of the contract that will execute the changes
   */
  function executeChange(ChangeContract changeContract) external;

  /**
    @notice Function to be called to make the changes in changeContract
    @param _changer Address of the contract that will execute the changes
   */
  function isAuthorizedChanger(address _changer) external view returns (bool);
}

// File: moc-governance/contracts/Governance/Governed.sol

pragma solidity ^0.5.8;



/**
  @title Governed
  @notice Base contract to be inherited by governed contracts
  @dev This contract is not usable on its own since it does not have any _productive useful_ behaviour
  The only purpose of this contract is to define some useful modifiers and functions to be used on the
  governance aspect of the child contract
  */
contract Governed is Initializable {

  /**
    @notice The address of the contract which governs this one
   */
  IGovernor public governor;

  string constant private NOT_AUTHORIZED_CHANGER = "not_authorized_changer";

  /**
    @notice Modifier that protects the function
    @dev You should use this modifier in any function that should be called through
    the governance system
   */
  modifier onlyAuthorizedChanger() {
    require(governor.isAuthorizedChanger(msg.sender), NOT_AUTHORIZED_CHANGER);
    _;
  }

  /**
    @notice Initialize the contract with the basic settings
    @dev This initialize replaces the constructor but it is not called automatically.
    It is necessary because of the upgradeability of the contracts
    @param _governor Governor address
   */
  function initialize(IGovernor _governor) public initializer {
    governor = _governor;
  }

  /**
    @notice Change the contract's governor. Should be called through the old governance system
    @param newIGovernor New governor address
   */
  function changeIGovernor(IGovernor newIGovernor) public onlyAuthorizedChanger {
    governor = newIGovernor;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/MoCBucketContainer.sol

pragma solidity ^0.5.8;





contract MoCBucketContainer is MoCBase, Governed {
  using SafeMath for uint256;
  using Math for uint256;

  struct BProxBalance {
    uint256 value;
    uint index; // Index start in 1, zero is reserved for NULL
  }

  struct MoCBucket {
    bytes32 name;
    bool isBase;
    uint256 nDoc;
    uint256 nBPro;
    uint256 nBTC;
    uint256 cobj;
    // Should only be used in L buckets
    mapping(address => BProxBalance) bproxBalances;
    address payable[] activeBalances;
    uint256 activeBalancesLength;
    // Should only be used in Base buckets (C0)
    uint256 inrateBag;
    bool available;
  }

  event BucketMovement(
    bytes32 from,
    bytes32 to,
    uint256 reserves,
    uint256 stableTokens
  );

  event BucketCreation(
    bytes32 name,
    uint256 cobj
  );

  event BucketStateUpdate(
    bytes32 name,
    uint256 nReserve,
    uint256 nStable,
    uint256 nRiskProx,
    uint256 inrateBag
  );

  mapping(bytes32 => MoCBucket) internal mocBuckets;

   /**
   GETTERS
   */
  function getBucketNBTC(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBTC;
  }

  function getBucketNBPro(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBPro;
  }

  function getBucketNDoc(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nDoc;
  }

  function getBucketCobj(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].cobj;
  }

  function getInrateBag(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].inrateBag;
  }

  /**
   * @dev Sets the objective coverage (cobj) on an specficied bucket.
   * @param  _bucket - name of the bucket
   * @param  _cobj - new value of cobj
   */
  function setBucketCobj(bytes32 _bucket, uint256 _cobj) public onlyAuthorizedChanger(){
    //TODO: It is necessary to analyze the impact in the model it has when changing X2. This
    mocBuckets[_bucket].cobj = _cobj;
  }

  /**
    @dev returns true if the bucket is a base bucket
    @param bucket Name of the bucket
  */
  function isBucketBase(bytes32 bucket) public view returns(bool){
    return mocBuckets[bucket].isBase;
  }

  /**
    @dev returns true if the bucket have docs in it
    @param bucket Name of the bucket
  */
  function isBucketEmpty(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].nDoc == 0;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddresses(bytes32 bucket) public view returns(address payable[] memory) {
    return mocBuckets[bucket].activeBalances;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddressesCount(bytes32 bucket) public view returns(uint256 count) {
    return mocBuckets[bucket].activeBalancesLength;
  }

  /**
    @dev Add values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function addValuesToBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.add(btc);
    bucket.nDoc = bucket.nDoc.add(doc);
    bucket.nBPro = bucket.nBPro.add(bprox);
  }

  /**
    @dev Substract values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function substractValuesFromBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender)  {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.sub(btc);
    bucket.nDoc = bucket.nDoc.sub(doc);
    bucket.nBPro = bucket.nBPro.sub(bprox);
  }

  /**
    @dev Moves BTC from inrateBag to main BTC bucket bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
   */
  function deliverInrate(bytes32 bucketName, uint256 amount) public
   onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toMove = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toMove);
    bucket.nBTC = bucket.nBTC.add(toMove);
  }

  /**
    @dev Removes Interests rate from Inrate bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
    @return Retrieved value
   */
  function recoverInrate(bytes32 bucketName, uint256 amount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) returns(uint256) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toRetrieve = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toRetrieve);

    return toRetrieve;
  }

  /**
    @dev Moves BTC from origin bucket to destination bucket inrateBag
    @param bucketName name of the bucket to from which takes
    @param btcAmount value to add to main bag [using reservePrecision]
  */
  function payInrate(bytes32 bucketName, uint256 btcAmount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.inrateBag = bucket.inrateBag.add(btcAmount);
  }

  /**
    @dev Move Btcs and Docs from one bucket to another
    @param from Name of bucket from where the BTCs will be removed
    @param to Name of bucket from where the BTCs will be added
    @param btc BTCs amount [using reservePrecision]
    @param docs Docs amount [using mocPrecision]
  */
  function moveBtcAndDocs(bytes32 from, bytes32 to, uint256 btc, uint256 docs) public
  onlyWhitelisted(msg.sender) bucketStateUpdate(from) bucketStateUpdate(to) {
    MoCBucket storage bucketFrom = mocBuckets[from];
    MoCBucket storage bucketTo = mocBuckets[to];

    bucketFrom.nBTC = bucketFrom.nBTC.sub(btc);
    bucketTo.nBTC = bucketTo.nBTC.add(btc);

    bucketFrom.nDoc = bucketFrom.nDoc.sub(docs);
    bucketTo.nDoc = bucketTo.nDoc.add(docs);

    emit BucketMovement(from, to, btc, docs);
  }

  /**
    @dev Clears completely the origin bucket, removing all Docs, RBTCs and bproxs
    @param toLiquidate Bucket to be cleared out
    @param destination Bucket that will receive the Docs and RBTCs
   */
  function liquidateBucket(bytes32 toLiquidate, bytes32 destination) public onlyWhitelisted(msg.sender) {
    require(!isBucketBase(toLiquidate), "Cannot liquidate a base bucket");

    clearBucketBalances(toLiquidate);
    emptyBucket(toLiquidate, destination);
  }

  /**
    @dev Clears Docs and BTC from bucket origin and sends them to destination bucket
    @param origin Bucket to clear out
    @param destination Destination bucket
  */
  function emptyBucket(bytes32 origin, bytes32 destination) public onlyWhitelisted(msg.sender) {
    moveBtcAndDocs(origin, destination, mocBuckets[origin].nBTC, mocBuckets[origin].nDoc);
  }

  /**
   * @dev checks if a bucket exists
   * @param bucket name of the bucket
   */
  function isAvailableBucket(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].available;
  }

  /**
    @dev Put all bucket BProx balances in zero
    @param bucketName Bucket to clear out
   */
  function clearBucketBalances(bytes32 bucketName) public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.nBPro = 0;
    bucket.activeBalancesLength = 0;
  }

  /**
    @dev Creates bucket
    @param name Name of the bucket
    @param cobj Target Coverage of the bucket
    @param isBase Indicates if it is a base bucket (true) or not (false)
  */
  function createBucket(bytes32 name, uint256 cobj, bool isBase) internal {
    mocBuckets[name].name = name;
    mocBuckets[name].nDoc = 0;
    mocBuckets[name].nBPro = 0;
    mocBuckets[name].nBTC = 0;
    mocBuckets[name].cobj = cobj;
    mocBuckets[name].isBase = isBase;
    mocBuckets[name].available = true;
    emit BucketCreation(name, cobj);
  }

  modifier onlyBaseBucket(bytes32 bucket) {
    require(isBucketBase(bucket), "Bucket should be a base type bucket");
    _;
  }

  modifier bucketStateUpdate(bytes32 bucket) {
    _;
    emit BucketStateUpdate(
      bucket,
      mocBuckets[bucket].nBTC,
      mocBuckets[bucket].nDoc,
      mocBuckets[bucket].nBPro,
      mocBuckets[bucket].inrateBag
      );
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/MoCBProxManager.sol

pragma solidity ^0.5.8;




contract MoCBProxManager is MoCBucketContainer {
  using SafeMath for uint256;
  uint256 constant MIN_ALLOWED_BALANCE = 0;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
    @param _c0Cobj Bucket C0 objective coverage
    @param _x2Cobj Bucket X2 objective coverage
  */
  function initialize(
    address connectorAddress,
    address _governor,
    uint256 _c0Cobj,
    uint256 _x2Cobj
  ) public initializer {
    initializeBase(connectorAddress);
    initializeValues(_governor);
    createBucket(BUCKET_C0, _c0Cobj, true);
    createBucket(BUCKET_X2, _x2Cobj, false);
  }

  /**
    @dev returns user balance
    @param bucket BProx corresponding bucket to get balance from
    @param userAddress user address to get balance from
    @return total balance for the userAddress
  */
  function bproxBalanceOf(bytes32 bucket, address userAddress) public view returns(uint256) {
    BProxBalance memory userBalance = mocBuckets[bucket].bproxBalances[userAddress];
    if (!hasValidBalance(bucket, userAddress, userBalance.index)) return 0;
    return userBalance.value;
  }

  /**
    @dev verifies that this user has assigned balance for the given bucket
    @param bucket corresponding Leveraged bucket to get balance from
    @param userAddress user address to verify balance for
    @param index index, starting from 1, where the address of the user is being kept
    @return true if the user has assigned balance
  */
  function hasValidBalance(bytes32 bucket, address userAddress, uint index) public view returns(bool) {
    return (index != 0) &&
      (index <= getActiveAddressesCount(bucket)) &&
      (mocBuckets[bucket].activeBalances[index - 1] == userAddress);
  }

  /**
    @dev  Assigns the amount of BProx
    @param bucket bucket from which the BProx will be removed
    @param account user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function assignBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, account);

    setBProxBalanceOf(bucket, account, currentBalance.add(bproxAmount));
    addValuesToBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev Removes the amount of BProx and substract BTC cost from bucket
    @param bucket bucket from which the BProx will be removed
    @param userAddress user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function removeBProx(bytes32 bucket, address payable userAddress, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, userAddress);

    setBProxBalanceOf(bucket, userAddress, currentBalance.sub(bproxAmount));
    substractValuesFromBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev Sets the amount of BProx
    @param bucket bucket from which the BProx will be setted
    @param userAddress user address to redeem for
    @param value bprox amount to redeem [using mocPresicion]
  */
  function setBProxBalanceOf(bytes32 bucket, address payable userAddress, uint256 value) public onlyWhitelisted(msg.sender) {
    mocBuckets[bucket].bproxBalances[userAddress].value = value;
    uint256 index = mocBuckets[bucket].bproxBalances[userAddress].index;
    if (!hasValidBalance(bucket, userAddress, index))
      index = 0;

    bool hasBalance = value > MIN_ALLOWED_BALANCE;
    // The address is not in the array
    if (index == 0) {
      if (hasBalance) {
        if (mocBuckets[bucket].activeBalances.length == mocBuckets[bucket].activeBalancesLength) {
          mocBuckets[bucket].activeBalances.length += 1;
        }
        uint256 currentIndex = mocBuckets[bucket].activeBalancesLength++;
        mocBuckets[bucket].activeBalances[currentIndex] = userAddress;
        mocBuckets[bucket].bproxBalances[userAddress].index = mocBuckets[bucket].activeBalancesLength;
      }
    } else {
      if (!hasBalance) {
        // We need to delete this address from the tracker
        uint256 lastActiveIndex = mocBuckets[bucket].activeBalancesLength;
        address payable keyToMove = mocBuckets[bucket].activeBalances[lastActiveIndex - 1];
        mocBuckets[bucket].activeBalances[index - 1] = keyToMove;
        // Alternative index and array decreases lenght to prevent gas limit
        mocBuckets[bucket].activeBalancesLength--;
        // Update moved key index
        mocBuckets[bucket].bproxBalances[keyToMove].index = index;
        // Disable empty account index (0 == NULL)
        mocBuckets[bucket].bproxBalances[userAddress].index = 0;
      }
    }
  }

  /**
   @dev intializes values of the contract
   @param _governor Governor contract address
  */
  function initializeValues(address _governor) internal {
    governor = IGovernor(_governor);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/interface/IMoCState.sol

pragma solidity ^0.5.8;

interface IMoCState {

     /******STATE MACHINE*********/
    enum States {
        // State 0
        Liquidated,
        // State 1
        BProDiscount,
        // State 2
        BelowCobj,
        // State 3
        AboveCobj
    }


    function addToRbtcInSystem(uint256 btcAmount) external;

    function subtractRbtcFromSystem(uint256 btcAmount) external;

    function coverage(bytes32 bucket) external view returns(uint256);

    function getRbtcRemainder() external view returns(uint256);

    function liq() external view returns(uint256);

    function state() external view returns(States);

    function peg() external view returns(uint256);

    function dayBlockSpan() external view returns(uint256);

    function getBitcoinPrice() external view returns(uint256);

    function getMoCPrice() external view returns(uint256);

    function getProtected() external view returns(uint256);

    function globalCoverage() external view returns(uint256);

    function getMoCVendors() external view returns(address);

    function getMoCToken() external view returns(address);

    function nextState() external;

    function maxBProWithDiscount() external view returns(uint256);

    function absoluteMaxBPro() external view returns(uint256);

    function absoluteMaxDoc() external view returns(uint256);

    function freeDoc() external view returns(uint256);

    function bproTecPrice() external view returns(uint256);

    function bproSpotDiscountRate() external view returns(uint256);

    function bproDiscountPrice() external view returns(uint256);

    function bucketBProTecPrice(bytes32 bucket) external view returns(uint256);

    function currentAbundanceRatio() external view returns(uint256);

    function abundanceRatio(uint256 doc0) external view returns(uint256);

    function daysToSettlement() external view returns(uint256);

    function leverage(bytes32 bucket) external view returns(uint256);

    function getBucketNBTC(bytes32 bucket) external view returns(uint256);

    function getLiquidationPrice() external view returns(uint256);

    function maxBProxBtcValue(bytes32 bucket) external view returns(uint256);

    function bucketBProTecPriceHelper(bytes32 bucket) external view returns(uint256);

    // Ex Mocconverter
    function docsToBtc(uint256 docAmount) external view returns(uint256);
    function btcToDoc(uint256 btcAmount) external view returns(uint256);
    function bproxToBtc(uint256 bproxAmount, bytes32 bucket) external view returns(uint256);
    function btcToBProx(uint256 btcAmount, bytes32 bucket) external view returns(uint256);


}

// File: contracts/MoCHelperLib.sol

pragma solidity ^0.5.8;


library MoCHelperLib {

  struct MocLibConfig {
    uint256 reservePrecision;
    uint256 dayPrecision;
    uint256 mocPrecision;
  }

  using SafeMath for uint256;

  uint256 constant UINT256_MAX = ~uint256(0);

  /**
    @dev Returns max uint256 value constant.
    @return max uint256 value constant
  */
  function getMaxInt(MocLibConfig storage /*config*/) public pure returns(uint256) {
    return UINT256_MAX;
  }

  /**
    @dev Calculates average interest using integral function: T =  Rate = a * (x ** b) + c
    @param tMax maxInterestRate [using mocPrecision]
    @param power factor [using noPrecision]
    @param tMin minInterestRate C0 doc amount [using mocPrecision]
    @param abRat1 initial abundance ratio [using mocPrecision]
    @param abRat2 final abundance ratio [using mocPrecision]
    @return average interest rate [using mocPrecision]
  */
  function inrateAvg(MocLibConfig storage config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRat1, uint256 abRat2)
  public view returns(uint256) {
    require(tMax > tMin, "Max inrate should be bigger than Min inrate");
    uint256 abRat1Comp = config.mocPrecision.sub(abRat1);
    uint256 abRat2Comp = config.mocPrecision.sub(abRat2);

    if (abRat1 == abRat2) {
      return potential(config, tMax, power, tMin, abRat1Comp);
    }
    else if (abRat2 < abRat1) {
      return avgInt(config, tMax, power, tMin, abRat1Comp, abRat2Comp);
    }
    else {
      return avgInt(config, tMax, power, tMin, abRat2Comp, abRat1Comp);
    }
  }

  /**
    @dev Calculates spot interest rate that BProx owners should pay to BPro owners: Rate = tMax * (abRatio ** power) + tMin
    @param tMin min interest rate [using mocPrecision]
    @param power power to use in the formula [using NoPrecision]
    @param tMax max interest rate [using mocPrecision]
    @param abRatio bucket C0  abundance Ratio [using mocPrecision]
   */
  function spotInrate(
    MocLibConfig storage config, uint256 tMax, uint256 power, uint256 tMin, uint256 abRatio
  ) public view returns(uint256) {
    uint256 abRatioComp = config.mocPrecision.sub(abRatio);

    return potential(config, tMax, power, tMin, abRatioComp);
  }

  /**
    @dev Calculates potential interests function with given parameters: Rate = a * (x ** b) + c
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value global doc amount [using mocPrecision]
  */
  function potential(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    // value ** b
    // [MOC] ** [] = [MOC]
    uint256 aux1 = pow(value, b, config.mocPrecision);
    // (a * aux1) + c
    // [MOC] [MOC] / [MOC] + [MOC] = [MOC]
    return a.mul(aux1).div(config.mocPrecision).add(c);
  }

  /**
    @dev Calculates average of the integral function:
     T = (
              (c * xf + ((a * (xf ** (b + 1))) / (b + 1))) -
              (c * xi + ((a * (xi ** (b + 1))) / (b + 1)))
             ) / (xf - xi)
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value1 value to put in the function [using mocPrecision]
    @param value2 value to put in the function [using mocPrecision]
    @return average interest rate [using mocPrecision]
  */
  function avgInt(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value1, uint256 value2)
  public view returns(uint256) {
    // value2 - value1
    // [MOC]
    uint256 diff = value2.sub(value1);
    // ((c * (1 - value1) + ((a * ((1 - value1) ** (b + 1))) / (b + 1)))
    uint256 intV1 = integral(config, a, b, c, value1);
    // ((c * (1 - value2) + ((a * ((1 - value2) ** (b + 1))) / (b + 1)))
    uint256 intV2 = integral(config,  a, b, c, value2);
    // (secOp - first) / diff
    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return intV2.sub(intV1).div(diff);
  }

  /**
    @dev Calculates integral of the exponential function: T = c * (value) + (a * value ** (b + 1)) / (b + 1))
    @param a maxInterestRate [using mocPrecision]
    @param b factor [using NoPrecision]
    @param c minInterestRate C0 doc amount [using mocPrecision]
    @param value value to put in the function [using mocPrecision]
    @return integration result [using mocPrecision]
  */
  function integral(MocLibConfig storage config, uint256 a, uint256 b, uint256 c, uint256 value)
  public view returns(uint256) {
    // b + 1
    // [NONE]
    uint256 b2 = b.add(1);
    // c * value
    // [MOC][MOC]
    uint256 firstOp = c.mul(value);
    // [MOC]
    uint256 pow = pow(value, b2, config.mocPrecision);
    // (a * value ** b2) / b2)
    // [MOC][MOC]
    uint256 secOp = a.mul(pow).div(b2);
    // (firstOp + secOp)
    // [MOC][MOC] + [MOC][MOC] = [MOC][MOC]
    return firstOp.add(secOp);
  }

  /**
  * @dev Relation between docs in bucket 0 and Doc total supply
  * @param doc0 doc count in bucket 0 [using mocPrecision]
  * @param doct total doc supply [using mocPrecision]
  * @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(MocLibConfig storage config, uint256 doc0, uint256 doct)
  public view returns(uint256) {
    if (doct == 0) {
      return config.mocPrecision;
    }
    // [DOC] [MOC] / [DOC] = [MOC]
    return doc0.mul(config.mocPrecision).div(doct);
  }

  /**
    @dev Returns the Ratio to apply to BPro Price in discount situations: SpotDiscountRate = TPD * (utpdu - cob) / (uptdu -liq)
    @param bproLiqDiscountRate Discount rate applied at Liquidation level coverage [using mocPrecision]
    @param liq Liquidation coverage threshold [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param cov Actual global Coverage threshold [using mocPrecision]
    @return Spot discount rate [using mocPrecision]
  */
  function bproSpotDiscountRate(
    MocLibConfig storage libConfig, uint256 bproLiqDiscountRate,
    uint256 liq, uint256 utpdu, uint256 cov
  ) public view returns(uint256) {
    require(bproLiqDiscountRate < libConfig.mocPrecision, "Discount rate should be lower than 1");

    if (cov >= utpdu) {
      return 0;
    }

    // utpdu - liq
    // [MOC] - [MOC] = [MOC]
    uint256 utpduLiqDiff = utpdu.sub(liq);

    // utpdu - cov
    // [MOC] - [MOC] = [MOC]
    uint256 utpduCovDiff = utpdu.sub(cov);

    // TPD * utpduCovDiff / utpduLiqDiff
    // [MOC] * [MOC] / [MOC] = [MOC]
    return bproLiqDiscountRate.mul(utpduCovDiff).div(utpduLiqDiff);
  }

  /**
    @dev Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)
    @param nB Total BTC amount [using reservePrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @param spotDiscount spot discount [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  */
  function maxBProWithDiscount(
    MocLibConfig storage libConfig, uint256 nB, uint256 nDoc, uint256 utpdu,
    uint256 peg, uint256 btcPrice, uint256 bproUsdPrice, uint256 spotDiscount
  ) public view returns(uint256)  {
    require(spotDiscount < libConfig.mocPrecision, "Discount Rate should be lower than 1");

    if (spotDiscount == 0) {
      return 0;
    }

    // nBTC * B
    // [RES] * [MOC] / [RES] = [MOC]
    uint256 nbUsdValue = nB.mul(btcPrice).div(libConfig.reservePrecision);

    // (TPusd * (1 - TPD))
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 bproDiscountPrice = bproUsdPrice.mul(libConfig.mocPrecision.sub(spotDiscount))
      .div(libConfig.mocPrecision);

    return maxBProWithDiscountAux(libConfig, nbUsdValue, nDoc, utpdu, peg, bproDiscountPrice);
  }

  /**
    @dev Max amount of BPro to available with discount: MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)
    @param nbUsdValue Total amount of BTC in USD [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param bproDiscountPrice bproUsdPrice with discount applied [using mocPrecision]
    @param peg peg value
    @return Total BPro amount [using mocPrecision]
  */
  function maxBProWithDiscountAux(
    MocLibConfig storage libConfig, uint256 nbUsdValue, uint256 nDoc,
    uint256 utpdu, uint256 peg, uint256 bproDiscountPrice
  ) internal view returns(uint256) {

    // uTPDU * nDOC * PEG
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 coverageUSDAmount = utpdu.mul(nDoc).mul(peg).div(libConfig.mocPrecision);

    // This case only occurs with Coverage below 1
    if (coverageUSDAmount <= nbUsdValue) {
      return 0;
    }

    // ([MOC] - [MOC]) * [RES] / [MOC] = [RES]
    return coverageUSDAmount.sub(nbUsdValue).mul(libConfig.reservePrecision).div(bproDiscountPrice);
  }

  /**
    @dev Calculates Locked bitcoin
    @param btcPrice BTC price [using mocPrecision]
    @param nDoc Docs amount [using mocPrecision]
    @param peg peg value
    @return Locked bitcoin [using reservePrecision]
  */
  function lockedBitcoin(
    MocLibConfig storage libConfig, uint256 btcPrice, uint256 nDoc, uint256 peg
  ) public view returns(uint256) {
    return nDoc.mul(peg).mul(libConfig.reservePrecision).div(btcPrice);
  }

  /**
    @dev Calculates price at liquidation event as a relation between the doc total supply
    and the amount of RBTC available to distribute
    @param rbtcAmount RBTC to distribute [using reservePrecision]
    @param nDoc Docs amount [using mocPrecision]
    @return Price at liquidation event [using mocPrecision]
  */
  function liquidationPrice(MocLibConfig storage libConfig, uint256 rbtcAmount, uint256 nDoc)
  public view returns(uint256) {
    // [MOC] * [RES] / [RES]
    return nDoc.mul(libConfig.reservePrecision).div(rbtcAmount);
  }

  /**
    @dev Calculates BPro BTC price: TPbtc = (nB-LB) / nTP
    @param nB Total BTC amount [using reservePrecision]
    @param lb Locked bitcoins amount [using reservePrecision]
    @param nTP BPro amount [using mocPrecision]
    @return BPro BTC price [using reservePrecision]
  */
  function bproTecPrice(MocLibConfig storage libConfig, uint256 nB, uint256 lb, uint256 nTP)
    public view returns(uint256) {
    // Liquidation happens before this condition turns true
    if (nB < lb) {
      return 0;
    }

    if (nTP == 0) {
      return libConfig.mocPrecision;
    }
    // ([RES] - [RES]) * [MOC] / [MOC]
    return nB.sub(lb).mul(libConfig.mocPrecision).div(nTP);
  }

  /**
    @dev Calculates BPro BTC price: BProxInBPro = bproxTecPrice / bproPrice
    @param bproxTecPrice BProx BTC price [using reservePrecision]
    @param bproPrice Trog BTC price [using reservePrecision]
    @return BProx price in BPro [using mocPrecision]
  */
  function bproxBProPrice(
    MocLibConfig storage libConfig, uint256 bproxTecPrice, uint256 bproPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [RES] = [MOC]
    return bproxTecPrice.mul(libConfig.mocPrecision).div(bproPrice);
  }

  /**
    @dev Returns a new value with the discountRate applied: TPbtc = (price)* (1 - discountRate)
    @param price Price [using SomePrecision]
    @param discountRate Discount rate to apply [using mocPrecision]
    @return Price with discount applied [using SomePrecision]
  */
  function applyDiscountRate(MocLibConfig storage libConfig, uint256 price, uint256 discountRate)
    public view returns(uint256) {

    uint256 discountCoeff = libConfig.mocPrecision.sub(discountRate);

    return price.mul(discountCoeff).div(libConfig.mocPrecision);
  }

  /**
    @dev Returns the amount of interest to pay: TPbtc = price * interestRate
    @param value Cost to apply interest [using SomePrecision]
    @param interestRate Interest rate to apply [using mocPrecision]
    @return Interest cost based on the value and interestRate [using SomePrecision]
  */
  function getInterestCost(MocLibConfig storage libConfig, uint256 value, uint256 interestRate)
    public view returns(uint256) {
    // [ORIGIN] * [MOC] / [MOC] = [ORIGIN]
    return value.mul(interestRate).div(libConfig.mocPrecision);
  }

  /**
    @dev Calculates Coverage: Coverage = nB / LB
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Coverage [using mocPrecision]
  */
  function coverage(MocLibConfig storage libConfig, uint256 nB, uint256 lB) public view
    returns(uint256) {
    if (lB == 0) {
      return UINT256_MAX;
    }

    return nB.mul(libConfig.mocPrecision).div(lB);
  }

 /**
    @dev Calculates Leverage from Coverage: Leverage = C / (C - 1)
    @param cov Coverage [using mocPrecision]
    @return Leverage [using mocPrecision]
  */
  function leverageFromCoverage(MocLibConfig storage libConfig, uint256 cov)
  public view returns(uint256) {
    if (cov == UINT256_MAX) {
      return libConfig.mocPrecision;
    }

    if (cov <= libConfig.mocPrecision) {
      return UINT256_MAX;
    }

    return cov.mul(libConfig.mocPrecision).div(cov.sub(libConfig.mocPrecision));
  }

 /**
    @dev Calculates Leverage: Leverage = nB / (nB - lB)
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Leverage [using mocPrecision]
  */
  function leverage(MocLibConfig storage libConfig, uint256 nB,uint256 lB)
  public view returns(uint256) {
    if (lB == 0) {
      return libConfig.mocPrecision;
    }

    if (nB <= lB) {
      return UINT256_MAX;
    }

    return nB.mul(libConfig.mocPrecision).div(nB.sub(lB));
  }

  /**
    @dev Price in BTC of the amount of Docs
    @param amount Total BTC amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Total value [using reservePrecision]
  */
  function docsBtcValue(
    MocLibConfig storage libConfig, uint256 amount,uint256 peg, uint256 btcPrice
  ) public view returns(uint256) {
    require(btcPrice > 0,"Bitcoin price should be more than zero");
    require(libConfig.reservePrecision > 0, "Precision should be more than zero");
    //Total = amount / satoshi price
    //Total = amount / (btcPrice / precision)
    // [RES] * [MOC] / [MOC]
    uint256 docBtcTotal = amount.mul(libConfig.mocPrecision).mul(peg).div(btcPrice);

    return docBtcTotal;
  }

 /**
    @dev Price in RBTC of the amount of BPros
    @param bproAmount amount of BPro [using mocPrecision]
    @param bproBtcPrice BPro price in RBTC [using reservePrecision]
    @return Total value [using reservePrecision]
  */
  function bproBtcValue(MocLibConfig storage libConfig, uint256 bproAmount, uint256 bproBtcPrice)
    public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Precision should be more than zero");

    // [MOC] * [RES] / [MOC] =  [RES]
    uint256 bproBtcTotal = bproAmount.mul(bproBtcPrice).div(libConfig.mocPrecision);

    return bproBtcTotal;
  }

  /**
    @dev Max amount of Docs to issue: MaxDoc = ((nB*B)-(Cobj*B/Bcons*nDoc*PEG))/(PEG*(Cobj*B/BCons-1))
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @return Total Docs amount [using mocPrecision]
  */
  function maxDoc(
    MocLibConfig storage libConfig, uint256 nB,
    uint256 cobj, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons
  ) public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    // If cobj is less than 1, just return zero
    if (cobj < libConfig.mocPrecision)
      return 0;

    // Cobj * B / BCons
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 adjCobj = cobj.mul(btcPrice).div(bCons);

    return maxDocAux(libConfig, nB, adjCobj, nDoc, peg, btcPrice);
  }

  function maxDocAux(MocLibConfig storage libConfig, uint256 nB, uint256 adjCobj, uint256 nDoc, uint256 peg, uint256 btcPrice)
  internal view returns(uint256) {
    // (nB*B)
    // [RES] [MOC] [MOC] / [RES] = [MOC] [MOC]
    uint256 firstOperand = nB.mul(btcPrice).mul(libConfig.mocPrecision).div(libConfig.reservePrecision);
    // (adjCobj*nDoc*PEG)
    // [MOC] [MOC]
    uint256 secOperand = adjCobj.mul(nDoc).mul(peg);
    // (PEG*(adjCobj-1)
    // [MOC]
    uint256 denom = adjCobj.sub(libConfig.mocPrecision).mul(peg);

    if (firstOperand <= secOperand)
      return 0;

    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return (firstOperand.sub(secOperand)).div(denom);
  }

  /**
    @dev Max amount of BPro to redeem: MaxBPro = ((nB*B)-(Cobj*nDoc*PEG))/TPusd
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc Target Coverage [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  */
  function maxBPro(
    MocLibConfig storage libConfig, uint256 nB, uint256 cobj,
    uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 bCons, uint256 bproUsdPrice
  ) public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    // Cobj * btcPrice / BCons
    // [MOC] * [MOC] / [MOC] = [MOC]
    uint256 adjCobj = cobj.mul(btcPrice).div(bCons);
    // (nB * btcPrice)
    // [RES] * [MOC] * [MOC] / [RES] = [MOC] [MOC]
    uint256 firstOperand = nB.mul(btcPrice)
      .mul(libConfig.mocPrecision)
      .div(libConfig.reservePrecision);
    // (adjCobj * nDoc * PEG)
    // [MOC] * [MOC]
    uint256 secOperand = adjCobj.mul(nDoc).mul(peg);

    if (firstOperand <= secOperand)
      return 0;

    // ([MOC][MOC] - [MOC][MOC]) / [MOC] = [MOC]
    return (firstOperand.sub(secOperand)).div(bproUsdPrice);
  }

  /**
    @dev Calculates the total BTC price of the amount of BPros
    @param amount Amount of BPro [using mocPrecision]
    @param bproPrice BPro BTC Price [using reservePrecision]
    @return BPro total value in BTC [using reservePrecision]
  */
  function totalBProInBtc(
    MocLibConfig storage libConfig, uint256 amount, uint256 bproPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [MOC] = [RES]
    return bproPrice.mul(amount).div(libConfig.mocPrecision);
  }

  /**
    @dev Calculates the equivalent in Docs of the btcAmount
    @param btcAmount BTC  amount [using reservePrecision]
    @param btcPrice BTC price [using mocPrecision]
    @return Equivalent Doc amount [using mocPrecision]
  */
  function maxDocsWithBtc(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 btcPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [RES] = [MOC]
    return btcAmount.mul(btcPrice).div(libConfig.reservePrecision);
  }

  /**
    @dev Calculates the equivalent in BPro of the btcAmount
    @param btcAmount BTC amount [using reservePrecision]
    @param bproPrice BPro BTC price [using reservePrecision]
    @return Equivalent Bpro amount [using mocPrecision]
  */
  function maxBProWithBtc(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 bproPrice
  ) public view returns(uint256) {
    if (bproPrice == 0) {
      return 0;
    }

    // [RES] * [MOC] / [RES]
    return btcAmount.mul(libConfig.mocPrecision).div(bproPrice);
  }

  /**
    @dev Calculates the Btc amount to move from C0 bucket to: toMove = btcAmount * (lev - 1)
    an L bucket when a BProx minting occurs
    @param btcAmount Total BTC amount [using reservePrecision]
    @param lev L bucket leverage [using mocPrecision]
    @return btc to move [using reservePrecision]
  */
  function bucketTransferAmount(
    MocLibConfig storage libConfig, uint256 btcAmount, uint256 lev
  ) public view returns(uint256) {
    require(lev > libConfig.mocPrecision, "Leverage should be more than 1");

    if (lev == UINT256_MAX || btcAmount == 0) {
      return 0;
    }

    // (lev-1)
    uint256 levSubOne = lev.sub(libConfig.mocPrecision);

    // Intentionally avaoid SafeMath
    // [RES] * [MOC]
    uint256 transferAmount = btcAmount * levSubOne;
    if (transferAmount / btcAmount != levSubOne)
      return 0;

    // [RES] * [MOC] / [MOC] = [RES]
    return transferAmount.div(libConfig.mocPrecision);
  }

  /**
    @dev Max amount of BTC allowed to be used to mint bprox: Maxbprox = nDOC/ (PEG*B*(lev-1))
    @param nDoc number of DOC [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param lev leverage [using mocPrecision]
    @return Max bprox BTC value [using reservePrecision]
  */
  function maxBProxBtcValue(
    MocLibConfig storage libConfig, uint256 nDoc, uint256 peg, uint256 btcPrice, uint256 lev
  ) public view returns(uint256)  {
    require(libConfig.reservePrecision > 0, "Invalid Precision");
    require(libConfig.mocPrecision > 0, "Invalid Precision");

    if (lev <= libConfig.mocPrecision) {
      return 0;
    }
    // (lev-1)
    // [MOC]
    uint256 levSubOne = lev.sub(libConfig.mocPrecision);

    // PEG * BtcPrice
    // [MOC]
    uint256 pegTimesPrice = peg.mul(btcPrice);

    // This intentionally avoid using safeMath to handle overflow case
    // PEG * BtcPrice * (lev - 1)
    // [MOC] * [MOC]
    uint256 dividend = pegTimesPrice * levSubOne;

    if (dividend / pegTimesPrice != levSubOne)
      return 0; // INFINIT dividend means 0

    // nDoc adjusted with precisions
    // [MOC] [RES]
    uint256 divider = nDoc.mul(libConfig.reservePrecision);

    // [MOC] [RES] [MOC] / [MOC] [MOC]
    return divider.mul(libConfig.mocPrecision).div(dividend);
  }

  /**
    @dev Calculates the equivalent in MoC of the btcAmount
    @param btcAmount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  */
  function maxMoCWithBtc(
    MocLibConfig storage /*libConfig*/, uint256 btcAmount, uint256 btcPrice, uint256 mocPrice
  ) public pure returns(uint256) {
    return btcPrice.mul(btcAmount).div(mocPrice);
  }

  /**
    @dev Calculates the equivalent in BTC of the MoC amount
    @param amount BTC  amount
    @param btcPrice BTC price
    @param mocPrice MoC price
    @return Equivalent MoC amount
  */
  function mocBtcValue(
    MocLibConfig storage /*libConfig*/, uint256 amount, uint256 btcPrice, uint256 mocPrice
  ) public pure returns(uint256) {
    require(btcPrice > 0,"Bitcoin price should be more than zero");
    require(mocPrice > 0,"MoC price should be more than zero");

    uint256 mocBtcTotal = amount.mul(mocPrice).div(btcPrice);

    return mocBtcTotal;
  }

  /**
    @dev Transform an address to payable address
    @param account Address to transform to payable
    @return Payable address for account
  */
  function getPayableAddress(
    MocLibConfig storage /*libConfig*/, address account
  ) public pure
  returns (address payable) {
    return address(uint160(account));
  }

  /**
    @dev Rounding product adapted from DSMath but with custom precision
    @param x Multiplicand
    @param y Multiplier
    @return Product
  */
  function mulr(uint x, uint y, uint256 precision) internal pure returns (uint z) {
    return x.mul(y).add(precision.div(2)).div(precision);
  }

  /**
    @dev Potentiation by squaring adapted from DSMath but with custom precision
    @param x Base
    @param n Exponent
    @return power
  */
  function pow(uint256 x, uint256 n, uint256 precision) internal pure returns (uint z) {
    uint256 x2 = x;
    z = n % 2 != 0 ? x : precision;

    for (n /= 2; n != 0; n /= 2) {
      x2 = mulr(x2, x2, precision);

      if (n % 2 != 0) {
        z = mulr(z, x2, precision);
      }
    }
  }
}

// File: contracts/MoCLibConnection.sol

pragma solidity ^0.5.8;


/**
  @dev Interface with MocHelperLib
 */
contract MoCLibConnection {
  using MoCHelperLib for MoCHelperLib.MocLibConfig;
  MoCHelperLib.MocLibConfig internal mocLibConfig;

  /*
  * Precision getters
  */
  function getMocPrecision() public view returns(uint256) {
    return mocLibConfig.mocPrecision;
  }

  function getReservePrecision() public view returns(uint256) {
    return mocLibConfig.reservePrecision;
  }

  function getDayPrecision() public view returns(uint256) {
    return mocLibConfig.dayPrecision;
  }

  function initializePrecisions() internal {
    mocLibConfig = MoCHelperLib.MocLibConfig({
      reservePrecision: 10 ** 18,
      mocPrecision: 10 ** 18,
      dayPrecision: 1
    });
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: contracts/interface/IMoCSettlement.sol

pragma solidity ^0.5.8;

interface IMoCSettlement {
    function getRedeemRequestAt(uint256 _index) external view returns (address payable, uint256);

    function redeemQueueSize() external view returns (uint256);

    function docAmountToRedeem(address _who) external view returns (uint256);

    function addRedeemRequest(uint256 amount, address payable redeemer) external;

    function alterRedeemRequestAmount(bool isAddition, uint256 delta, address redeemer) external;

    function isSettlementEnabled() external view returns (bool);

    function runSettlement(uint256 steps) external returns (uint256);

    function isSettlementReady() external view returns (bool);

    function nextSettlementBlock() external view returns (uint256);
}

// File: contracts/interface/IMoCExchange.sol

pragma solidity ^0.5.8;

interface IMoCExchange {
    function getMoCTokenBalance(address owner, address spender) external view
    returns (uint256 mocBalance, uint256 mocAllowance);

    function mintBPro(address account, uint256 btcAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBPro(address account, uint256 bproAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function mintDoc(address account, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount, address vendorAccount)
    external returns (uint256, uint256, uint256, uint256, uint256);

    function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemFreeDoc(address account, uint256 docAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemAllDoc(address origin, address payable destination) external
    returns (uint256);

    function forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice)
    external returns (bool);

    function redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice) external
    returns (bool, uint256);
}

// File: moc-governance/contracts/Stopper/Stoppable.sol

pragma solidity ^0.5.8;



/**
  @title Stoppable
  @notice Allow a contract to be paused through the stopper subsystem. This contracts
  is able to disable the stoppability feature through governance.
  @dev This contract was heavily based on the _Pausable_ contract of openzeppelin-eth but
  it was modified in order to being able to turn on and off its stopability
 */
contract Stoppable is Governed {

  event Paused(address account);
  event Unpaused(address account);

  bool public stoppable;
  bool private _paused;
  address public stopper;
  string private constant UNSTOPPABLE = "unstoppable";
  string private constant CONTRACT_IS_ACTIVE = "contract_is_active";
  string private constant CONTRACT_IS_PAUSED = "contract_is_paused";
  string private constant NOT_STOPPER = "not_stopper";


  /**
    @notice Modifier to make a function callable only when the contract is enable
    to be paused
  */
  modifier whenStoppable() {
    require(stoppable, UNSTOPPABLE);
    _;
  }

  /**
    @notice Modifier to make a function callable only when the contract is not paused
  */
  modifier whenNotPaused() {
    require(!_paused, CONTRACT_IS_PAUSED);
    _;
  }

  /**
    @notice Modifier to make a function callable only when the contract is paused
    */
  modifier whenPaused() {
    require(_paused, CONTRACT_IS_ACTIVE);
    _;
  }

  /**
    @notice  Modifier to make a function callable only by the pauser
   */
  modifier onlyPauser() {
    require(stopper == msg.sender, NOT_STOPPER);
    _;
  }

  /**
    @notice Initialize the contract with the basic settings
    @dev This initialize replaces the constructor but it is not called automatically.
    It is necessary because of the upgradeability of the contracts. Either this function or the next can be used
    @param _stopper The address that is authorized to stop this contract
    @param _governor The address that will define when a change contract is authorized to do this unstoppable/stoppable again
   */
  function initialize(address _stopper, IGovernor _governor) public initializer {
    initialize(_stopper, _governor, true);
  }

  /**
    @notice Initialize the contract with the basic settings
    @dev This initialize replaces the constructor but it is not called automatically.
    It is necessary because of the upgradeability of the contracts. Either this function or the previous can be used
    @param _stopper The address that is authorized to stop this contract
    @param _governor The address that will define when a change contract is authorized to do this unstoppable/stoppable again
    @param _stoppable Define if the contract starts being unstoppable or not
   */
  function initialize(address _stopper, IGovernor _governor, bool _stoppable) public initializer {
    stoppable = _stoppable;
    stopper = _stopper;
    Governed.initialize(_governor);
  }

  /**
    @notice Returns true if paused
   */
  function paused() public view returns (bool) {
    return _paused;
  }
  /**
    @notice Called by the owner to pause, triggers stopped state
    @dev Should only be called by the pauser and when it is stoppable
   */
  function pause() public whenStoppable onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
    @notice Called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }


  /**
    @notice Switches OFF the stoppability of the contract; if the contract was paused
    it will no longer be so
    @dev Should be called through governance
   */
  function makeUnstoppable() public onlyAuthorizedChanger {
    stoppable = false;
  }


  /**
    @notice Switches ON the stoppability of the contract; if the contract was paused
    before making it unstoppable it will be paused again after calling this function
    @dev Should be called through governance
   */
  function makeStoppable() public onlyAuthorizedChanger {
    stoppable = true;
  }

  /**
    @notice Changes the address which is enable to stop this contract
    @param newStopper Address of the newStopper
    @dev Should be called through governance
   */
  function setStopper(address newStopper) public onlyAuthorizedChanger {
    stopper = newStopper;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interface/IMoCVendors.sol

pragma solidity ^0.5.8;

interface IMoCVendors {
    function resetTotalPaidInMoC() external;

    function getIsActive(address account) external view
    returns (bool);

    function getTotalPaidInMoC(address account) external view
    returns (uint256);

    function getStaking(address account) external view
    returns (uint256);

    function getMarkup(address account) external view
    returns (uint256);

    function updatePaidMarkup(address account, uint256 mocAmount, uint256 rbtcAmount) external
    returns(bool);
}

// File: contracts/interface/IMoCInrate.sol

pragma solidity ^0.5.8;

interface IMoCInrate {
    // Transaction types
    function MINT_BPRO_FEES_RBTC() external view returns(uint8);
    function REDEEM_BPRO_FEES_RBTC() external view returns(uint8);
    function MINT_DOC_FEES_RBTC() external view returns(uint8);
    function REDEEM_DOC_FEES_RBTC() external view returns(uint8);
    function MINT_BTCX_FEES_RBTC() external view returns(uint8);
    function REDEEM_BTCX_FEES_RBTC() external view returns(uint8);
    function MINT_BPRO_FEES_MOC() external view returns(uint8);
    function REDEEM_BPRO_FEES_MOC() external view returns(uint8);
    function MINT_DOC_FEES_MOC() external view returns(uint8);
    function REDEEM_DOC_FEES_MOC() external view returns(uint8);
    function MINT_BTCX_FEES_MOC() external view returns(uint8);
    function REDEEM_BTCX_FEES_MOC() external view returns(uint8);

    function dailyInratePayment() external returns(uint256);

    function payBitProHoldersInterestPayment() external returns(uint256);

    function calculateBitProHoldersInterest() external view returns(uint256, uint256);

    function getBitProInterestAddress() external view returns(address payable);

    function getBitProRate() external view returns(uint256);

    function getBitProInterestBlockSpan() external view returns(uint256);

    function isDailyEnabled() external view returns(bool);

    function isBitProInterestEnabled() external view returns(bool);

    function commissionsAddress() external view returns(address payable);

    function calcCommissionValue(uint256 rbtcAmount, uint8 txType) external view returns(uint256);

    function calculateVendorMarkup(address vendorAccount, uint256 amount) external view returns (uint256 markup);

    function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) external view returns(uint256);

    function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) external view returns(uint256);

    function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) external view returns(uint256);

    function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) external;
}

// File: contracts/interface/IMoC.sol

pragma solidity ^0.5.8;

interface IMoC {
    function() external payable;

    function sendToAddress(address payable receiver, uint256 btcAmount) external returns(bool);
}

// File: contracts/MoC.sol

pragma solidity ^0.5.8;















contract MoCEvents {
  event BucketLiquidation(bytes32 bucket);
  event ContractLiquidated(address mocAddress);
}

contract MoC is MoCEvents, MoCLibConnection, MoCBase, Stoppable, IMoC {
  using SafeMath for uint256;

  /// @dev Contracts.
  address internal docToken;
  address internal bproToken;
  MoCBProxManager internal bproxManager;
  IMoCState internal mocState;
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address internal DEPRECATED_mocConverter;
  IMoCSettlement internal settlement;
  IMoCExchange internal mocExchange;
  IMoCInrate internal mocInrate;
  /// @dev 'MoCBurnout' is deprecated. DO NOT use this variable.
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  address public DEPRECATED_mocBurnout;

  /// @dev Indicates if Rbtc remainder was sent and BProToken was paused
  bool internal liquidationExecuted;

  //TODO: We must research if fallback function is really needed.
  /**
    @dev Fallback function
  */
  function() external payable whenNotPaused() transitionState() {
    bproxManager.addValuesToBucket(BUCKET_C0, msg.value, 0, 0);
    mocState.addToRbtcInSystem(msg.value);
  }

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param governorAddress Governor contract address
    @param stopperAddress Stopper contract address
    @param startStoppable Indicates if the contract starts being unstoppable or not
  */
  function initialize(
    address connectorAddress,
    address governorAddress,
    address stopperAddress,
    bool startStoppable
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    //initializeContracts
    docToken = connector.docToken();
    bproToken = connector.bproToken();
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = IMoCState(connector.mocState());
    settlement = IMoCSettlement(connector.mocSettlement());
    mocExchange = IMoCExchange(connector.mocExchange());
    mocInrate = IMoCInrate(connector.mocInrate());
    //initializeGovernanceContracts
    Stoppable.initialize(stopperAddress, IGovernor(governorAddress), startStoppable);
  }

  /****************************INTERFACE*******************************************/

  /**
    @dev Gets the BProx balance of an address
    @param bucket Name of the bucket
    @param account Address
    @return BProx balance of the address
  */
  function bproxBalanceOf(bytes32 bucket, address account) public view returns(uint256) {
    return bproxManager.bproxBalanceOf(bucket, account);
  }

  /**
    @dev Gets the RedeemRequest at the queue index position
    @param index queue position to get
    @return redeemer's address and amount he submitted
  */
  function getRedeemRequestAt(uint256 index) public view returns(address, uint256) {
    return settlement.getRedeemRequestAt(index);
  }

  /**
    @dev Returns current redeem queue size
    @return redeem queue size
   */
  function redeemQueueSize() public view returns(uint256) {
    return settlement.redeemQueueSize();
  }

  /**
    @dev Returns the total amount of Docs in the redeem queue for redeemer
    @param redeemer address for which ^ is computed
    @return total amount of Docs in the redeem queue for redeemer
   */
  function docAmountToRedeem(address redeemer) public view returns(uint256) {
    return settlement.docAmountToRedeem(redeemer);
  }


  /**
  * @dev Creates or updates the amount of a Doc redeem Request from the msg.sender
  * @param docAmount Amount of Docs to redeem on settlement [using mocPrecision]
  */
  function redeemDocRequest(uint256 docAmount) public  whenNotPaused() whenSettlementReady() {
    settlement.addRedeemRequest(docAmount, msg.sender);
  }

  /**
    @dev Alters the redeem amount position for the redeemer
    @param isAddition true if adding amount to redeem, false to substract.
    @param delta the amount to add/substract to current position
  */
  function alterRedeemRequestAmount(bool isAddition, uint256 delta) public whenNotPaused() whenSettlementReady() {
    settlement.alterRedeemRequestAmount(isAddition, delta, msg.sender);
  }

  /**
    @dev Mints BPRO and pays the comissions of the operation (retrocompatible function).
    @dev Retrocompatible function.
    @param btcToMint Amount in BTC to mint
   */
  function mintBPro(uint256 btcToMint)
  public payable {
    mintBProVendors(btcToMint, address(0));
  }

  /**
    @dev Mints BPRO and pays the comissions of the operation.
    @param btcToMint Amount in BTC to mint
    @param vendorAccount Vendor address
   */
  function mintBProVendors(uint256 btcToMint, address payable vendorAccount)
  public payable
  whenNotPaused() transitionState() notInProtectionMode() {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintBPro(msg.sender, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems Bpro Tokens and pays the comissions of the operation (retrocompatible function).
    @param bproAmount Amount in Bpro
  */
  function redeemBPro(uint256 bproAmount)
  public {
    redeemBProVendors(bproAmount, address(0));
  }

  /**
    @dev Redeems Bpro Tokens and pays the comissions of the operation
    @param bproAmount Amount in Bpro
    @param vendorAccount Vendor address
  */
  function redeemBProVendors(uint256 bproAmount, address payable vendorAccount)
  public
  whenNotPaused() transitionState() atLeastState(IMoCState.States.AboveCobj) {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 btcAmount,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemBPro(msg.sender, bproAmount, vendorAccount);

    redeemWithCommission(
      msg.sender,
      btcAmount,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Mint Doc tokens and pays the commisions of the operation (retrocompatible function).
    @dev Retrocompatible function.
    @param btcToMint Amount in RBTC to mint
  */
  function mintDoc(uint256 btcToMint)
  public payable {
    mintDocVendors(btcToMint, address(0));
  }

  /**
   * @dev Mint Doc tokens and pays the commisions of the operation
   * @param btcToMint Amount in RBTC to mint
   * @param vendorAccount Vendor address
   */
  function mintDocVendors(uint256 btcToMint, address payable vendorAccount)
  public payable
  whenNotPaused() transitionState() atLeastState(IMoCState.States.AboveCobj) {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintDoc(msg.sender, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC (retrocompatible function).
    @dev Retrocompatible function.
    @param bucket Bucket to reedem, for example X2
    @param bproxAmount Amount in Bprox
  */
  function redeemBProx(bytes32 bucket, uint256 bproxAmount) public {
    redeemBProxVendors(bucket, bproxAmount, address(0));
  }

  /**
    @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC
    @param bucket Bucket to reedem, for example X2
    @param bproxAmount Amount in Bprox
    @param vendorAccount Vendor address
  */
  function redeemBProxVendors(bytes32 bucket, uint256 bproxAmount, address payable vendorAccount) public
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcRedeemed,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemBProx(msg.sender, bucket, bproxAmount, vendorAccount);

    redeemWithCommission(
      msg.sender,
      totalBtcRedeemed,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev BUCKET bprox minting (retrocompatible function).
    @dev Retrocompatible function.
    @param bucket Name of the bucket used
    @param btcToMint amount to mint on RBTC
  */
  function mintBProx(bytes32 bucket, uint256 btcToMint) public payable {
    mintBProxVendors(bucket, btcToMint, address(0));
  }

  /**
    @dev BUCKET bprox minting
    @param bucket Name of the bucket used
    @param btcToMint amount to mint on RBTC
    @param vendorAccount Vendor address
  */
  function mintBProxVendors(bytes32 bucket, uint256 btcToMint, address payable vendorAccount) public payable
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.mintBProx(msg.sender, bucket, btcToMint, vendorAccount);

    transferCommissions(
      msg.sender,
      msg.value,
      totalBtcSpent,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible (retrocompatible function).
    @dev Retrocompatible function.
    @param docAmount Amount of Docs to redeem.
  */
  function redeemFreeDoc(uint256 docAmount)
  public {
    redeemFreeDocVendors(docAmount, address(0));
  }

  /**
    @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible.
    @param docAmount Amount of Docs to redeem.
    @param vendorAccount Vendor address
  */
  function redeemFreeDocVendors(uint256 docAmount, address payable vendorAccount)
  public
  whenNotPaused() transitionState() notInProtectionMode() {
    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    (uint256 btcAmount,
    uint256 btcCommission,
    uint256 mocCommission,
    uint256 btcMarkup,
    uint256 mocMarkup) = mocExchange.redeemFreeDoc(msg.sender, docAmount, vendorAccount);

    redeemWithCommission(
      msg.sender,
      btcAmount,
      btcCommission,
      mocCommission,
      vendorAccount,
      btcMarkup,
      mocMarkup
    );
    /** END UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  }

  /**
    @dev Allow redeem on liquidation state, user DoCs get burned and he receives
    the equivalent BTCs if can be covered, or the maximum available
  */
  function redeemAllDoc() public atState(IMoCState.States.Liquidated) {
    mocExchange.redeemAllDoc(msg.sender, msg.sender);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public whenNotPaused() {
    mocInrate.dailyInratePayment();
  }

  /**
    @dev Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
    BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function payBitProHoldersInterestPayment() public whenNotPaused() {
    uint256 toPay = mocInrate.payBitProHoldersInterestPayment();
    if (doSend(mocInrate.getBitProInterestAddress(), toPay)) {
      bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
    }
  }

  /**
    @dev Calculates BitPro holders holder interest by taking the total amount of RBTCs available on Bucket 0.
    BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    return mocInrate.calculateBitProHoldersInterest();
  }

  /**
    @dev Gets the target address to transfer BitPro Holders rate
    @return Target address to transfer BitPro Holders interest
  */
  function getBitProInterestAddress() public view returns(address payable) {
    return mocInrate.getBitProInterestAddress();
  }

  /**
    @dev Gets the rate for BitPro Holders
    @return BitPro Rate
  */
  function getBitProRate() public view returns(uint256) {
    return mocInrate.getBitProRate();
  }

  /**
    @dev Gets the blockspan of BPRO that represents the frecuency of BitPro holders interest payment
    @return returns power of bitProInterestBlockSpan
  */
  function getBitProInterestBlockSpan() public view returns(uint256) {
    return mocInrate.getBitProInterestBlockSpan();
  }

  function isDailyEnabled() public view returns(bool) {
    return mocInrate.isDailyEnabled();
  }

  function isBitProInterestEnabled() public view returns(bool) {
    return mocInrate.isBitProInterestEnabled();
  }

  /**
    @dev Indicates if settlement is enabled
    @return Returns true if blockSpan number of blocks has passed since last execution; otherwise false
  */
  function isSettlementEnabled() public view returns(bool) {
    return settlement.isSettlementEnabled();
  }

  /**
    @dev Checks if bucket liquidation is reached.
    @param bucket Name of bucket.
    @return true if bucket liquidation is reached, false otherwise
  */
  function isBucketLiquidationReached(bytes32 bucket) public view returns(bool) {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      return true;
    }
    return false;
  }

  function evalBucketLiquidation(bytes32 bucket) public availableBucket(bucket) notBaseBucket(bucket) whenSettlementReady() {
    if (isBucketLiquidationReached(bucket)) {
      bproxManager.liquidateBucket(bucket, BUCKET_C0);

      emit BucketLiquidation(bucket);
    }
  }

  /**
    @dev Evaluates if liquidation state has been reached and runs liq if that's the case
  */
  function evalLiquidation() public transitionState() {
    // DO NOTHING. Everything is handled in transitionState() modifier.
  }

  /**
    @dev Runs all settlement process
    @param steps Number of steps
  */
  function runSettlement(uint256 steps) public whenNotPaused() transitionState() {
    // Transfer accums commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), settlement.runSettlement(steps));
  }

  /**
    @dev Send RBTC to a user and update RbtcInSystem in MoCState
    @param receiver address of receiver
    @param btcAmount amount to transfer
    @return result of the transaction
  */
  function sendToAddress(address payable receiver, uint256 btcAmount) public onlyWhitelisted(msg.sender) returns(bool) {
    if (btcAmount == 0) {
      return true;
    }
    return doSend(receiver, btcAmount);
  }

  function liquidate() internal {
    if (!liquidationExecuted) {
      //pauseBProToken
      if (!Pausable(bproToken).paused()) {
        Pausable(bproToken).pause();
      }
      //sendRbtcRemainder
      doTransfer(mocInrate.commissionsAddress(), mocState.getRbtcRemainder());
      liquidationExecuted = true;

      emit ContractLiquidated(connector.moc());
    }
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

  /**
    @dev Transfer mint operation fees (commissions + vendor markup)
    @param sender address of msg.sender
    @param value amount of msg.value
    @param totalBtcSpent amount in RBTC spent
    @param btcCommission commission amount in RBTC
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param btcMarkup vendor markup in RBTC
    @param mocMarkup vendor markup in MoC
  */
  // solium-disable-next-line security/no-assign-params
  function transferCommissions(
    address payable sender,
    uint256 value,
    uint256 totalBtcSpent,
    uint256 btcCommission,
    uint256 mocCommission,
    address payable vendorAccount,
    uint256 btcMarkup,
    uint256 mocMarkup
  )
  internal {
    uint256 totalBtcWithFees = totalBtcSpent;
    if (mocCommission.add(mocMarkup) == 0) {
      totalBtcWithFees = totalBtcSpent.add(btcCommission).add(btcMarkup);
    }
    require(totalBtcWithFees <= value, "amount is not enough");

    // Need to update general State
    mocState.addToRbtcInSystem(totalBtcSpent);

    transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup);

    transferBtcCommission(vendorAccount, btcCommission, btcMarkup);

    // Calculate change
    sender.transfer(value.sub(totalBtcWithFees));
  }

  /**
    @dev Transfer operation fees in MoC (commissions + vendor markup)
    @param sender address of msg.sender
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param mocMarkup vendor markup in MoC
  */
  // solium-disable-next-line security/no-assign-params
  function transferMocCommission(
    address sender,
    uint256 mocCommission,
    address vendorAccount,
    uint256 mocMarkup
  ) internal {
    // If commission and markup are paid in MoC
    uint256 totalMoCFee = mocCommission.add(mocMarkup);
    if (totalMoCFee > 0) {
      IMoCVendors mocVendors = IMoCVendors(mocState.getMoCVendors());
      // Transfer MoC from sender to this contract
      IERC20 mocToken = IERC20(mocState.getMoCToken());

      // Transfer vendor markup in MoC
      if (mocVendors.updatePaidMarkup(vendorAccount, mocMarkup, 0)) {
        // Transfer MoC to vendor address
        mocToken.transferFrom(sender, vendorAccount, mocMarkup);
        // Transfer MoC to commissions address
        mocToken.transferFrom(sender, mocInrate.commissionsAddress(), mocCommission);
      } else {
        // Transfer MoC to commissions address
        mocToken.transferFrom(sender, mocInrate.commissionsAddress(), totalMoCFee);
      }
    }
  }

  /**
    @dev Transfer redeem operation fees (commissions + vendor markup)
    @param sender address of msg.sender
    @param btcCommission commission amount in RBTC
    @param mocCommission commission amount in MoC
    @param vendorAccount address of vendor
    @param btcMarkup vendor markup in RBTC
    @param mocMarkup vendor markup in MoC
  */
  function redeemWithCommission(
    address payable sender,
    uint256 btcAmount,
    uint256 btcCommission,
    uint256 mocCommission,
    address payable vendorAccount,
    uint256 btcMarkup,
    uint256 mocMarkup
  )
   internal {
    mocState.subtractRbtcFromSystem(btcAmount.add(btcMarkup).add(btcCommission));

    transferMocCommission(sender, mocCommission, vendorAccount, mocMarkup);

    transferBtcCommission(vendorAccount, btcCommission, btcMarkup);

    sender.transfer(btcAmount);
  }

  /**
    @dev Transfer operation fees in RBTC (commissions + vendor markup)
    @param vendorAccount address of vendor
    @param btcCommission commission amount in RBTC
    @param btcMarkup vendor markup in RBTC
  */
  function transferBtcCommission(address payable vendorAccount, uint256 btcCommission, uint256 btcMarkup) internal {

    uint256 totalBtcFee = btcCommission.add(btcMarkup);

    if (totalBtcFee > 0) {
      IMoCVendors mocVendors = IMoCVendors(mocState.getMoCVendors());
      // Transfer vendor markup in MoC
      if (mocVendors.updatePaidMarkup(vendorAccount, 0, btcMarkup)) {
        // Transfer RBTC to vendor address
        vendorAccount.transfer(btcMarkup);
        // Transfer RBTC to commissions address
        mocInrate.commissionsAddress().transfer(btcCommission);
      } else {
        // Transfer MoC to commissions address
        mocInrate.commissionsAddress().transfer(totalBtcFee);
      }
    }
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /**
    @dev Transfer using transfer function and updates global RBTC register in MoCState
    @param receiver address of receiver
    @param btcAmount amount in RBTC
  */
  function doTransfer(address payable receiver, uint256 btcAmount) private {
    mocState.subtractRbtcFromSystem(btcAmount);
    receiver.transfer(btcAmount);
  }

  /**
    @dev Transfer using send function and updates global RBTC register in MoCState
    @param receiver address of receiver
    @param btcAmount amount in RBTC
    @return Execution result
  */
  function doSend(address payable receiver, uint256 btcAmount) private returns(bool) {
    // solium-disable-next-line security/no-send
    bool result = receiver.send(btcAmount);

    if (result) {
      mocState.subtractRbtcFromSystem(btcAmount);
    }

    return result;
  }

  /***** STATE MODIFIERS *****/
  modifier whenSettlementReady() {
    require(settlement.isSettlementReady(), "Function can only be called when settlement is ready");
    _;
  }

  modifier atState(IMoCState.States _state) {
    require(mocState.state() == _state, "Function cannot be called at this state.");
    _;
  }

  modifier atLeastState(IMoCState.States _state) {
    require(mocState.state() >= _state, "Function cannot be called at this state.");
    _;
  }

  modifier atMostState(IMoCState.States _state) {
    require(mocState.state() <= _state, "Function cannot be called at this state.");
    _;
  }

  modifier notInProtectionMode() {
    require(mocState.globalCoverage() > mocState.getProtected(), "Function cannot be called at protection mode.");
    _;
  }

  modifier bucketStateTransition(bytes32 bucket) {
    evalBucketLiquidation(bucket);
    _;
  }

  modifier availableBucket(bytes32 bucket) {
    require (bproxManager.isAvailableBucket(bucket), "Bucket is not available");
    _;
  }

  modifier notBaseBucket(bytes32 bucket) {
    require(!bproxManager.isBucketBase(bucket), "Bucket should not be a base type bucket");
    _;
  }

  modifier transitionState()
  {
    mocState.nextState();
    if (mocState.state() == IMoCState.States.Liquidated) {
      liquidate();
    }
    else
      _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
