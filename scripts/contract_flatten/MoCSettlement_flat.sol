// SPDX-License-Identifier: 
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
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

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;



/**
 * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See `ERC20._mint`.
     *
     * Requirements:
     *
     * - the caller must have the `MinterRole`.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/token/OwnerBurnableToken.sol

pragma solidity ^0.5.8;



/**
 * @title Owner Burnable Token
 * @dev Token that allows the owner to irreversibly burned (destroyed) any token.
 */
contract OwnerBurnableToken is Ownable, ERC20Mintable {
  /**
   * @dev Burns a specific amount of tokens for the address.
   * @param who who's tokens are gona be burned
   * @param value The amount of token to be burned.
   */
  function burn(address who, uint256 value) public onlyOwner {
    _burn(who, value);
  }
}

// File: contracts/token/DocToken.sol

pragma solidity ^0.5.8;



contract DocToken is ERC20Detailed, OwnerBurnableToken {

  string private _name = "Dollar on Chain";
  string private _symbol = "DOC";
  uint8 private _decimals = 18;

  /**
    @dev Constructor
  */
  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {

  }

  /**
    @dev Fallback function
  */
  function() external {
  }
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

// File: contracts/PartialExecution.sol

pragma solidity ^0.5.8;




contract PartialExecutionData {
  enum ExecutionState {Ready, Running, Finished}

  struct TaskGroup {
    bytes32 id;
    ExecutionState state;
    bytes32[] subTasks;
    function() internal onStart;
    function() internal onFinish;
    bool autoRestart;
  }

  struct Task {
    bytes32 id;
    function() internal returns (uint256) getStepCount;
    function(uint256) internal stepFunction;
    function() internal onStart;
    function() internal onFinish;
    uint256 currentStep;
    uint256 stepCount;
    ExecutionState state;
  }
}


/**
  @dev Brings basic data structures and functions for partial execution.
  The main data structures are:
    Task: Represents a function that needs to be executed by steps.
    TaskGroup: Represents a function that contains several functions that needs to be executed by steps.
  Tasks and Tasks groups can be executed specifying the amount of steps to run.
*/
contract PartialExecution is PartialExecutionData {
  using SafeMath for uint256;
  using Math for uint256;
  mapping(bytes32 => Task) internal tasks;
  mapping(bytes32 => TaskGroup) internal taskGroups;

  /**
   @dev Auxiliar function for tasks with no onFinish function
 */
  function noFunction() internal {}


  /**
   @dev Reset pointers a task group
   @param _groupId Id of the task group
   @param _subtasks Tasks to execute when executing the task group
   @param _onFinish Function to execute when all tasks of the group are completed
 */
  function resetTaskGroupPointers(
    bytes32 _groupId,
    bytes32[] memory _subtasks,
    function() _onStart,
    function() _onFinish,
    bool _autoRestart
  ) internal {
    taskGroups[_groupId].id = _groupId;
    taskGroups[_groupId].subTasks = _subtasks;
    taskGroups[_groupId].onStart = _onStart;
    taskGroups[_groupId].onFinish = _onFinish;
    taskGroups[_groupId].autoRestart = _autoRestart;

  }

  /**
   @dev Creates a task
   @param taskId Id of the task
   @param _getStepCount Function executed before starting the task
   Should return the step count of the execution
   @param _stepFunction Function to execute at each step
   @param _onStart Function to execute before task execution
   @param _onFinish Function to execute when all steps are completed
 */
  function resetTaskPointers(
    bytes32 taskId,
    function() internal returns (uint256) _getStepCount,
    function(uint256) internal _stepFunction,
    function() internal _onStart,
    function() internal _onFinish
  ) internal {
    tasks[taskId].id = taskId;
    tasks[taskId].getStepCount = _getStepCount;
    tasks[taskId].stepFunction = _stepFunction;
    tasks[taskId].onStart = _onStart;
    tasks[taskId].onFinish = _onFinish;
  }



  /**
   @dev Creates a task group
   @param _groupId Id of the task group
   @param _subtasks Tasks to execute when executing the task group
   @param _onFinish Function to execute when all tasks of the group are completed
 */
  function createTaskGroup(
    bytes32 _groupId,
    bytes32[] memory _subtasks,
    function() _onStart,
    function() _onFinish,
    bool _autoRestart
  ) internal {
    taskGroups[_groupId].id = _groupId;
    taskGroups[_groupId].subTasks = _subtasks;
    taskGroups[_groupId].onStart = _onStart;
    taskGroups[_groupId].onFinish = _onFinish;
    taskGroups[_groupId].state = ExecutionState.Ready;
    taskGroups[_groupId].autoRestart = _autoRestart;
  }

  /**
   @dev Creates a task
   @param taskId Id of the task
   @param _getStepCount Function executed before starting the task
   Should return the step count of the execution
   @param _stepFunction Function to execute at each step
   @param _onStart Function to execute before task execution
   @param _onFinish Function to execute when all steps are completed
 */
  function createTask(
    bytes32 taskId,
    function() internal returns (uint256) _getStepCount,
    function(uint256) internal _stepFunction,
    function() internal _onStart,
    function() internal _onFinish
  ) internal {
    tasks[taskId].id = taskId;
    tasks[taskId].getStepCount = _getStepCount;
    tasks[taskId].stepFunction = _stepFunction;
    tasks[taskId].onStart = _onStart;
    tasks[taskId].onFinish = _onFinish;
    tasks[taskId].state = ExecutionState.Ready;
  }

  /**
   @dev Executes all tasks of the group in order using the step count passed as parameter
   @param groupId Id of the task group
   @param stepCount Step count to execute
 */
  function executeGroup(bytes32 groupId, uint256 stepCount) internal {
    TaskGroup storage group = taskGroups[groupId];

    if (group.state == ExecutionState.Ready) {
      group.onStart();
      group.state = ExecutionState.Running;
    }

    uint256 leftSteps = stepCount;

    for (uint256 i = 0; i < group.subTasks.length && leftSteps > 0; i++) {
      uint256 consumed = executeTask(group.subTasks[i], leftSteps);
      leftSteps = leftSteps.sub(consumed);
    }

    if (groupFinished(groupId)) {
      group.state = ExecutionState.Finished;
      group.onFinish();
      if (group.autoRestart) {
        resetGroup(groupId);
      }
    }
  }

  /**
   @dev Creates a task
   @param taskId Id of the task
   @param steps Step count to execute
   @return The amount of steps consumed in the execution
 */
  function executeTask(bytes32 taskId, uint256 steps)
  internal
  returns (uint256)
  {
    Task storage task = tasks[taskId];
    uint256 initialStep = task.currentStep;

    if (task.state == ExecutionState.Finished) {
      // No execution
      return 0;
    }
    if (task.state == ExecutionState.Ready) {
      task.stepCount = task.getStepCount();
      task.onStart();
      task.state = ExecutionState.Running;
    }
    if (task.state == ExecutionState.Running) {
      uint256 endStep = Math.min(
        task.currentStep.add(steps),
        task.stepCount
      );

      for (
        task.currentStep;
        task.currentStep < endStep;
        task.currentStep++
      ) {
        task.stepFunction(task.currentStep);
      }

      if (task.currentStep == task.stepCount) {
        task.state = ExecutionState.Finished;
        task.onFinish();
      }
    }

    return task.currentStep.sub(initialStep);
  }

  /**
   @dev Put task in Ready to run state and reset currentStep value
   @param taskId Id of the task
 */
  function resetTask(bytes32 taskId) internal {
    tasks[taskId].state = ExecutionState.Ready;
    tasks[taskId].currentStep = 0;
  }

  /**
  @dev Reset all tasks in a group. Used at the completion of a task group execution
  @param groupId Id of the task group
*/
  function resetTasks(bytes32 groupId) internal {
    TaskGroup storage group = taskGroups[groupId];

    for (uint256 i = 0; i < group.subTasks.length; i++) {
      resetTask(group.subTasks[i]);
    }
  }

  /**
  @dev Set if a Group should be automatically set to Ready state
  after Finnished State is reached
  @param groupId Id of the task group
*/
  function setAutoRestart(bytes32 groupId, bool _autoRestart) internal {
    taskGroups[groupId].autoRestart = _autoRestart;
  }

  /**
  @dev Set Group in Ready state. Reset all sub-task.
  @param groupId Id of the task group
*/
  function resetGroup(bytes32 groupId) internal {
    TaskGroup storage group = taskGroups[groupId];
    group.state = ExecutionState.Ready;

    resetTasks(groupId);
  }

  /**
   @dev Returns true if the last task of the group was completed
   @param groupId Id of the task group
   @return boolean
 */
  function groupFinished(bytes32 groupId) internal view returns (bool) {
    TaskGroup storage group = taskGroups[groupId];
    bytes32 taskId = group.subTasks[group.subTasks.length.sub(1)];
    Task storage lastTask = tasks[taskId];

    return lastTask.state == ExecutionState.Finished;
  }

  /**
   @dev Returns true if the group is currently un Running state
   @param groupId Id of the task group
   @return boolean
 */
  function isGroupRunning(bytes32 groupId) internal view returns (bool) {
    return taskGroups[groupId].state == ExecutionState.Running;
  }

  /**
   @dev Returns true if the group is currently in Ready state
   @param groupId Id of the task group
   @return boolean
 */
  function isGroupReady(bytes32 groupId) internal view returns (bool) {
    return taskGroups[groupId].state == ExecutionState.Ready;
  }

  /**
   @dev Returns true if the task is currently un Running state
   @param taskId Id of the task
   @return boolean
 */
  function isTaskRunning(bytes32 taskId) internal view returns (bool) {
    return tasks[taskId].state == ExecutionState.Running;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
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

// File: contracts/MoCSettlement.sol

pragma solidity ^0.5.8;













contract MoCSettlementEvents {
  event RedeemRequestAlter(address indexed redeemer, bool isAddition, uint256 delta);
  event RedeemRequestProcessed(address indexed redeemer, uint256 commission, uint256 amount);
  event SettlementRedeemStableToken(uint256 queueSize, uint256 accumCommissions, uint256 reservePrice);
  event SettlementDeleveraging(uint256 leverage, uint256 riskProxPrice, uint256 reservePrice, uint256 startBlockNumber);
  event SettlementStarted(
    uint256 stableTokenRedeemCount,
    uint256 deleveragingCount,
    uint256 riskProxPrice,
    uint256 reservePrice
  );
  event SettlementCompleted(uint256 commissionsPayed);
}

contract MoCSettlement is
MoCSettlementEvents,
MoCBase,
PartialExecution,
Governed,
IMoCSettlement
{
  using Math for uint256;
  using SafeMath for uint256;

  bytes32 public constant DOC_REDEMPTION_TASK = keccak256("DocRedemption");
  bytes32 public constant DELEVERAGING_TASK = keccak256("Deleveraging");
  bytes32 public constant SETTLEMENT_TASK = keccak256("Settlement");

  struct RedeemRequest {
    address payable who;
    uint256 amount;
  }

  struct UserRedeemRequest {
    uint256 index;
    bool activeRedeemer;
  }

  // All necessary data for Settlement execution
  struct SettlementInfo {
    uint256 btcPrice;
    uint256 btcxPrice;
    uint256 docRedeemCount;
    uint256 deleveragingCount;
    uint256 bproxAmount;
    uint256 partialCommissionAmount;
    uint256 finalCommissionAmount;
    uint256 leverage;
    uint256 startBlockNumber;
    bool isProtectedMode;
  }

  // Contracts
  IMoCState internal mocState;
  IMoCExchange internal mocExchange;
  DocToken internal docToken;
  MoCBProxManager internal bproxManager;

  /**
  @dev Block Number of the last successful execution
  */
  uint256 internal lastProcessedBlock;
  /**
  @dev Min number of blocks settlement should be re evaluated on
  */
  uint256 internal blockSpan;
  /**
  @dev Information for Settlement execution
  */
  SettlementInfo internal settlementInfo;
  /**
  @dev Redeem queue
  */
  RedeemRequest[] private redeemQueue;
  uint256 private redeemQueueLength;

  mapping(address => UserRedeemRequest) private redeemMapping;

  /**
    @dev Initializes the contract
    @param connectorAddress MoCConnector contract address
    @param _governor Governor contract address
    @param _blockSpan Blockspan configuration blockspan of settlement
  */
  function initialize(
    address connectorAddress,
    address _governor,
    uint256 _blockSpan
  ) public initializer {
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _blockSpan);
  }

  /**
   *  @dev Set the blockspan configuration blockspan of settlement
   */
  function setBlockSpan(uint256 bSpan) public onlyAuthorizedChanger() {
    blockSpan = bSpan;
  }

  /**
   *  @dev Set Settlement to be kept in finnished state after
   *  all execution is completed.
   */
  function setSettlementToStall() public onlyAuthorizedChanger() {
    setAutoRestart(SETTLEMENT_TASK, false);
  }

  /**
   *  @dev Set Settlement state to Ready
   */
  function restartSettlementState() public onlyAuthorizedChanger() {
    resetGroup(SETTLEMENT_TASK);
    setAutoRestart(SETTLEMENT_TASK, true);
  }

  /**
    @dev Gets the RedeemRequest at the queue index position
    @param _index queue position to get
    @return redeemer's address and amount he submitted
  */
  function getRedeemRequestAt(uint256 _index)
  public
  view
  withinBoundaries(_index)
  returns (address payable, uint256)
  {
    return (redeemQueue[_index].who, redeemQueue[_index].amount);
  }

  /**
    @dev Gets the number of blocks the settlemnet will be allowed to run
  */
  function getBlockSpan() public view returns (uint256) {
    return blockSpan;
  }

  /**
    @dev Verify that the index is smaller than the length of the redeem request queue
    @param _index queue position to get
  */
  modifier withinBoundaries(uint256 _index) {
    require(_index < redeemQueueLength, "Index out of boundaries");
    _;
  }

  /**
    @dev Returns the current redeem request queue's length
  */
  function redeemQueueSize() public view returns (uint256) {
    return redeemQueueLength;
  }

  /**
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
  function isSettlementEnabled() public view returns (bool) {
    return nextSettlementBlock() <= block.number;
  }

  /**
    @dev Returns true if the settlment is running
  */
  function isSettlementRunning() public view returns (bool) {
    return isGroupRunning(SETTLEMENT_TASK);
  }

  /**
    @dev Returns true if the settlment is ready
  */
  function isSettlementReady() public view returns (bool) {
    return isGroupReady(SETTLEMENT_TASK);
  }

  /**
    @dev Returns the next block from which settlement is possible
  */
  function nextSettlementBlock() public view returns (uint256) {
    return lastProcessedBlock.add(blockSpan);
  }

  /**
    @dev returns the total amount of Docs in the redeem queue for _who
    @param _who address for which ^ is computed
    @return total amount of Docs in the redeem queue for _who [using mocPrecision]
  */
  function docAmountToRedeem(address _who) public view returns (uint256) {
    if (!redeemMapping[_who].activeRedeemer) {
      return 0;
    }

    uint256 indexRedeem = redeemMapping[_who].index;
    RedeemRequest memory redeemRequest = redeemQueue[indexRedeem];
    return redeemRequest.amount;
  }

  /**
    @dev push a new redeem request to the queue for the sender or updates the amount if the user has a redeem request
    @param amount amount he is willing to redeem [using mocPrecision]
    @param redeemer redeemer address
  */
  function addRedeemRequest(uint256 amount, address payable redeemer)
  public
  onlyWhitelisted(msg.sender)
  {
    if (!redeemMapping[redeemer].activeRedeemer) {
      if (redeemQueueLength == redeemQueue.length) {
        redeemQueue.length += 1;
      }
      uint256 index = redeemQueueLength;
      redeemQueue[redeemQueueLength++] = RedeemRequest(redeemer, amount);
      redeemMapping[redeemer] = UserRedeemRequest(index, true);
      emit RedeemRequestAlter(redeemer, true, amount);
    } else {
      alterRedeemRequestAmount(true, amount, redeemer);
    }
  }

  /**
    @dev empty the queue
  */
  function clear() public onlyWhitelisted(msg.sender) {
    redeemQueueLength = 0;
  }

  /**
    @dev Alters the redeem amount position for the redeemer
    @param isAddition true if adding amount to redeem, false to substract.
    @param delta the amount to add/substract to current position [using mocPrecision]
    @param redeemer address to alter amount for
    @return the filled amount [using mocPrecision]
  */
  function alterRedeemRequestAmount(
    bool isAddition,
    uint256 delta,
    address redeemer
  ) public onlyWhitelisted(msg.sender) {
    require(
      redeemMapping[redeemer].activeRedeemer,
      "This is not an active redeemer"
    );
    uint256 indexRedeem = redeemMapping[redeemer].index;
    RedeemRequest storage redeemRequest = redeemQueue[indexRedeem];
    require(redeemRequest.who == redeemer, "Not allowed redeemer");
    uint256 actualDelta = delta;
    if (isAddition) {
      redeemRequest.amount = redeemRequest.amount.add(delta);
    } else {
      if (redeemRequest.amount < delta) {
        actualDelta = redeemRequest.amount;
        redeemRequest.amount = 0;
      } else {
        redeemRequest.amount = redeemRequest.amount.sub(delta);
      }
    }
    emit RedeemRequestAlter(redeemer, isAddition, actualDelta);
  }

  /**
    @dev Runs settlement process in steps
    @param steps Amount of steps to run
    @return The commissions collected in the executed steps
  */
  function runSettlement(uint256 steps)
  public
  onlyWhitelisted(msg.sender)
  isTime()
  returns (uint256)
  {
    executeGroup(SETTLEMENT_TASK, steps);

    return settlementInfo.finalCommissionAmount;
  }

  /**
    @dev Create Task structures for Settlement execution
  */
  function fixTasksPointer() public {
    bytes32[] memory tasks = new bytes32[](2);
    tasks[0] = DELEVERAGING_TASK;
    tasks[1] = DOC_REDEMPTION_TASK;

    resetTaskPointers(
      DELEVERAGING_TASK,
      deleveragingStepCount,
      deleveragingStep,
      noFunction,
      finishDeleveraging
    );
    resetTaskPointers(
      DOC_REDEMPTION_TASK,
      docRedemptionStepCount,
      docRedemptionStep,
      noFunction,
      finishDocRedemption
    );
    resetTaskGroupPointers(
      SETTLEMENT_TASK,
      tasks,
      initializeSettlement,
      finishSettlement,
      true
    );
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = IMoCState(connector.mocState());
    mocExchange = IMoCExchange(connector.mocExchange());
  }

  function initializeValues(address _governor, uint256 _blockSpan) internal {
    governor = IGovernor(_governor);
    blockSpan = _blockSpan;
    lastProcessedBlock = block.number;
    initializeTasks();
  }


  modifier isTime() {
    require(isSettlementEnabled(), "Settlement not yet enabled");
    _;
  }

  /**************************************************/
  /******************** TASKS ***********************/
  /**************************************************/

/**
  @dev Returns the amount of steps for the Deleveraging task
  which is the amount of active BProx addresses
*/
  function deleveragingStepCount() internal view returns (uint256) {
    return bproxManager.getActiveAddressesCount(BUCKET_X2);
  }

  /**
  @dev Returns the amount of steps for the Doc Redemption task
  which is the amount of redeem requests in the queue
*/
  function docRedemptionStepCount() internal view returns (uint256) {
    // If Protected Mode is reached, DoCs in queue must not be redeemed until next settlement
    if (mocState.globalCoverage() <= mocState.getProtected()) {
      return 0;
    }
    return redeemQueueLength;
  }

  /**
  @dev Freezes state for Settlement execution
*/
  function initializeSettlement() internal {
    settlementInfo.leverage = mocState.leverage(BUCKET_X2);
    settlementInfo.btcPrice = mocState.getBitcoinPrice();
    settlementInfo.btcxPrice = mocState.bucketBProTecPrice(BUCKET_X2);
    settlementInfo.startBlockNumber = block.number;

    // Protected Mode
    if (mocState.globalCoverage() <= mocState.getProtected()) {
      settlementInfo.isProtectedMode = true;
    } else {
      settlementInfo.isProtectedMode = false;
    }

    settlementInfo.docRedeemCount = redeemQueueLength;
    settlementInfo.deleveragingCount = bproxManager.getActiveAddressesCount(
      BUCKET_X2
    );
    settlementInfo.finalCommissionAmount = 0;
    settlementInfo.partialCommissionAmount = 0;
    settlementInfo.startBlockNumber = block.number;

    // Reset total paid in MoC for every vendor
    IMoCVendors mocVendors = IMoCVendors(mocState.getMoCVendors());
    mocVendors.resetTotalPaidInMoC();

    emit SettlementStarted(
      settlementInfo.docRedeemCount,
      settlementInfo.deleveragingCount,
      settlementInfo.btcxPrice,
      settlementInfo.btcPrice
    );
  }

  /**
  @dev Execute final step of Settlement task group
*/
  function finishSettlement() internal {
    lastProcessedBlock = lastProcessedBlock.add(blockSpan);
    settlementInfo.finalCommissionAmount = settlementInfo
    .partialCommissionAmount;
    emit SettlementCompleted(settlementInfo.finalCommissionAmount);
  }

  /**
  @dev Execute final step of Deleveraging task
*/
  function finishDeleveraging() internal {
    emit SettlementDeleveraging(
      settlementInfo.leverage,
      settlementInfo.btcxPrice,
      settlementInfo.btcPrice,
      settlementInfo.startBlockNumber
    );

    bproxManager.emptyBucket(BUCKET_X2, BUCKET_C0);
  }

  /**
  @dev Execute final step of DocRedemption task
*/
  function finishDocRedemption() internal {
    emit SettlementRedeemStableToken(
      settlementInfo.docRedeemCount,
      settlementInfo.finalCommissionAmount,
      settlementInfo.btcPrice
    );

    if (!settlementInfo.isProtectedMode) {
      clear();
    }
  }

  /**
  @dev Individual Deleveraging step to be executed in partial execution
  uint256 parameter needed for PartialExecution
*/
  function deleveragingStep(uint256) internal {
    // We just pop the first element because the redemption always remove the address.
    address payable userAddress = bproxManager.getActiveAddresses(
      BUCKET_X2
    )[0];
    uint256 bproxBalance = bproxManager.bproxBalanceOf(
      BUCKET_X2,
      userAddress
    );

    // RBTC sending could only fail if the receiving address
    // executes code and reverts. If that happens, the user will lose
    // his Bprox and RBTCs will be kept in MoC.
    mocExchange.forceRedeemBProx(
      BUCKET_X2,
      userAddress,
      bproxBalance,
      settlementInfo.btcxPrice
    );
  }

  /**
  @dev Individual DocRedemption step to be executed in partial execution
  @param index Step number currently in execution
*/
  function docRedemptionStep(uint256 index) internal {
    (address payable redeemer, uint256 redeemAmount) = getRedeemRequestAt(
      index
    );
    uint256 userDocBalance = docToken.balanceOf(redeemer);
    uint256 amountToRedeem = Math.min(userDocBalance, redeemAmount);
    if (amountToRedeem > 0) {
      (bool result, uint256 btcCommissionSpent) = mocExchange
      .redeemDocWithPrice(
        redeemer,
        amountToRedeem,
        settlementInfo.btcPrice
      );
      // Redemption can fail if the receiving address is a contract
      if (result) {
        emit RedeemRequestProcessed(
          redeemer,
          btcCommissionSpent,
          amountToRedeem
        );
        settlementInfo.partialCommissionAmount = settlementInfo
        .partialCommissionAmount
        .add(btcCommissionSpent);
      }
    }
    UserRedeemRequest storage userReedem = redeemMapping[redeemer];
    userReedem.activeRedeemer = false;
    redeemQueue[index].amount = 0;
  }

  /**
  @dev Create Task structures for Settlement execution
*/
  function initializeTasks() internal {
    createTask(
      DELEVERAGING_TASK,
      deleveragingStepCount,
      deleveragingStep,
      noFunction,
      finishDeleveraging
    );
    createTask(
      DOC_REDEMPTION_TASK,
      docRedemptionStepCount,
      docRedemptionStep,
      noFunction,
      finishDocRedemption
    );

    bytes32[] memory tasks = new bytes32[](2);
    tasks[0] = DELEVERAGING_TASK;
    tasks[1] = DOC_REDEMPTION_TASK;

    createTaskGroup(
      SETTLEMENT_TASK,
      tasks,
      initializeSettlement,
      finishSettlement,
      true
    );
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
