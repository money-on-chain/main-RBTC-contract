pragma solidity 0.5.8;



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


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

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


contract BProToken is ERC20Detailed, ERC20Pausable, OwnerBurnableToken {

  string private _name = "BitPRO";
  string private _symbol = "BITP";
  uint8 private _decimals = 18;

  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {
  }

  //Fallback
  function() external {
  }
}






library MoCHelperLib {

  struct MocLibConfig {
    uint256 reservePrecision;
    uint256 dayPrecision;
    uint256 mocPrecision;
  }

  using SafeMath for uint256;

  uint256 constant UINT256_MAX = ~uint256(0);

  /**
    Calculates average interest using integral function

    @dev T =  Rate = a * (x ** b) + c
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
    Calculates spot interest rate that BProx owners should pay to BPro owners

    @dev Rate = tMax * (abRatio ** power) + tMin
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
    Calculates potential interests function with given parameters

    @dev Rate = a * (x ** b) + c
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
    Calculates average of the integral function

    @dev T = (
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
    Calculates integral of the exponential function

    @dev T = c * (value) + (a * value ** (b + 1)) / (b + 1))
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
    SpotDiscountRate = TPD * (utpdu - cob) / (uptdu -liq)

    @dev Returns the Ratio to apply to BPro Price in discount situations
    @param bproLiqDiscountRate Discount rate applied at Liquidation level coverage [using mocPrecision]
    @param liq Liquidation coverage threshold [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param cov Actual global Coverage threshold [using mocPrecision]
    @return Spot discount rate [using mocPrecision]
  **/
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
    MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)

    @dev Max amount of BPro to available with discount
    @param nB Total BTC amount [using reservePrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @param spotDiscount spot discount [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  **/
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
    MaxBProWithDiscount = (uTPDU * nDOC * PEG - (nBTC * B)) / (TPusd * TPD)

    @dev Max amount of BPro to available with discount
    @param nbUsdValue Total amount of BTC in USD [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param utpdu Discount coverage threshold [using mocPrecision]
    @param bproDiscountPrice bproUsdPrice with discount applied [using mocPrecision]
    @param peg peg value
    @return Total BPro amount [using mocPrecision]
  **/
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
  **/
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
  **/
  function liquidationPrice(MocLibConfig storage libConfig, uint256 rbtcAmount, uint256 nDoc)
  public view returns(uint256) {
    // [MOC] * [RES] / [RES]
    return nDoc.mul(libConfig.reservePrecision).div(rbtcAmount);
  }

  /**
   TPbtc = (nB-LB) / nTP

    @dev Calculates BPro BTC price
    @param nB Total BTC amount [using reservePrecision]
    @param lb Locked bitcoins amount [using reservePrecision]
    @param nTP BPro amount [using mocPrecision]
    @return BPro BTC price [using reservePrecision]
  **/
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
   BProxInBPro = bproxTecPrice / bproPrice

    @dev Calculates BPro BTC price
    @param bproxTecPrice BProx BTC price [using reservePrecision]
    @param bproPrice Trog BTC price [using reservePrecision]
    @return BProx price in BPro [using mocPrecision]
  **/
  function bproxBProPrice(
    MocLibConfig storage libConfig, uint256 bproxTecPrice, uint256 bproPrice
  ) public view returns(uint256) {
    // [RES] * [MOC] / [RES] = [MOC]
    return bproxTecPrice.mul(libConfig.mocPrecision).div(bproPrice);
  }

  /**
   TPbtc = (price)* (1 - discountRate)

    @dev Returns a new value with the discountRate applied
    @param price Price [using SomePrecision]
    @param discountRate Discount rate to apply [using mocPrecision]
    @return Price with discount applied [using SomePrecision]
  **/
  function applyDiscountRate(MocLibConfig storage libConfig, uint256 price, uint256 discountRate)
    public view returns(uint256) {

    uint256 discountCoeff = libConfig.mocPrecision.sub(discountRate);

    return price.mul(discountCoeff).div(libConfig.mocPrecision);
  }

  /**
   TPbtc = price * interestRate

    @dev Returns the amount of interest to pay
    @param value Cost to apply interest [using SomePrecision]
    @param interestRate Interest rate to apply [using mocPrecision]
    @return Interest cost based on the value and interestRate [using SomePrecision]
  **/
  function getInterestCost(MocLibConfig storage libConfig, uint256 value, uint256 interestRate)
    public view returns(uint256) {
    // [ORIGIN] * [MOC] / [MOC] = [ORIGIN]
    return value.mul(interestRate).div(libConfig.mocPrecision);
  }

  /**
    Coverage = nB / LB

    @dev Calculates Coverage
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Coverage [using mocPrecision]
  **/
  function coverage(MocLibConfig storage libConfig, uint256 nB, uint256 lB) public view
    returns(uint256) {
    if (lB == 0) {
      return UINT256_MAX;
    }

    return nB.mul(libConfig.mocPrecision).div(lB);
  }

 /**
  Leverage = C / (C - 1)

    @dev Calculates Leverage
    @param cov Coverage [using mocPrecision]
    @return Leverage [using mocPrecision]
  **/
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
  Leverage = nB / (nB - lB)

    @dev Calculates Leverage
    @param nB Total BTC amount [using reservePrecision]
    @param lB Locked bitcoins amount [using reservePrecision]
    @return Leverage [using mocPrecision]
  **/
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
  **/
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
  **/
  function bproBtcValue(MocLibConfig storage libConfig, uint256 bproAmount, uint256 bproBtcPrice)
    public view returns(uint256) {
    require(libConfig.reservePrecision > 0, "Precision should be more than zero");

    // [MOC] * [RES] / [MOC] =  [RES]
    uint256 bproBtcTotal = bproAmount.mul(bproBtcPrice).div(libConfig.mocPrecision);

    return bproBtcTotal;
  }

  /**
   MaxDoc = ((nB*B)-(Cobj*B/Bcons*nDoc*PEG))/(PEG*(Cobj*B/BCons-1))

    @dev Max amount of Docs to issue
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc DOC amount [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @return Total Docs amount [using mocPrecision]
  **/
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
   MaxBPro = ((nB*B)-(Cobj*nDoc*PEG))/TPusd

    @dev Max amount of BPro to redeem
    @param nB Total BTC amount [using reservePrecision]
    @param cobj Target Coverage [using mocPrecision]
    @param nDoc Target Coverage [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param bCons BTC conservative price [using mocPrecision]
    @param bproUsdPrice bproUsdPrice [using mocPrecision]
    @return Total BPro amount [using mocPrecision]
  **/
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
  **/
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
  **/
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
  **/
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
    toMove = btcAmount * (lev - 1)

    @dev Calculates the Btc amount to move from C0 bucket to
    an L bucket when a BProx minting occurs
    @param btcAmount Total BTC amount [using reservePrecision]
    @param lev L bucket leverage [using mocPrecision]
    @return btc to move [using reservePrecision]
    **/
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
    Maxbprox = nDOC/ (PEG*B*(lev-1))

    @dev Max amount of BTC allowed to be used to mint bprox
    @param nDoc number of DOC [using mocPrecision]
    @param peg peg value
    @param btcPrice BTC price [using mocPrecision]
    @param lev leverage [using mocPrecision]
    @return Max bprox BTC value [using reservePrecision]
  **/
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
    @dev Rounding product adapted from DSMath but with custom precision
    @param x Multiplicand
    @param y Multiplier
    @return Product
  **/
  function mulr(uint x, uint y, uint256 precision) internal pure returns (uint z) {
    return x.mul(y).add(precision.div(2)).div(precision);
  }

  /**
    @dev Potentiation by squaring adapted from DSMath but with custom precision
    @param x Base
    @param n Exponent
    @return power
  **/
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

/**
 * @dev Defines special constants to use along all the MoC System
 */
contract MoCConstants {
  bytes32 constant public BUCKET_X2 = "X2";
  bytes32 constant public BUCKET_C0 = "C0";
}



/**
  @dev General usefull modifiers and functions
 */
contract MoCBase is MoCConstants, Initializable{
  // Contracts
  MoCConnector public connector;

  bool internal initialized;

  function initializeBase(address connectorAddress) internal initializer  {
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




contract MoCBucketContainer is MoCBase, Governed{
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
  **/
  function isBucketBase(bytes32 bucket) public view returns(bool){
    return mocBuckets[bucket].isBase;
  }

  /**
    @dev returns true if the bucket have docs in it
    @param bucket Name of the bucket
  **/
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
  **/
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
  **/
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
  **/
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
  **/
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
  **/
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


contract MoCBProxManager is MoCBucketContainer {
  using SafeMath for uint256;
  uint256 constant MIN_ALLOWED_BALANCE = 0;
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
    @dev  Removes the amount of BProx and substract BTC cost from bucket
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
   * @dev intializes values of the contract
   */
  function initializeValues(address _governor) internal {
    governor = IGovernor(_governor);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}


interface BtcPriceProvider {
  function peek() external view returns (bytes32, bool);
}




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
   * @dev Remove account to whitelist
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

  bool internal initialized;

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
    address burnoutBookAddress
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
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}











contract DocToken is ERC20Detailed, OwnerBurnableToken {

  string private _name = "Dollar on Chain";
  string private _symbol = "DOC";
  uint8 private _decimals = 18;

  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {

  }

  //Fallback
  function() external {
  }
}











/** @title Btc Price Provider. */
contract MoCEMACalculator is Governed {
  using SafeMath for uint256;

  event MovingAverageCalculation (
    uint256 price,
    uint256 movingAverage
  );

  uint256 internal bitcoinMovingAverage;
  uint256 public smoothingFactor;
  uint256 public lastEmaCalculation;
  uint256 public emaCalculationBlockSpan;

  uint256 constant public PRICE_PRECISION =  10 ** 18;
  uint256 constant public FACTOR_PRECISION = 10 ** 18;

  function getBitcoinMovingAverage() public view returns(uint256) {
    return bitcoinMovingAverage;
  }

  function getSmoothingFactor() public view returns(uint256) {
    return smoothingFactor;
  }

  function setSmoothingFactor(uint256 factor) public onlyAuthorizedChanger() {
    _doSetSmoothingFactor(factor);
  }

  function getGovernorAddress() public view returns(address){
    return address(governor);
  }

  function getEmaCalculationBlockSpan() public view returns(uint256){
    return emaCalculationBlockSpan;
  }
  /**
  * @param blockSpan Defines how many blocks should pass between BMA calculations
  **/
  function setEmaCalculationBlockSpan(uint256 blockSpan) public onlyAuthorizedChanger() {
    emaCalculationBlockSpan = blockSpan;
  }

  function shouldCalculateEma() public view returns(bool) {
    return block.number >= lastEmaCalculation.add(emaCalculationBlockSpan);
  }

  function getLastEmaCalculation() public view returns(uint256) {
    return lastEmaCalculation;
  }

    /** @dev Provides Bitcoin's Price and Moving average.
    * More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param initialEma Initial ema value
    * @param smoothFactor Weight coefficient for EMA calculation.
    * @param emaBlockSpan Block count in a period for EMA calculation
    */
  function initializeMovingAverage(uint256 initialEma, uint256 smoothFactor, uint256 emaBlockSpan) internal {
    _doSetSmoothingFactor(smoothFactor);
    lastEmaCalculation = block.number;
    bitcoinMovingAverage = initialEma;
    emaCalculationBlockSpan = emaBlockSpan;
  }

  /** @dev Calculates a EMA of the price.
    * More information of EMA calculation https://en.wikipedia.org/wiki/Exponential_smoothing
    * @param btcPrice Current price.
    */
  function setBitcoinMovingAverage(uint256 btcPrice) internal {
    if (shouldCalculateEma()) {
      uint256 weightedPrice = btcPrice.mul(smoothingFactor);
      uint256 currentEma = bitcoinMovingAverage.mul(coefficientComp()).add(weightedPrice)
        .div(FACTOR_PRECISION);

      lastEmaCalculation = block.number;
      bitcoinMovingAverage = currentEma;

      emit MovingAverageCalculation(btcPrice, currentEma);
    }
  }

  /** @dev Calculates the smoothing factor complement
    */
  function coefficientComp() internal view returns(uint256) {
    return FACTOR_PRECISION.sub(smoothingFactor);
  }

  function initializeGovernor(address _governor) internal {
    governor = IGovernor(_governor);
  }

  function _doSetSmoothingFactor(uint256 factor) private {
    require(factor <= FACTOR_PRECISION, "Invalid smoothing factor");
    smoothingFactor = factor;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}



















contract PartialExecutionData {
  enum ExecutionState {
    Ready,
    Running,
    Finished
  }

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
    function() internal returns(uint256) getStepCount;
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
  function noFunction() internal {

  }

  /**
     @dev Creates a task group
     @param _groupId Id of the task group
     @param _subtasks Tasks to execute when executing the task group
     @param _onFinish Function to execute when all tasks of the group are completed
   */
  function createTaskGroup(bytes32 _groupId, bytes32[] memory _subtasks, function() _onStart, function() _onFinish, bool _autoRestart) internal{
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
    function() internal returns(uint256) _getStepCount,
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

    for (uint256 i = 0; i < group.subTasks.length; i++) {
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
  function executeTask(bytes32 taskId, uint256 steps) internal returns(uint256){
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
      uint256 endStep = Math.min(task.currentStep.add(steps), task.stepCount);

      for (task.currentStep; task.currentStep < endStep; task.currentStep++) {
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
  function groupFinished(bytes32 groupId) internal view returns(bool){
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
  function isGroupRunning(bytes32 groupId) internal view returns(bool) {
    return taskGroups[groupId].state == ExecutionState.Running;
  }

  /**
     @dev Returns true if the group is currently in Ready state
     @param groupId Id of the task group
     @return boolean
   */
  function isGroupReady(bytes32 groupId) internal view returns(bool) {
    return taskGroups[groupId].state == ExecutionState.Ready;
  }

  /**
     @dev Returns true if the task is currently un Running state
     @param taskId Id of the task
     @return boolean
   */
  function isTaskRunning(bytes32 taskId) internal view returns(bool) {
    return tasks[taskId].state == ExecutionState.Running;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}




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
  event SettlementCompleted(
    uint256 commissionsPayed
  );
}

contract MoCSettlement is MoCSettlementEvents, MoCBase, PartialExecution, Governed {
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
  }

  // Contracts
  MoCState internal mocState;
  MoCExchange internal mocExchange;
  DocToken internal docToken;
  MoCBProxManager internal bproxManager;

  /**
    @dev Block Number of the last successful execution
  **/
  uint256 internal lastProcessedBlock;
  /**
    @dev Min number of blocks settlement should be re evaluated on
  **/
  uint256 internal blockSpan;
  /**
    @dev Information for Settlement execution
  **/
  SettlementInfo internal settlementInfo;
  /**
    @dev Redeem queue
  **/
  RedeemRequest[] private redeemQueue;
  uint256 private redeemQueueLength;

  mapping(address => UserRedeemRequest) private redeemMapping;

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
  function setBlockSpan(uint256 bSpan) public onlyAuthorizedChanger(){
    blockSpan = bSpan;
  }

  /**
   *  @dev Set Settlement to be kept in finnished state after
   *  all execution is completed.
   */
  function setSettlementToStall() public onlyAuthorizedChanger(){
    setAutoRestart(SETTLEMENT_TASK, false);
  }

  /**
   *  @dev Set Settlement state to Ready
   */
  function restartSettlementState() public onlyAuthorizedChanger(){
    resetGroup(SETTLEMENT_TASK);
    setAutoRestart(SETTLEMENT_TASK, true);
  }

  /**
    @dev Gets the RedeemRequest at the queue index position
    @param _index queue position to get
    @return redeemer's address and amount he submitted
  */
  function getRedeemRequestAt(uint256 _index) public view
    withinBoundaries(_index) returns(address payable, uint256) {
    return (redeemQueue[_index].who, redeemQueue[_index].amount);
  }

  /**
    @dev Gets the number of blocks the settlemnet will be allowed to run
  */
  function getBlockSpan() public view returns(uint256){
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
  function redeemQueueSize() public view returns(uint256) {
    return redeemQueueLength;
  }

  /**
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
  function isSettlementEnabled() public view returns(bool) {
    return nextSettlementBlock() <= block.number;
  }

  /**
    @dev Returns true if the settlment is running
  */
  function isSettlementRunning() public view returns(bool) {
    return isGroupRunning(SETTLEMENT_TASK);
  }

  /**
    @dev Returns true if the settlment is ready
  */
  function isSettlementReady() public view returns(bool) {
    return isGroupReady(SETTLEMENT_TASK);
  }
  /**
    @dev Returns the next block from which settlement is possible
   */
  function nextSettlementBlock() public view returns(uint256) {
    return lastProcessedBlock.add(blockSpan);
  }

  /**
    @dev returns the total amount of Docs in the redeem queue for _who
    @param _who address for which ^ is computed
    @return total amount of Docs in the redeem queue for _who [using mocPrecision]
   */
  function docAmountToRedeem(address _who) public view returns(uint256) {

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
  function addRedeemRequest(uint256 amount, address payable redeemer) public onlyWhitelisted(msg.sender) {
    if (!redeemMapping[redeemer].activeRedeemer) {
      if (redeemQueueLength == redeemQueue.length) {
        redeemQueue.length += 1;
      }
      uint256 index = redeemQueueLength;
      redeemQueue[redeemQueueLength++] = RedeemRequest(redeemer, amount);
      redeemMapping[redeemer] = UserRedeemRequest(index, true);
      emit RedeemRequestAlter(redeemer, true, amount);
    }
    else{
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
  function alterRedeemRequestAmount(bool isAddition, uint256 delta, address redeemer)
  public onlyWhitelisted(msg.sender) {
    require(redeemMapping[redeemer].activeRedeemer, "This is not an active redeemer");
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
  * @dev Runs settlement process in steps
    @param steps Amount of steps to run
    @return The commissions collected in the executed steps
  */
  function runSettlement(uint256 steps) public onlyWhitelisted(msg.sender) isTime() returns(uint256) {
    executeGroup(SETTLEMENT_TASK, steps);

    return settlementInfo.finalCommissionAmount;
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    mocExchange = MoCExchange(connector.mocExchange());
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
  function deleveragingStepCount() internal view returns(uint256) {
    return bproxManager.getActiveAddressesCount(BUCKET_X2);
  }

  /**
    @dev Returns the amount of steps for the Doc Redemption task
    which is the amount of redeem requests in the queue
  */
  function docRedemptionStepCount() internal view returns(uint256) {
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

    settlementInfo.docRedeemCount = redeemQueueLength;
    settlementInfo.deleveragingCount = bproxManager.getActiveAddressesCount(BUCKET_X2);
    settlementInfo.finalCommissionAmount = 0;
    settlementInfo.partialCommissionAmount = 0;
    settlementInfo.startBlockNumber = block.number;


    emit SettlementStarted(settlementInfo.docRedeemCount, settlementInfo.deleveragingCount, settlementInfo.btcxPrice, settlementInfo.btcPrice);
  }

  /**
    @dev Execute final step of Settlement task group
  */
  function finishSettlement() internal {
    lastProcessedBlock = lastProcessedBlock.add(blockSpan);
    settlementInfo.finalCommissionAmount = settlementInfo.partialCommissionAmount;
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

    clear();
  }

  /**
    @dev Individual Deleveraging step to be executed in partial execution
    uint256 parameter needed for PartialExecution
  */
  function deleveragingStep(uint256) internal {
    // We just pop the first element because the redemption always remove the address.
    address payable userAddress = bproxManager.getActiveAddresses(BUCKET_X2)[0];
    uint256 bproxBalance = bproxManager.bproxBalanceOf(BUCKET_X2, userAddress);

    // RBTC sending could only fail if the receiving address
    // executes code and reverts. If that happens, the user will lose
    // his Bprox and RBTCs will be kept in MoC.
    mocExchange.forceRedeemBProx(BUCKET_X2, userAddress, bproxBalance, settlementInfo.btcxPrice);
  }

  /**
    @dev Individual DocRedemption step to be executed in partial execution
    @param index Step number currently in execution
  */
  function docRedemptionStep(uint256 index) internal {
    (address payable redeemer, uint256 redeemAmount) = getRedeemRequestAt(index);
    uint256 userDocBalance = docToken.balanceOf(redeemer);
    uint256 amountToRedeem = Math.min(userDocBalance, redeemAmount);
    if (amountToRedeem > 0) {
      (bool result, uint256 btcCommissionSpent) = mocExchange.redeemDocWithPrice(redeemer, amountToRedeem, settlementInfo.btcPrice);
      // Redemption can fail if the receiving address is a contract
      if (result) {
        emit RedeemRequestProcessed(redeemer, btcCommissionSpent, amountToRedeem);
        settlementInfo.partialCommissionAmount = settlementInfo.partialCommissionAmount.add(btcCommissionSpent);
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
    createTask(DELEVERAGING_TASK, deleveragingStepCount, deleveragingStep, noFunction, finishDeleveraging);
    createTask(DOC_REDEMPTION_TASK, docRedemptionStepCount, docRedemptionStep, noFunction, finishDocRedemption);

    bytes32[] memory tasks = new bytes32[](2);
    tasks[0] = DELEVERAGING_TASK;
    tasks[1] = DOC_REDEMPTION_TASK;

    createTaskGroup(SETTLEMENT_TASK, tasks, initializeSettlement, finishSettlement, true);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}









contract MoCState is MoCLibConnection, MoCBase, MoCEMACalculator {
  using Math for uint256;
  using SafeMath for uint256;

  // This is the current state.
  States public state;

  event StateTransition(States newState);
  event PriceProviderUpdated(address oldAddress, address newAddress);
  // Contracts
  BtcPriceProvider internal btcPriceProvider;
  MoCSettlement internal mocSettlement;
  MoCConverter internal mocConverter;
  DocToken internal docToken;
  BProToken internal bproToken;
  MoCBProxManager internal bproxManager;

  // One Day based on 15 seconds blocks
  uint256 public dayBlockSpan;
  // Relation between DOC and dollar
  uint256 public peg;
  // BPro max discount rate
  // Reflects the discount spot rate at Liquidation level
  uint256 public bproMaxDiscountRate;
  // Liquidation limit
  // [using mocPrecision]
  uint256 public liq;
  // BPro with discount limit
  // [using mocPrecision]
  uint256 public utpdu;
  // Complete amount of Bitcoin in the system
  // this represents basically MoC Balance
  uint256 public rbtcInSystem;
  // Price to use at doc redemption at
  // liquidation event
  uint256 public liquidationPrice;

  function initialize(
    address connectorAddress,
    address _governor,
    address _btcPriceProvider,
    uint256 _liq,
    uint256 _utpdu,
    uint256 _maxDiscRate,
    uint256 _dayBlockSpan,
    uint256 _ema,
    uint256 _smoothFactor,
    uint256 _emaBlockSpan,
    uint256 _maxMintBPro
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(_governor, _btcPriceProvider,_liq, _utpdu, _maxDiscRate, _dayBlockSpan, _maxMintBPro);
    initializeMovingAverage(_ema, _smoothFactor, _emaBlockSpan);
  }

  /**
  * @param rate Discount rate at liquidation level [using mocPrecision]
  **/
  function setMaxDiscountRate(uint256 rate) public onlyAuthorizedChanger() {
    require(rate < mocLibConfig.mocPrecision, "rate is lower than mocPrecision");

    bproMaxDiscountRate = rate;
  }

    /**
   * @dev return the value of the BPro max discount rate configuration param
   * @return bproMaxDiscountRate BPro max discount rate
   */
  function getMaxDiscountRate() public view returns(uint256) {
    return bproMaxDiscountRate;
  }

  /**
  * @dev Defines how many blocks there are in a day
  * @param blockSpan blocks there are in a day
  **/
  function setDayBlockSpan(uint256 blockSpan) public onlyAuthorizedChanger() {
    dayBlockSpan = blockSpan;
  }

  /**
  * @dev Sets a new BTCProvider contract
  * @param btcProviderAddress blocks there are in a day
  **/
  function setBtcPriceProvider(address btcProviderAddress) public onlyAuthorizedChanger() {
    address oldBtcPriceProviderAddress = address(btcPriceProvider);
    btcPriceProvider = BtcPriceProvider(btcProviderAddress);
    emit PriceProviderUpdated(oldBtcPriceProviderAddress, address(btcPriceProvider));
  }

  /**
  * @dev Gets the BTCPriceProviderAddress
  * @return btcPriceProvider blocks there are in a day
  **/
  function getBtcPriceProvider() public view returns(address) {
    return address(btcPriceProvider);
  }
  /**
   * @dev Gets how many blocks there are in a day
   * @return blocks there are in a day
   */
  function getDayBlockSpan() public view returns(uint256) {
    return dayBlockSpan;
  }
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

/**
  * @dev Subtract the btc amount passed by parameter to the total Bitcoin Amount
  * @param btcAmount Amount that will be subtract to rbtcInSystem
  */
  function subtractRbtcFromSystem(uint256 btcAmount) public onlyWhitelisted(msg.sender) {
    rbtcInSystem = rbtcInSystem.sub(btcAmount);
  }

  /**
  * @dev btcAmount Add the btc amount passed by parameter to the total Bitcoin Amount
  * @param btcAmount Amount that will be added to rbtcInSystem
  */
  function addToRbtcInSystem(uint256 btcAmount) public onlyWhitelisted(msg.sender) {
    rbtcInSystem = rbtcInSystem.add(btcAmount);
  }

  /**
    @dev All BPros in circulation
   */
  function bproTotalSupply() public view returns(uint256) {
    return bproToken.totalSupply();
  }

  /**
    @dev All docs in circulation
   */
  function docTotalSupply() public view returns(uint256) {
    return docToken.totalSupply();
  }

  /**
    @dev Target coverage for complete system
   */
  function cobj() public view returns(uint256) {
    return bproxManager.getBucketCobj(BUCKET_C0);
  }

  /**
    * @dev Amount of Bitcoins in the system excluding
    * BTCx values and interests holdings
    */
  function collateralRbtcInSystem() public view returns(uint256) {
    uint256 rbtcInBtcx = mocConverter.bproxToBtc(bproxManager.getBucketNBPro(BUCKET_X2),BUCKET_X2);
    uint256 rbtcInBag = bproxManager.getInrateBag(BUCKET_C0);

    return rbtcInSystem.sub(rbtcInBtcx).sub(rbtcInBag);
  }

  /** @dev GLOBAL Coverage
    * @return coverage [using mocPrecision]
    */
  function globalCoverage() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    return mocLibConfig.coverage(collateralRbtcInSystem(), lB);
  }

  /**
  * @dev BUCKET lockedBitcoin
  * @param bucket Name of the bucket used
  * @return lockedBitcoin amount [using reservePrecision]
  */
  function lockedBitcoin(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);

    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), nDoc, peg);
  }

  /**
  * @dev Gets RBTC in BitPro within specified bucket
  * @param bucket Name of the bucket used
  * @return Bitcoin amount of BitPro in Bucket [using reservePrecision]
  */
  function getRbtcInBitPro(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 lB = lockedBitcoin(bucket);

    if ( lB >= nB ){
      return 0;
    }

    return nB.sub(lB);
  }

  /**
  * @dev Gets the RBTC in the contract that not corresponds
    to Doc collateral
  * @return RBTC remainder [using reservePrecision]
  */
  function getRbtcRemainder() public view returns(uint256) {
    uint256 lB = globalLockedBitcoin();

    if ( lB >= rbtcInSystem ){
      return 0;
    }

    return rbtcInSystem.sub(lB);
  }

  /**
  * @dev BUCKET Coverage
  * @param bucket Name of the bucket used
  * @return coverage [using coveragePrecision]
  */
  function coverage(bytes32 bucket) public view returns(uint256) {
    if (!bproxManager.isBucketBase(bucket) && bproxManager.isBucketEmpty(bucket)) {
      return bproxManager.getBucketCobj(bucket);
    }

    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 lB = lockedBitcoin(bucket);

    return mocLibConfig.coverage(nB, lB);
  }

    /**
  * @dev Abundance ratio, receives tha amount of doc to use the value of doc0 and Doc total supply
  * @return abundance ratio [using mocPrecision]
  */
  function abundanceRatio(uint256 doc0) public view returns(uint256) {
    return mocLibConfig.abundanceRatio(doc0, docTotalSupply());
  }

  /**
  * @dev Relation between docs in bucket 0 and Doc total supply
  * @return abundance ratio [using mocPrecision]
  */
  function currentAbundanceRatio() public view returns(uint256) {
    return abundanceRatio(getBucketNDoc(BUCKET_C0));
  }

  /**
  * @dev BUCKET Leverage
  * @param bucket Name of the bucket used
  * @return coverage [using mocPrecision]
  */
  function leverage(bytes32 bucket) public view returns(uint256) {
    uint256 cov = coverage(bucket);

    return mocLibConfig.leverageFromCoverage(cov);
  }

  /**
  * @dev GLOBAL maxDoc
  * @return abundance ratio [using mocPrecision]
  */
  function globalMaxDoc() public view returns(uint256) {
    return mocLibConfig.maxDoc(collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons());
  }

  /**
  * @return amount of docs in bucket 0, that can be redeemed outside of settlement [using mocPrecision]
  */
  function freeDoc() public view returns(uint256) {
    return bproxManager.getBucketNDoc(BUCKET_C0);
  }

  /**
  * @dev BUCKET maxDoc
  * @return abundance ratio [using mocPrecision]
  */
  function maxDoc(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);
    uint256 bktCobj = bproxManager.getBucketCobj(bucket);

    return mocLibConfig.maxDoc(nB, bktCobj, nDoc, peg, getBitcoinPrice(), getBcons());
  }

  /**
  * @dev GLOBAL maxBPro
  * @return maxBPro for redeem [using reservePrecision]
  */
  function globalMaxBPro() public view returns(uint256) {
    uint256 bproPrice = bproUsdPrice();

    return mocLibConfig.maxBPro(
      collateralRbtcInSystem(), cobj(), docTotalSupply(), peg, getBitcoinPrice(), getBcons(), bproPrice
    );
  }

  /**
  * @dev ABSOLUTE maxDoc
  * @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxDoc() public view returns(uint256) {
    return Math.min(globalMaxDoc(), maxDoc(BUCKET_C0));
  }

  /** @dev BUCKET maxBPro to redeem / mint
      @param bucket Name of the bucket used
    * @return maxBPro for redeem [using mocPrecision]
    */
  function maxBPro(bytes32 bucket) public view returns(uint256) {
    uint256 nB = bproxManager.getBucketNBTC(bucket);
    uint256 nDoc = bproxManager.getBucketNDoc(bucket);
    uint256 bproPrice = bproUsdPrice();
    uint256 bktCobj = bproxManager.getBucketCobj(bucket);

    return mocLibConfig.maxBPro(
      nB, bktCobj, nDoc, peg, getBitcoinPrice(), getBcons(), bproPrice
    );
  }

 /**
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return maxBProx [using reservePrecision]
  */
  function maxBProx(bytes32 bucket) public view returns(uint256) {
    uint256 maxBtc = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(maxBtc, bucketBProTecPrice(bucket));
  }

  /**
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return maxBProx BTC value to mint [using reservePrecision]
  */
  function maxBProxBtcValue(bytes32 bucket) public view returns(uint256) {
    uint256 nDoc0 = bproxManager.getBucketNDoc(BUCKET_C0);
    uint256 bucketLev = leverage(bucket);

    return mocLibConfig.maxBProxBtcValue(nDoc0, peg, getBitcoinPrice(), bucketLev);
  }

  /** @dev ABSOLUTE maxBPro
  * @return maxDoc to issue [using mocPrecision]
  */
  function absoluteMaxBPro() public view returns(uint256) {
    return Math.min(globalMaxBPro(), maxBPro(BUCKET_C0));
  }

  /**
  * @dev DISCOUNT maxBPro
  * @return maxBPro for mint with discount [using mocPrecision]
  */
  function maxBProWithDiscount() public view returns(uint256) {
    uint256 nDoc = docTotalSupply();
    uint256 bproSpotDiscount = bproSpotDiscountRate();
    uint256 bproPrice = bproUsdPrice();
    uint256 btcPrice = getBitcoinPrice();

    return mocLibConfig.maxBProWithDiscount(collateralRbtcInSystem(), nDoc, utpdu, peg, btcPrice, bproPrice,
      bproSpotDiscount);
  }

  /**
  * @dev GLOBAL lockedBitcoin
  * @return lockedBitcoin amount [using reservePrecision]
  */
  function globalLockedBitcoin() public view returns(uint256) {
    return mocLibConfig.lockedBitcoin(getBitcoinPrice(), docTotalSupply(), peg);
  }

  /**
  * @dev BTC price of BPro
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bproTecPrice() public view returns(uint256) {
    return bucketBProTecPrice(BUCKET_C0);
  }

  /**
  * @dev BUCKET BTC price of BPro
  * @param bucket Name of the bucket used
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bucketBProTecPrice(bytes32 bucket) public view returns(uint256) {
    uint256 nBPro = bproxManager.getBucketNBPro(bucket);
    uint256 lb = lockedBitcoin(bucket);
    uint256 nB = bproxManager.getBucketNBTC(bucket);

    return mocLibConfig.bproTecPrice(nB, lb, nBPro);
  }

  /**
  * @dev BTC price of BPro with spot discount applied
  * @return the BPro Tec Price [using reservePrecision]
  */
  function bproDiscountPrice() public view returns(uint256) {
    uint256 bproTecprice = bproTecPrice();
    uint256 discountRate = bproSpotDiscountRate();

    return mocLibConfig.applyDiscountRate(bproTecprice, discountRate);
  }

  /**
  * @dev BPro USD PRICE
  * @return the BPro USD Price [using mocPrecision]
  */
  function bproUsdPrice() public view returns(uint256) {
    uint256 bproBtcPrice = bproTecPrice();
    uint256 btcPrice = getBitcoinPrice();

    return btcPrice.mul(bproBtcPrice).div(mocLibConfig.reservePrecision);
  }

 /**
  * @dev GLOBAL max bprox to mint
  * @param bucket Name of the bucket used
  * @return max BPro allowed to be spent to mint BProx [using reservePrecision]
  **/
  function maxBProxBProValue(bytes32 bucket) public view returns(uint256) {
    uint256 btcValue = maxBProxBtcValue(bucket);

    return mocLibConfig.maxBProWithBtc(btcValue, bproTecPrice());
  }

  /**
  * @dev BUCKET BProx price in BPro
  * @param bucket Name of the bucket used
  * @return BProx BPro Price [using mocPrecision]
  */
  function bproxBProPrice(bytes32 bucket) public view returns(uint256) {
    // Otherwise, it reverts.
    if (state == States.Liquidated) {
      return 0;
    }

    uint256 bproxBtcPrice = bucketBProTecPrice(bucket);
    uint256 bproBtcPrice = bproTecPrice();

    return mocLibConfig.bproxBProPrice(bproxBtcPrice, bproBtcPrice);
  }

  /**
  * @dev GLOBAL BTC Discount rate to apply to BProPrice.
  * @return BPro discount rate [using DISCOUNT_PRECISION].
   */
  function bproSpotDiscountRate() public view returns(uint256) {
    uint256 cov = globalCoverage();

    return mocLibConfig.bproSpotDiscountRate(bproMaxDiscountRate, liq, utpdu, cov);
  }

  /**
    @dev Calculates the number of days to next settlement based dayBlockSpan
   */
  function daysToSettlement() public view returns(uint256) {
    return blocksToSettlement().mul(mocLibConfig.dayPrecision).div(dayBlockSpan);
  }

  /**
    @dev Number of blocks to settlement
   */
  function blocksToSettlement() public view returns(uint256) {
    if (mocSettlement.nextSettlementBlock() <= block.number) {
      return 0;
    }

    return mocSettlement.nextSettlementBlock().sub(block.number);
  }

  /**
   * @dev Verifies if forced liquidation is reached checking if globalCoverage <= liquidation (currently 1.04)
   * @return true if liquidation state is reached, false otherwise
   */
  function isLiquidationReached() public view returns(bool) {
    uint256 cov = globalCoverage();
    if (state != States.Liquidated && cov <= liq)
      return true;
    return false;
  }

  /**
    @dev Returns the price to use for doc redeem in a liquidation event
   */
  function getLiquidationPrice() public view returns(uint256) {
    return liquidationPrice;
  }

  function getBucketNBTC(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNBTC(bucket);
  }

  function getBucketNBPro(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNBPro(bucket);
  }

  function getBucketNDoc(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketNDoc(bucket);
  }

  function getBucketCobj(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getBucketCobj(bucket);
  }

  function getInrateBag(bytes32 bucket) public view returns(uint256) {
    return bproxManager.getInrateBag(bucket);
  }

  /**********************
    BTC PRICE PROVIDER
   *********************/

  function getBcons() public view returns(uint256) {
    return Math.min(getBitcoinPrice(), getBitcoinMovingAverage());
  }

  function getBitcoinPrice() public view returns(uint256) {
    (bytes32 price, bool has) = btcPriceProvider.peek();
    require(has, "Oracle have no Bitcoin Price");

    return uint256(price);
  }


  function calculateBitcoinMovingAverage() public {
    setBitcoinMovingAverage(getBitcoinPrice());
  }



  /**
   * @dev return the value of the liq threshold configuration param
   * @return liq threshold, currently 1.04
   */
  function getLiq() public view returns(uint256) {
    return liq;
  }

  /**
   * @dev sets the value of the liq threshold configuration param
   * @param _liq liquidation threshold
   */
  function setLiq(uint _liq) public onlyAuthorizedChanger(){
    liq = _liq;
  }

  /**
   * @dev return the value of the utpdu threshold configuration param
   * @return utpdu Universal TPro discount sales coverage threshold
   */
  function getUtpdu() public view returns(uint256) {
    return utpdu;
  }

  /**
   * @dev sets the value of the utpdu threshold configuration param
   * @param _utpdu Universal TPro discount sales coverage threshold
   */
  function setUtpdu(uint _utpdu) public onlyAuthorizedChanger(){
    utpdu = _utpdu;
  }

  /**
   * @dev returns the relation between DOC and dollar. By default it is 1.
   * @return peg relation between DOC and dollar
   */
  function getPeg() public view returns(uint256) {
    return peg;
  }

  /**
   * @dev sets the relation between DOC and dollar. By default it is 1.
   * @param _peg relation between DOC and dollar
   */
  function setPeg(uint _peg) public onlyAuthorizedChanger(){
    peg = _peg;
  }

  function nextState() public {
    // There is no coming back from Liquidation
    if (state == States.Liquidated)
      return;

    States prevState = state;
    calculateBitcoinMovingAverage();
    uint256 cov = globalCoverage();
    if (cov <= liq) {
      setLiquidationPrice();
      state = States.Liquidated;
    } else if (cov > liq && cov <= utpdu) {
      state = States.BProDiscount;
    } else if (cov > utpdu && cov <= cobj()) {
      state = States.BelowCobj;
    } else {
      state = States.AboveCobj;
    }

    if (prevState != state)
      emit StateTransition(state);
  }


  /**
    @dev Calculates price at liquidation event as the relation between
    the doc total supply and the amount of RBTC available to distribute
   */
  function setLiquidationPrice() internal {
    // When coverage is below 1, the amount to
    // distribute is all the RBTC in the contract
    uint256 rbtcAvailable = Math.min(globalLockedBitcoin(), rbtcInSystem);

    liquidationPrice = mocLibConfig.liquidationPrice(rbtcAvailable, docTotalSupply());
  }

  function initializeValues(
    address _governor,
    address _btcPriceProvider,
    uint256 _liq,
    uint256 _utpdu,
    uint256 _maxDiscRate,
    uint256 _dayBlockSpan,
    uint256 _maxMintBPro) internal {
    liq = _liq;
    utpdu = _utpdu;
    bproMaxDiscountRate = _maxDiscRate;
    dayBlockSpan = _dayBlockSpan;
    governor = IGovernor(_governor);
    btcPriceProvider = BtcPriceProvider(_btcPriceProvider);
    // Default values
    state = States.AboveCobj;
    peg = 1;
    maxMintBPro = _maxMintBPro;
  }

  function initializeContracts() internal  {
    mocSettlement = MoCSettlement(connector.mocSettlement());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocConverter = MoCConverter(connector.mocConverter());
  }

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/

  // Max value posible to mint of BPro
  uint256 public maxMintBPro;

  /**
  * @param _maxMintBPro [using mocPrecision]
  **/
  function setMaxMintBPro(uint256 _maxMintBPro) public onlyAuthorizedChanger() {
    maxMintBPro = _maxMintBPro;
  }

   /**
   * @dev return Max value posible to mint of BPro
   * @return maxMintBPro
   */
  function getMaxMintBPro() public view returns(uint256) {
    return maxMintBPro;
  }

  /**
  * @dev return the bpro available to mint
  * @return maxMintBProAvalaible  [using mocPrecision]
  */
  function maxMintBProAvalaible() public view returns(uint256) {

    uint256 totalBPro = bproTotalSupply();
    uint256 maxiMintBPro = getMaxMintBPro();

    if (totalBPro >= maxiMintBPro) {
      return 0;
    }

    uint256 availableMintBPro = maxiMintBPro.sub(totalBPro);

    return availableMintBPro;
  }

  /** END UPDATE V017: 01/11/2019 **/

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}


















contract MoCConverter is MoCBase, MoCLibConnection {
  MoCState internal mocState;

  function initialize(address connectorAddress) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    mocState = MoCState(connector.mocState());
  }

  /**
  * @dev BTC equivalent for the amount of bpros given
  * @param amount Amount of BPro to calculate the total price
  * @return total BTC Price of the amount BPros [using reservePrecision]
  */
  function bproToBtc(uint256 amount) public view returns(uint256) {
    uint256 tecPrice = mocState.bproTecPrice();

    return mocLibConfig.totalBProInBtc(amount, tecPrice);
  }

  function btcToBPro(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, mocState.bproTecPrice());
  }

  /**
  * @dev BTC equivalent for the amount of bpro given applying the spotDiscountRate
  * @param amount amount of BPro [using mocPrecision]
   */
  function bproDiscToBtc(uint256 amount) public view returns(uint256) {
    uint256 discountRate = mocState.bproSpotDiscountRate();
    uint256 totalBtcValue = bproToBtc(amount);

    return mocLibConfig.applyDiscountRate(totalBtcValue, discountRate);
  }

  function btcToBProDisc(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, mocState.bproDiscountPrice());
  }

  function docsToBtc(uint256 docAmount) public view returns(uint256) {
    return mocLibConfig.docsBtcValue(docAmount, mocState.peg(), mocState.getBitcoinPrice());
  }

  function docsToBtcWithPrice(uint256 docAmount, uint256 btcPrice) public view returns(uint256) {
    return mocLibConfig.docsBtcValue(docAmount, mocState.peg(), btcPrice);
  }

  function btcToDoc(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxDocsWithBtc(btcAmount, mocState.getBitcoinPrice());
  }

  function bproxToBtc(uint256 bproxAmount, bytes32 bucket) public view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproxAmount, mocState.bucketBProTecPrice(bucket));
  }

  function btcToBProx(uint256 btcAmount, bytes32 bucket) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, mocState.bucketBProTecPrice(bucket));
  }

  function btcToBProWithPrice(uint256 btcAmount, uint256 price) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, price);
  }

  function bproToBtcWithPrice(uint256 bproAmount, uint256 bproPrice) public view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproAmount, bproPrice);
  }
  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}


contract MoCInrateEvents {
  event InrateDailyPay(uint256 amount, uint256 daysToSettlement, uint256 nReserveBucketC0);
  event RiskProHoldersInterestPay(uint256 amount, uint256 nReserveBucketC0BeforePay);
}

contract MoCInrateStructs {
  struct InrateParams {
    uint256 tMax;
    uint256 tMin;
    uint256 power;
  }

  InrateParams btcxParams = InrateParams({
    tMax: 261157876067800,
    tMin: 0,
    power: 1
  });
}


contract MoCInrate is MoCInrateEvents, MoCInrateStructs, MoCBase, MoCLibConnection, Governed {
  using SafeMath for uint256;

  // Last block when a payment was executed
  uint256 public lastDailyPayBlock;
  // Absolute  BitPro holders rate for the given bitProInterestBlockSpan time span. [using mocPrecision]
  uint256 public bitProRate;
  // Target address to transfer BitPro holders interests
  address payable public bitProInterestAddress;
  // Last block when an BitPro holders instereste was calculated
  uint256 public lastBitProInterestBlock;
  // BitPro interest Blockspan to configure blocks between payments
  uint256 public bitProInterestBlockSpan;

  // Target addres to transfer commissions of mint/redeem
  address payable public commissionsAddress;
  // commissionRate [using mocPrecision]
  uint256 public commissionRate;

  /**CONTRACTS**/
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCBProxManager internal bproxManager;

  /************************************/
  /***** UPGRADE v017       ***********/
  /************************************/

  /** START UPDATE V017: 01/11/2019 **/

  // Upgrade to support red doc inrate parameter
  uint256 public docTmin;
  uint256 public docPower;
  uint256 public docTmax;

  function setDoCTmin(uint256 _docTmin) public onlyAuthorizedChanger() {
    docTmin = _docTmin;
  }

  function setDoCTmax(uint256 _docTmax) public onlyAuthorizedChanger() {
    docTmax = _docTmax;
  }

  function setDoCPower(uint256 _docPower) public onlyAuthorizedChanger(){
    docPower = _docPower;
  }

  function getDoCTmin() public view returns(uint256) {
    return docTmin;
  }

  function getDoCTmax() public view returns(uint256) {
    return docTmax;
  }

  function getDoCPower() public view returns(uint256) {
    return docPower;
  }

  /**
    @dev Calculates an average interest rate between after and before free doc Redemption

    @param docRedeem Docs to redeem [using mocPrecision]
    @return Interest rate value [using mocPrecision]
   */
  function docInrateAvg(uint256 docRedeem) public view returns(uint256) {
    uint256 preAbRatio = mocState.currentAbundanceRatio();
    uint256 posAbRatio = mocState.abundanceRatio(bproxManager.getBucketNDoc(BUCKET_C0).sub(docRedeem));

    return mocLibConfig.inrateAvg(docTmax, docPower, docTmin, preAbRatio, posAbRatio);
  }

  /** END UPDATE V017: 01/11/2019 **/

  function initialize(
    address connectorAddress,
    address _governor,
    uint256 btcxTmin,
    uint256 btcxPower,
    uint256 btcxTmax,
    uint256 _bitProRate,
    uint256 blockSpanBitPro,
    address payable bitProInterestTargetAddress,
    address payable commissionsAddressTarget,
    uint256 commissionRateParam,
    uint256 _docTmin,
    uint256 _docPower,
    uint256 _docTmax
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeValues(
      _governor,
      btcxTmin,
      btcxPower,
      btcxTmax,
      _bitProRate,
      commissionsAddressTarget,
      commissionRateParam,
      blockSpanBitPro,
      bitProInterestTargetAddress,
      _docTmin,
      _docPower,
      _docTmax
    );
  }

  /**
   * @dev gets tMin param of BTCX tokens
   * @return returns tMin of BTCX
   */
  function getBtcxTmin() public view returns(uint256) {
    return btcxParams.tMin;
  }

  /**
   * @dev gets tMax param of BTCX tokens
   * @return returns tMax of BTCX
   */
  function getBtcxTmax() public view returns(uint256) {
    return btcxParams.tMax;
  }

  /**
   * @dev gets power param of BTCX tokens
   * @return returns power of BTCX
   */
  function getBtcxPower() public view returns(uint256) {
    return btcxParams.power;
  }

  /**
   * @dev Gets the blockspan of BPRO that represents the frecuency of BitPro holders intereset payment
   * @return returns power of bitProInterestBlockSpan
   */
  function getBitProInterestBlockSpan() public view returns(uint256) {
    return bitProInterestBlockSpan;
  }

  /**
   * @dev sets tMin param of BTCX tokens
   * @param _btxcTmin tMin of BTCX
   */
  function setBtcxTmin(uint256 _btxcTmin) public onlyAuthorizedChanger() {
    btcxParams.tMin = _btxcTmin;
  }

  /**
   * @dev sets tMax param of BTCX tokens
   * @param _btxcTax tMax of BTCX
   */
  function setBtcxTmax(uint256 _btxcTax) public onlyAuthorizedChanger() {
    btcxParams.tMax = _btxcTax;
  }

  /**
   * @dev sets power param of BTCX tokens
   * @param _btxcPower power of BTCX
   */
  function setBtcxPower(uint256 _btxcPower) public onlyAuthorizedChanger(){
    btcxParams.power = _btxcPower;
  }

  /**
   @dev Gets the rate for BitPro Holders
   @return BitPro Rate
  */
  function getBitProRate() public view returns(uint256){
    return bitProRate;
  }

  function getCommissionRate() public view returns(uint256) {
    return commissionRate;
  }

   /**
    @dev Sets BitPro Holders rate
    @param newBitProRate New BitPro rate
   */
  function setBitProRate(uint256 newBitProRate) public onlyAuthorizedChanger() {
    bitProRate = newBitProRate;
  }

   /**
    @dev Sets the blockspan BitPro Intereset rate payment is enable to be executed
    @param newBitProBlockSpan New BitPro Block span
   */
  function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) public onlyAuthorizedChanger() {
    bitProInterestBlockSpan = newBitProBlockSpan;
  }

  /**
   @dev Gets the target address to transfer BitPro Holders rate
   @return Target address to transfer BitPro Holders interest
  */
  function getBitProInterestAddress() public view returns(address payable){
    return bitProInterestAddress;
  }

   /**
    @dev Sets the target address to transfer BitPro Holders rate
    @param newBitProInterestAddress New BitPro rate
   */
  function setBitProInterestAddress(address payable newBitProInterestAddress ) public onlyAuthorizedChanger() {
    bitProInterestAddress = newBitProInterestAddress;
  }

   /**
    @dev Sets the target address to transfer commissions of Mint/Redeem transactions
    @param newCommissionsAddress New commisions address
   */
  function setCommissionsAddress(address payable newCommissionsAddress) public onlyAuthorizedChanger() {
    commissionsAddress = newCommissionsAddress;
  }

   /**
    @dev Sets the commission rate for Mint/Redeem transactions
    @param newCommissionRate New commission rate
   */
  function setCommissionRate(uint256 newCommissionRate) public onlyAuthorizedChanger() {
    commissionRate = newCommissionRate;
  }

  /**
    @dev Calculates interest rate for BProx Minting, redeem and Free Doc Redeem
    @return Interest rate value [using RatePrecsion]
   */
  function spotInrate() public view returns(uint256) {
    uint256 abRatio = mocState.currentAbundanceRatio();

    return mocLibConfig.spotInrate(btcxParams.tMax, btcxParams.power, btcxParams.tMin, abRatio);
  }

  /**
    @dev Calculates an average interest rate between after and before mint/redeem

    @param bucket Name of the bucket involved in the operation
    @param btcAmount Value of the operation from which calculates the inrate [using reservePrecision]
    @param onMinting Value that represents if the calculation is based on mint or on redeem
    @return Interest rate value [using mocPrecision]
   */
  function btcxInrateAvg(bytes32 bucket, uint256 btcAmount, bool onMinting) public view returns(uint256) {
    uint256 preAbRatio = mocState.currentAbundanceRatio();
    uint256 posAbRatio = mocState.abundanceRatio(simulateDocMovement(bucket, btcAmount, onMinting));

    return mocLibConfig.inrateAvg(btcxParams.tMax, btcxParams.power, btcxParams.tMin, preAbRatio, posAbRatio);
  }

  /**
    @dev returns the amount of BTC to pay in concept of interest
    to bucket C0
   */
  function dailyInrate() public view returns(uint256) {
    uint256 daysToSettl = mocState.daysToSettlement();
    uint256 totalInrateInBag = bproxManager.getInrateBag(BUCKET_C0);

    if (daysToSettl < mocLibConfig.dayPrecision) {
      return totalInrateInBag;
    }

    // ([RES] * [DAY] / ([DAY] + [DAY])) = [RES]
    // inrateBag / (daysToSettlement + 1)
    uint256 toPay = totalInrateInBag
      .mul(mocLibConfig.dayPrecision)
      .div(daysToSettl.add(mocLibConfig.dayPrecision));

    return toPay;
  }

  /**
    @dev Extract the inrate from the passed RBTC value for Bprox minting operation
    @param bucket Bucket to use to calculate interés
    @param rbtcAmount Total value from which extract the interest rate [using reservePrecision]
    @return RBTC to pay in concept of interests [using reservePrecision]
  */
  function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) public view returns(uint256) {
    // Calculate Reserves to move in the operation
    uint256 rbtcToMove = mocLibConfig.bucketTransferAmount(rbtcAmount, mocState.leverage(bucket));
    // Calculate interest rate
    uint256 inrateValue = btcxInrateAvg(bucket, rbtcAmount, true); // Minting
    uint256 finalInrate = inrateToSettlement(inrateValue, true); // Minting

    // Final interest
    return mocLibConfig.getInterestCost(rbtcToMove, finalInrate);
  }

  /**
    @dev Extract the inrate from the passed RBTC value for the Doc Redeem operation
    @param docAmount Doc amount of the redemption [using mocPrecision]
    @param rbtcAmount Total value from which extract the interest rate [using reservePrecision]
    @return RBTC to pay in concept of interests [using reservePrecision]
  */
  function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) public view returns(uint256) {
    uint256 rate = docInrateAvg(docAmount);
    uint256 finalInrate = inrateToSettlement(rate, true);
    uint256 interests = mocLibConfig.getInterestCost(rbtcAmount, finalInrate);

    return interests;
  }

  /**
    @dev This function calculates the interest to return to the user
    in a BPRox redemption. It uses a mechanism to counteract the effect
    of free docs redemption. It will be replaced with FreeDoC redemption
    interests in the future
    @param bucket Bucket to use to calculate interest
    @param rbtcToRedeem Total value from which calculate interest [using reservePrecision]
    @return RBTC to recover in concept of interests [using reservePrecision]
  */
  function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view returns(uint256) {
    // Get interests to return for redemption
    uint256 redeemInterest = calcRedeemInterestValue(bucket, rbtcToRedeem); // Redeem
    uint256 proportionalInterest = calcProportionalInterestValue(bucket, redeemInterest);

    return Math.min(proportionalInterest, redeemInterest);
  }

  /**
    @dev calculates the Commission rate from the passed RBTC amount for mint/redeem operations
    @param rbtcAmount Total value from which apply the Commission rate [using reservePrecision]
    @return finalCommissionAmount [using reservePrecision]
  */
  function calcCommissionValue(uint256 rbtcAmount)
  public view returns(uint256) {
    uint256 finalCommissionAmount = rbtcAmount.mul(commissionRate).div(mocLibConfig.mocPrecision);
    return finalCommissionAmount;
  }

  /**
    @dev Calculates RBTC value to return to the user in concept of interests
    @param bucket Bucket to use to calculate interest
    @param rbtcToRedeem Total value from which calculate interest [using reservePrecision]
    @return RBTC to recover in concept of interests [using reservePrecision]
  */
  function calcRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) public view returns(uint256) {
    // Calculate Reserves to move in the operation
    uint256 rbtcToMove = mocLibConfig.bucketTransferAmount(rbtcToRedeem, mocState.leverage(bucket));
    // Calculate interest rate
    uint256 inrate = btcxInrateAvg(bucket, rbtcToRedeem, false); // Redeem
    uint256 finalInrate = inrateToSettlement(inrate, false); // Redeem

    // Calculate interest for the redemption
    return mocLibConfig.getInterestCost(rbtcToMove, finalInrate);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public
  onlyWhitelisted(msg.sender) onlyOnceADay() returns(uint256) {
    uint256 toPay = dailyInrate();
    lastDailyPayBlock = block.number;

    if (toPay != 0) {
      bproxManager.deliverInrate(BUCKET_C0, toPay);
    }

    emit InrateDailyPay(toPay, mocState.daysToSettlement(), mocState.getBucketNBTC(BUCKET_C0));
  }

  function isDailyEnabled() public view returns(bool) {
    return lastDailyPayBlock == 0 || block.number > lastDailyPayBlock + mocState.dayBlockSpan();
  }

  function isBitProInterestEnabled() public view returns(bool) {
    return lastBitProInterestBlock == 0 || block.number > (lastBitProInterestBlock + bitProInterestBlockSpan);
  }

  /**
   * @dev Calculates BitPro Holders interest rates
   * @return toPay interest in RBTC [using RBTCPrecsion]
   * @return bucketBtnc0 RTBC on bucket0 used to calculate de interest [using RBTCPrecsion]
   */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    uint256 bucketBtnc0 = bproxManager.getBucketNBTC(BUCKET_C0);
    uint256 toPay = (bucketBtnc0.mul(bitProRate).div(mocLibConfig.mocPrecision));
    return (toPay, bucketBtnc0);
  }

  /**
   * @dev Pays the BitPro Holders interest rates
   * @return interest payed in RBTC [using RBTCPrecsion]
   */
  function payBitProHoldersInterestPayment() public
  onlyWhitelisted(msg.sender)
  onlyWhenBitProInterestsIsEnabled() returns(uint256) {
    (uint256 bitProInterest, uint256 bucketBtnc0) = calculateBitProHoldersInterest();
    lastBitProInterestBlock = block.number;
    emit RiskProHoldersInterestPay(bitProInterest, bucketBtnc0);
    return bitProInterest;
  }

  /**
    @dev Calculates the interest rate to pay until the settlement day
    @param inrate Spot interest rate
    @param countAllDays Value that represents if the calculation will use all days or one day less
    @return Interest rate value [using RatePrecsion]
   */
  function inrateToSettlement(uint256 inrate, bool countAllDays) internal view returns(uint256) {
    uint256 dayCount = inrateDayCount(countAllDays);

    return inrate.mul(dayCount).div(mocLibConfig.dayPrecision);
  }

  /**
    @dev This function calculates the interest to return to a user redeeming
    BTCx as a proportion of the amount in the interestBag.
    @param bucket Bucket to use to calculate interest
    @param redeemInterest Total value from which calculate interest [using reservePrecision]
    @return InterestsInBag * (RedeemInterests / FullRedeemInterest) [using reservePrecision]

  */
  function calcProportionalInterestValue(bytes32 bucket, uint256 redeemInterest) internal view returns(uint256) {
    uint256 fullRedeemInterest = calcFullRedeemInterestValue(bucket);
    uint256 interestsInBag = bproxManager.getInrateBag(BUCKET_C0);

    if (fullRedeemInterest == 0) {
      return 0;
    }

    // Proportional interests amount
    return redeemInterest.mul(interestsInBag).div(fullRedeemInterest); // [RES] * [RES] / [RES]
  }

  /**
    @dev This function calculates the interest to return
    if a user redeem all Btcx in existance
    @param bucket Bucket to use to calculate interest
    @return Interests [using reservePrecision]
  */
  function calcFullRedeemInterestValue(bytes32 bucket) internal view returns(uint256) {
    // Value in RBTC of all BProxs in the bucket
    uint256 fullBProxRbtcValue = mocConverter.bproxToBtc(bproxManager.getBucketNBPro(bucket), bucket);
    // Interests to return if a redemption of all Bprox is done
    return calcRedeemInterestValue(bucket, fullBProxRbtcValue); // Redeem
  }

  /**
    @dev Calculates the final amount of Bucket 0 DoCs on BProx mint/redeem

    @param bucket Name of the bucket involved in the operation
    @param btcAmount Value of the operation from which calculates the inrate [using reservePrecision]
    @return Final bucket 0 Doc amount
   */
  function simulateDocMovement(bytes32 bucket, uint256 btcAmount, bool onMinting) internal view returns(uint256) {
    // Calculates docs to move
    uint256 btcToMove = mocLibConfig.bucketTransferAmount(btcAmount, mocState.leverage(bucket));
    uint256 docsToMove = mocConverter.btcToDoc(btcToMove);

    if (onMinting) {
      /* Should not happen when minting bpro because it's
      not possible to mint more than max bprox but is
      useful when trying to calculate inrate before minting */
      return bproxManager.getBucketNDoc(BUCKET_C0) > docsToMove ? bproxManager.getBucketNDoc(BUCKET_C0).sub(docsToMove) : 0;
    } else {
      return bproxManager.getBucketNDoc(BUCKET_C0).add(Math.min(docsToMove, bproxManager.getBucketNDoc(bucket)));
    }
  }

  /**
    @dev Returns the days to use for interests calculation

    @param countAllDays Value that represents if the calculation is based on mint or on redeem
    @return days [using dayPrecision]
   */
  function inrateDayCount(bool countAllDays) internal view returns(uint256) {
    uint256 daysToSettl = mocState.daysToSettlement();

    if (daysToSettl < mocLibConfig.dayPrecision){
      return 0;
    }

    if (countAllDays) {
      return daysToSettl;
    }

    return daysToSettl.sub(mocLibConfig.dayPrecision);
  }

  modifier onlyOnceADay() {
    require(isDailyEnabled(), "Interest rate already payed today");
    _;
  }

  modifier onlyWhenBitProInterestsIsEnabled() {
    require(isBitProInterestEnabled(), "Interest rate of BitPro holders already payed this week");
    _;
  }

  /**
   * @dev Initialize the contracts with which it interacts
   */
  function initializeContracts() internal {
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
  }

  /**
   * @dev Initialize the parameters of the contract
   * @param _governor the address of the IGovernor contract
   * @param btcxMin Minimum interest rate [using mocPrecision]
   * @param btcxPower Power is a parameter for interest rate calculation [using noPrecision]
   * @param btcxMax Maximun interest rate [using mocPrecision]
   * @param _bitProRate BitPro holder interest rate [using mocPrecision]
   * @param blockSpanBitPro BitPro blockspan to configure payments periods[using mocPrecision]

   * @param bitProInterestsTarget Target address to transfer the weekly BitPro holders interest
   */
  function initializeValues(
    address _governor,
    uint256 btcxMin,
    uint256 btcxPower,
    uint256 btcxMax,
    uint256 _bitProRate,
    address payable commissionsAddressTarget,
    uint256 commissionRateParam,
    uint256 blockSpanBitPro,
    address payable bitProInterestsTarget,
    uint256 _docTmin,
    uint256 _docPower,
    uint256 _docTmax
  ) internal {
    governor = IGovernor(_governor);
    btcxParams.tMin = btcxMin;
    btcxParams.power = btcxPower;
    btcxParams.tMax = btcxMax;
    bitProRate = _bitProRate;
    bitProInterestAddress = bitProInterestsTarget;
    bitProInterestBlockSpan = blockSpanBitPro;
    commissionRate = commissionRateParam;
    commissionsAddress = commissionsAddressTarget;
    docTmin = _docTmin;
    docPower = _docPower;
    docTmax = _docTmax;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}





















contract MoCBurnoutEvents {
  event BurnoutAddressSet(address indexed account, address burnoutAddress);
  event BurnoutExecuted(uint256 addressCount);
  event BurnoutAddressProcessed(address indexed account, address burnoutAddress, uint256 btcAmount);
}

/**
 * @title Burnout Queue for liquidation event
 * @dev Track all Burnout addresses that will be used in liquidation event. When liquidation happens
 * all Docs of the holders in the queue will be sent to the corresponding burnout address.
 */
contract MoCBurnout is MoCBase, MoCBurnoutEvents, PartialExecution {
  using SafeMath for uint256;

  // Contracts
  DocToken internal docToken;
  MoCExchange internal mocExchange;
  MoCState internal mocState;

  bytes32 internal constant BURNOUT_TASK = keccak256("Burnout");

  // Burnout addresses
  mapping(address => address payable) burnoutBook;
  // Used to iterate in liquidation event
  address[] private burnoutQueue;
  uint256 private numElements;

  function initialize(
    address connectorAddress
  ) public initializer {
    initializeBase(connectorAddress);
    initializeContracts();
    initializeTasks();
  }

  function isBurnoutRunning() public view returns(bool) {
    return isTaskRunning(BURNOUT_TASK);
  }

  /**
    @dev Return current burnout queue size
   */
  function burnoutQueueSize() public view returns(uint256) {
    return numElements;
  }

  /**
    @dev Returns the burnout address for _who address
    @param _who Address to find burnout address
    @return Burnout address
   */
  function getBurnoutAddress(address _who) public view returns(address) {
    return burnoutBook[_who];
  }

  /**
    @dev push a new burnout address to the queue for _who
    @param _who address for which set the burnout address
    @param _burnout address to send docs in liquidation event
  */
  function pushBurnoutAddress(address _who, address payable _burnout) public onlyWhitelisted(msg.sender) {
    require(_burnout != address(0x0), "Burnout address can't be 0x0");

    if (burnoutBook[_who] == address(0x0)) {
      pushAddressToQueue(_who);
    }

    burnoutBook[_who] = _burnout;
    emit BurnoutAddressSet(_who, _burnout);
  }

  /**
    @dev Iterate over the burnout address book and redeem docs
  **/
  function executeBurnout(uint256 steps) public onlyWhitelisted(msg.sender) {
    executeTask(BURNOUT_TASK, steps);
  }

  function burnoutStep(uint256 index) internal {
    address account = burnoutQueue[index];
    address payable burnout = burnoutBook[account];
    uint256 btcTotal = mocExchange.redeemAllDoc(account, burnout);

    emit BurnoutAddressProcessed(account, burnout, btcTotal);
  }

  function finishBurnout() internal {
    emit BurnoutExecuted(numElements);
    clearBook();
  }

  function burnoutStepCount() internal view returns(uint256) {
    return numElements;
  }

  function pushAddressToQueue(address _who) internal {
    if (numElements == burnoutQueue.length) {
      burnoutQueue.length += 1;
    }

    burnoutQueue[numElements++] = _who;
  }

  /**
    @dev empty the queue
   */
  function clearBook() internal {
    numElements = 0;
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    mocExchange = MoCExchange(connector.mocExchange());
    mocState = MoCState(connector.mocState());
  }

  /**
    @dev Create Task structures for Settlement execution
  */
  function initializeTasks() internal {
    createTask(BURNOUT_TASK, burnoutStepCount, burnoutStep, noFunction, finishBurnout);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}







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



contract MoCEvents {
  event BucketLiquidation(bytes32 bucket);
}

contract MoC is MoCEvents, MoCLibConnection, MoCBase, Stoppable  {
  using SafeMath for uint256;

  // Contracts
  DocToken internal docToken;
  BProToken internal bproToken;
  MoCBProxManager internal bproxManager;
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCSettlement internal settlement;
  MoCExchange internal mocExchange;
  MoCInrate internal mocInrate;
  MoCBurnout public mocBurnout;

  // Indicates if Rbtc remainder was sent and
  // BProToken was paused
  bool internal liquidationExecuted;

  // Fallback
  //TODO: We must research if fallback function is really needed.
  function() external payable whenNotPaused() transitionState() {
    bproxManager.addValuesToBucket(BUCKET_C0, msg.value, 0, 0);
    mocState.addToRbtcInSystem(msg.value);
  }

  function initialize(
    address connectorAddress,
    address governorAddress,
    address stopperAddress,
    bool startStoppable
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
    initializeGovernanceContracts(stopperAddress, governorAddress, startStoppable);
  }

  /****************************INTERFACE*******************************************/

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
    @dev returns current redeem queue size
   */
  function redeemQueueSize() public view returns(uint256) {
    return settlement.redeemQueueSize();
  }

  /**
    @dev returns the total amount of Docs in the redeem queue for redeemer
    @param redeemer address for which ^ is computed
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
    @dev Mints BPRO and pays the comissions of the operation.
    @param btcToMint Amount un BTC to mint
   */
  function mintBPro(uint256 btcToMint) public payable whenNotPaused() transitionState() {
    (uint256 btcExchangeSpent, uint256 commissionSpent) = mocExchange.mintBPro(msg.sender, btcToMint);

    uint256 totalBtcSpent = btcExchangeSpent.add(commissionSpent);
    require(totalBtcSpent <= msg.value, "amount is not enough");

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);

    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
   * @dev Redeems Bpro Tokens and pays the comissions of the operation in RBTC
     @param bproAmount Amout in Bpro
   */
  function redeemBPro(uint256 bproAmount) public whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    (uint256 btcAmount, uint256 commissionSpent) = mocExchange.redeemBPro(msg.sender, bproAmount);

    doTransfer(msg.sender, btcAmount);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
   * @dev Mint Doc tokens and pays the commisions of the operation
   * @param btcToMint Amount in RBTC to mint
   */
  function mintDoc(uint256 btcToMint) public payable whenNotPaused() transitionState() atLeastState(MoCState.States.AboveCobj) {
    (uint256 btcExchangeSpent, uint256 commissionSpent) = mocExchange.mintDoc(msg.sender, btcToMint);

    uint256 totalBtcSpent = btcExchangeSpent.add(commissionSpent);
    require(totalBtcSpent <= msg.value, "amount is not enough");

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);

    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
     @dev Redeems Bprox Tokens and pays the comissions of the operation in RBTC
     @param bucket Bucket to reedem, for example X2
     @param bproxAmount Amount in Bprox
   */
  function redeemBProx(bytes32 bucket, uint256 bproxAmount) public
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    (uint256 totalBtcRedeemed, uint256 commissionSpent) = mocExchange.redeemBProx(msg.sender, bucket, bproxAmount);

    doTransfer(msg.sender, totalBtcRedeemed);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
  * @dev BUCKET bprox minting
  * @param bucket Name of the bucket used
  * @param btcToMint amount to mint on RBTC
  **/
  function mintBProx(bytes32 bucket, uint256 btcToMint) public payable
  whenNotPaused() whenSettlementReady() availableBucket(bucket) notBaseBucket(bucket)
  transitionState() bucketStateTransition(bucket) {
    (uint256 btcExchangeSpent, uint256 commissionSpent) = mocExchange.mintBProx(msg.sender, bucket, btcToMint);

    uint256 totalBtcSpent = btcExchangeSpent.add(commissionSpent);
    require(totalBtcSpent <= msg.value, "amount is not enough");

    // Need to update general State
    mocState.addToRbtcInSystem(msg.value);
    // Calculate change
    uint256 change = msg.value.sub(totalBtcSpent);
    doTransfer(msg.sender, change);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
  * @dev Redeems the requested amount for the msg.sender, or the max amount of free docs possible.
  * @param docAmount Amount of Docs to redeem.
  */
  function redeemFreeDoc(uint256 docAmount) public whenNotPaused() transitionState() {
    (uint256 btcAmount, uint256 commissionSpent) = mocExchange.redeemFreeDoc(msg.sender, docAmount);

    doTransfer(msg.sender, btcAmount);

    // Transfer commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), commissionSpent);
  }

  /**
  * @dev Allow redeem on liquidation state, user DoCs get burned and he receives
  * the equivalent BTCs if can be covered, or the maximum available
  **/
  function redeemAllDoc() public atState(MoCState.States.Liquidated) {
    mocExchange.redeemAllDoc(msg.sender, msg.sender);
  }

  /**
    @dev Moves the daily amount of interest rate to C0 bucket
  */
  function dailyInratePayment() public whenNotPaused() {
    mocInrate.dailyInratePayment();
  }

  /**
  * @dev Pays the BitPro interest and transfers it to the address mocInrate.bitProInterestAddress
  * BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function payBitProHoldersInterestPayment() public whenNotPaused() {
    uint256 toPay = mocInrate.payBitProHoldersInterestPayment();
    if (doSend(mocInrate.getBitProInterestAddress(), toPay)) {
      bproxManager.substractValuesFromBucket(BUCKET_C0, toPay, 0, 0);
    }
  }

  /**
  * @dev Calculates BitPro holders holder interest by taking the total amount of RBCs available on Bucket 0.
  * BitPro interests = Nb (bucket 0) * bitProRate.
  */
  function calculateBitProHoldersInterest() public view returns(uint256, uint256) {
    return mocInrate.calculateBitProHoldersInterest();
  }

  function getBitProInterestAddress() public view returns(address payable) {
    return mocInrate.getBitProInterestAddress();
  }

  function getBitProRate() public view returns(uint256) {
    return mocInrate.getBitProRate();
  }

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
    @dev Returns true if blockSpan number of blocks has pass since last execution
  */
  function isSettlementEnabled() public view returns(bool) {
    return settlement.isSettlementEnabled();
  }

  /**
   * @dev Checks if bucket liquidation is reached.
   * @return true if bucket liquidation is reached, false otherwise
   */
  function isBucketLiquidationReached(bytes32 bucket) public view returns(bool) {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      return true;
    }
    return false;
  }

  function evalBucketLiquidation(bytes32 bucket) public availableBucket(bucket) notBaseBucket(bucket) whenSettlementReady() {
    if (mocState.coverage(bucket) <= mocState.liq()) {
      bproxManager.liquidateBucket(bucket, BUCKET_C0);

      emit BucketLiquidation(bucket);
    }
  }

  /**
  * @dev Set Burnout address.
  * @param burnoutAddress Address to which the funds will be sent on liquidation.
  */
  function setBurnoutAddress(address payable burnoutAddress) public whenNotPaused() atLeastState(MoCState.States.BProDiscount) {
    mocBurnout.pushBurnoutAddress(msg.sender, burnoutAddress);
  }

  /**
  * @dev Get Burnout address.
  */
  function getBurnoutAddress() public view returns(address) {
    return mocBurnout.getBurnoutAddress(msg.sender);
  }

  /**
  * @dev Evaluates if liquidation state has been reached and runs liq if that's the case
  */
  function evalLiquidation(uint256 steps) public {
    mocState.nextState();

    if (mocState.state() == MoCState.States.Liquidated) {
      liquidate();
      mocBurnout.executeBurnout(steps);
    }
  }

  /**
  * @dev Runs all settlement process
  */
  function runSettlement(uint256 steps) public whenNotPaused() transitionState() {
    uint256 accumCommissions = settlement.runSettlement(steps);

    // Transfer accums commissions to commissions address
    doTransfer(mocInrate.commissionsAddress(), accumCommissions);
  }

  /**
  * @dev Send RBTC to a user and update RbtcInSystem in MoCState
  * @return result of the transaction
  **/
  function sendToAddress(address payable receiver, uint256 btcAmount) public onlyWhitelisted(msg.sender) returns(bool) {
    if (btcAmount == 0) {
      return true;
    }

    return doSend(receiver, btcAmount);
  }

  function liquidate() internal {
    if (!liquidationExecuted) {
      pauseBProToken();
      sendRbtcRemainder();
      liquidationExecuted = true;
    }
  }

  /**
    @dev Transfer the value that not corresponds to
    Doc Collateral
  */
  function sendRbtcRemainder() internal {
    uint256 bitProRBTCValue = mocState.getRbtcRemainder();
    doTransfer(mocInrate.commissionsAddress(), bitProRBTCValue);
  }

  function initializeContracts() internal {
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    settlement = MoCSettlement(connector.mocSettlement());
    mocConverter = MoCConverter(connector.mocConverter());
    mocExchange = MoCExchange(connector.mocExchange());
    mocInrate = MoCInrate(connector.mocInrate());
    mocBurnout = MoCBurnout(connector.mocBurnout());
  }

  function initializeGovernanceContracts(address stopperAddress, address governorAddress, bool startStoppable) internal {
    Stoppable.initialize(stopperAddress, IGovernor(governorAddress), startStoppable);
  }

  function pauseBProToken() internal {
    if (!bproToken.paused()) {
      bproToken.pause();
    }
  }

  /**
  * @dev Transfer using transfer function and updates global RBTC register in MoCState
  **/
  function doTransfer(address payable receiver, uint256 btcAmount) private {
    mocState.subtractRbtcFromSystem(btcAmount);
    receiver.transfer(btcAmount);
  }

  /**
  * @dev Transfer using send function and updates global RBTC register in MoCState
  * @return Execution result
  **/
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

  modifier atState(MoCState.States _state) {
    require(mocState.state() == _state, "Function cannot be called at this state.");
    _;
  }

  modifier atLeastState(MoCState.States _state) {
    require(mocState.state() >= _state, "Function cannot be called at this state.");
    _;
  }

  modifier atMostState(MoCState.States _state) {
    require(mocState.state() <= _state, "Function cannot be called at this state.");
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
    if (mocState.state() == MoCState.States.Liquidated) {
      liquidate();
    }
    else
      _;
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}


contract MoCExchangeEvents {
  event RiskProMint(address indexed account, uint256 amount, uint256 reserveTotal, uint256 commission, uint256 reservePrice);
  event RiskProWithDiscountMint(uint256 riskProTecPrice, uint256 riskProDiscountPrice, uint256 amount);
  event RiskProRedeem(address indexed account, uint256 amount, uint256 reserveTotal, uint256 commission, uint256 reservePrice);
  event StableTokenMint(address indexed account, uint256 amount, uint256 reserveTotal, uint256 commission, uint256 reservePrice);
  event StableTokenRedeem(address indexed account, uint256 amount, uint256 reserveTotal, uint256 commission, uint256 reservePrice);
  event FreeStableTokenRedeem(
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 commission,
    uint256 interests,
    uint256 reservePrice
  );

  event RiskProxMint(
    bytes32 bucket,
    address indexed account,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 commission,
    uint256 reservePrice
  );

  event RiskProxRedeem(
    bytes32 bucket,
    address indexed account,
    uint256 commission,
    uint256 amount,
    uint256 reserveTotal,
    uint256 interests,
    uint256 leverage,
    uint256 reservePrice
  );
}

contract MoCExchange is MoCExchangeEvents, MoCBase, MoCLibConnection  {
  using Math for uint256;
  using SafeMath for uint256;

  // Contracts
  MoCState internal mocState;
  MoCConverter internal mocConverter;
  MoCBProxManager internal bproxManager;
  BProToken internal bproToken;
  DocToken internal docToken;
  MoCInrate internal mocInrate;
  MoC internal moc;

  function initialize(
    address connectorAddress
  ) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    initializeContracts();
  }

  /**
  * @dev Mint BPros and give it to the msg.sender
  */
  function mintBPro(address account, uint256 btcAmount) public onlyWhitelisted(msg.sender) returns(uint256, uint256) {
    uint256 bproRegularPrice = mocState.bproTecPrice();
    uint256 finalBProAmount = 0;
    uint256 btcValue = 0;

    if (mocState.state() == MoCState.States.BProDiscount)
    {
      uint256 discountPrice = mocState.bproDiscountPrice();
      uint256 bproDiscountAmount = mocConverter.btcToBProDisc(btcAmount);

      finalBProAmount = Math.min(bproDiscountAmount, mocState.maxBProWithDiscount());
      btcValue = finalBProAmount == bproDiscountAmount ? btcAmount : mocConverter.bproDiscToBtc(finalBProAmount);

      emit RiskProWithDiscountMint(bproRegularPrice, discountPrice, finalBProAmount);
    }

    if (btcAmount != btcValue)
    {
      uint256 regularBProAmount = mocConverter.btcToBPro(btcAmount.sub(btcValue));
      finalBProAmount = finalBProAmount.add(regularBProAmount);
    }

    // START Upgrade V017
    // 01/11/2019 Limiting mint bpro (no with discount)
    // Only enter with no discount state
    if (mocState.state() != MoCState.States.BProDiscount)
    {
      uint256 availableBPro = Math.min(finalBProAmount, mocState.maxMintBProAvalaible());
      if (availableBPro != finalBProAmount) {
        btcAmount = mocConverter.bproToBtc(availableBPro);
        finalBProAmount = availableBPro;

        if (btcAmount <= 0) {
          return (0, 0);
        }
      }
    }
    // END Upgrade V017

    uint256 btcCommissionPaid = mocInrate.calcCommissionValue(btcAmount);

    mintBPro(account, btcCommissionPaid, finalBProAmount, btcAmount);

    return (btcAmount, btcCommissionPaid);
  }

  /**
  * @dev Sender burns his BProS and redeems the equivalent BTCs
  * @param bproAmount Amount of BPros to be redeemed
  * @return bitcoins to transfer to the redeemer and commission spent, using [using reservePrecision]
  **/
  function redeemBPro(address account, uint256 bproAmount) public onlyWhitelisted(msg.sender) returns(uint256, uint256) {
    uint256 userBalance = bproToken.balanceOf(account);
    uint256 userAmount = Math.min(bproAmount, userBalance);

    uint256 bproFinalAmount = Math.min(userAmount, mocState.absoluteMaxBPro());
    uint256 totalBtc = mocConverter.bproToBtc(bproFinalAmount);

    uint256 btcCommission = mocInrate.calcCommissionValue(totalBtc);

    // Mint token
    bproToken.burn(account, bproFinalAmount);

    // Update Buckets
    bproxManager.substractValuesFromBucket(BUCKET_C0, totalBtc, 0, bproFinalAmount);

    uint256 btcTotalWithoutCommission = totalBtc.sub(btcCommission);

    emit RiskProRedeem(account, bproFinalAmount, btcTotalWithoutCommission, btcCommission, mocState.getBitcoinPrice());

    return (btcTotalWithoutCommission, btcCommission);
  }

  /**
  * @dev Redeems the requested amount for the account, or the max amount of free docs possible.
  * @param account Address of the redeeemer
  * @param docAmount Amount of Docs to redeem [using mocPrecision]
  * @return bitcoins to transfer to the redeemer and commission spent, using [using reservePrecision]

  */
  function redeemFreeDoc(address account, uint256 docAmount) public onlyWhitelisted(msg.sender) returns(uint256, uint256) {
    if (docAmount <= 0) {
      return (0, 0);
    } else {
      uint256 finalDocAmount = Math.min(docAmount, Math.min(mocState.freeDoc(), docToken.balanceOf(account)));
      uint256 docsBtcValue = mocConverter.docsToBtc(finalDocAmount);

      uint256 btcInterestAmount = mocInrate.calcDocRedInterestValues(finalDocAmount, docsBtcValue);
      uint256 finalBtcAmount = docsBtcValue.sub(btcInterestAmount);
      uint256 btcCommission = mocInrate.calcCommissionValue(finalBtcAmount);

      doDocRedeem(account, finalDocAmount, docsBtcValue);
      bproxManager.payInrate(BUCKET_C0, btcInterestAmount);

      emit FreeStableTokenRedeem(account, finalDocAmount, finalBtcAmount, btcCommission, btcInterestAmount, mocState.getBitcoinPrice());

      return (finalBtcAmount.sub(btcCommission), btcCommission);
    }
  }

    /**
  * @dev Mint Max amount of Docs and give it to the msg.sender
  * @param account minter user address
  * @param btcToMint btc amount the user intents to convert to DoC [using rbtPresicion]
  * @return the actual amount of btc used and the btc commission for them [using rbtPresicion]
  */
  function mintDoc(address account, uint256 btcToMint) public onlyWhitelisted(msg.sender) returns(uint256, uint256) {
    // Docs to issue with tx value amount
    if (btcToMint > 0) {
      uint256 docs = mocConverter.btcToDoc(btcToMint);
      uint256 docAmount = Math.min(docs, mocState.absoluteMaxDoc());
      uint256 totalCost = docAmount == docs ? btcToMint : mocConverter.docsToBtc(docAmount);

      // Mint Token
      docToken.mint(account, docAmount);

      // Update Buckets
      bproxManager.addValuesToBucket(BUCKET_C0, totalCost, docAmount, 0);

      uint256 btcCommission = mocInrate.calcCommissionValue(totalCost);

      emit StableTokenMint(account, docAmount, totalCost, btcCommission, mocState.getBitcoinPrice());

      return (totalCost, btcCommission);
    }

    return (0, 0);
  }

  /**
  * @dev User DoCs get burned and he receives the equivalent BTCs in return
  * @param userAddress Address of the user asking to redeem
  * @param amount Verified amount of Docs to be redeemed [using mocPrecision]
  * @param btcPrice bitcoin price [using mocPrecision]
  * @return true and commission spent if btc send was completed, false if fails.
  **/
  function redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice)
  public onlyWhitelisted(msg.sender) returns(bool, uint256){
    uint256 totalBtc = mocConverter.docsToBtcWithPrice(amount, btcPrice);

    uint256 commissionSpent = mocInrate.calcCommissionValue(totalBtc);
    uint256 btcToRedeem = totalBtc.sub(commissionSpent);

    bool result = moc.sendToAddress(userAddress, btcToRedeem);

    // If sends fail, then no redemption is executed
    if (result) {
      doDocRedeem(userAddress, amount, totalBtc);
      emit StableTokenRedeem(userAddress, amount, totalBtc.sub(commissionSpent), commissionSpent, btcPrice);
    }

    return (result, commissionSpent);
  }

  /**
  * @dev Allow redeem on liquidation state, user DoCs get burned and he receives
  * the equivalent RBTCs according to liquidationPrice
  * @param origin address owner of the DoCs
  * @param destination address to send the RBTC
  * @return The amount of RBTC in sent for the redemption or 0 if send does not succed
  **/
  function redeemAllDoc(address origin, address payable destination) public onlyWhitelisted(msg.sender) returns(uint256) {
    uint256 userDocBalance = docToken.balanceOf(origin);
    if (userDocBalance == 0)
      return 0;

    uint256 liqPrice = mocState.getLiquidationPrice();
    // [USD * RBTC / USD]
    uint256 totalRbtc = mocConverter.docsToBtcWithPrice(userDocBalance, liqPrice);

    // If send fails we don't burn the tokens
    if (moc.sendToAddress(destination, totalRbtc)) {
      docToken.burn(origin, userDocBalance);
      emit StableTokenRedeem(origin, userDocBalance, totalRbtc, 0, liqPrice);

      return totalRbtc;
    }
    else
    {
      return 0;
    }
  }


  /**
    @dev  Mint the amount of BPros
    @param account Address that will owned the BPros
    @param bproAmount Amount of BPros to mint [using mocPrecision]
    @param rbtcValue RBTC cost of the minting [using reservePrecision]
  */
  function mintBPro(address account, uint256 btcCommission, uint256 bproAmount, uint256 rbtcValue) public onlyWhitelisted(msg.sender) {
    bproToken.mint(account, bproAmount);
    bproxManager.addValuesToBucket(BUCKET_C0, rbtcValue, 0, bproAmount);

    emit RiskProMint(account, bproAmount, rbtcValue, btcCommission, mocState.getBitcoinPrice());
  }

  /**
  * @dev BUCKET Bprox minting. Mints Bprox for the specified bucket
  * @param account owner of the new minted Bprox
  * @param bucket bucket name
  * @param btcToMint rbtc amount to mint [using reservePrecision]
  * @return total RBTC Spent (btcToMint more interest) and commission spent [using reservePrecision]
  **/
  function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint
  ) public onlyWhitelisted(msg.sender) returns(uint256, uint256) {
    if (btcToMint > 0){
      uint256 lev = mocState.leverage(bucket);

      uint256 finalBtcToMint = Math.min(btcToMint, mocState.maxBProxBtcValue(bucket));

      // Get interest and the adjusted BProAmount
      uint256 btcInterestAmount = mocInrate.calcMintInterestValues(bucket, finalBtcToMint);

      // pay interest
      bproxManager.payInrate(BUCKET_C0, btcInterestAmount);

      uint256 bproxToMint = mocConverter.btcToBProx(finalBtcToMint, bucket);

      bproxManager.assignBProx(bucket, account, bproxToMint, finalBtcToMint);
      moveExtraFundsToBucket(BUCKET_C0, bucket, finalBtcToMint, lev);

      // Calculate leverage after mint
      lev = mocState.leverage(bucket);

      uint256 btcCommission = mocInrate.calcCommissionValue(finalBtcToMint);

      emit RiskProxMint(
        bucket, account, bproxToMint, finalBtcToMint,
        btcInterestAmount, lev, btcCommission, mocState.getBitcoinPrice()
      );

      return (finalBtcToMint.add(btcInterestAmount), btcCommission);
    }

    return (0, 0);
  }

  /**
  * @dev Sender burns his BProx, redeems the equivalent amount of BPros, return
  * the "borrowed" DOCs and recover pending interests
  * @param account user address to redeem bprox from
  * @param bucket Bucket where the BProxs are hold
  * @param bproxAmount Amount of BProxs to be redeemed [using mocPrecision]
  * @return the actual amount of btc to redeem and the btc commission for them [using reservePrecision]
  **/
  function redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount
  ) public onlyWhitelisted(msg.sender) returns (uint256, uint256) {
    // Revert could cause not evaluating state changing
    if (bproxManager.bproxBalanceOf(bucket, account) == 0) {
      return (0, 0);
    }

    // Calculate leverage before the redeem
    uint256 bucketLev = mocState.leverage(bucket);
    // Get redeemable value
    uint256 userBalance = bproxManager.bproxBalanceOf(bucket, account);
    uint256 bproxToRedeem = Math.min(bproxAmount, userBalance);
    uint256 rbtcToRedeem = mocConverter.bproxToBtc(bproxToRedeem, bucket);
    // //Pay interests
    uint256 rbtcInterests = recoverInterests(bucket, rbtcToRedeem);

    // Burn Bprox
    burnBProxFor(
      bucket,
      account,
      bproxToRedeem,
      mocState.bucketBProTecPrice(bucket)
    );

    if (bproxManager.getBucketNBPro(bucket) == 0) {
      // If there is no BProx left, empty bucket for rounding remnant
      bproxManager.emptyBucket(bucket, BUCKET_C0);
    } else {
      // Move extra value from L bucket to C0
      moveExtraFundsToBucket(bucket, BUCKET_C0, rbtcToRedeem, bucketLev);
    }

    uint256 btcCommission = mocInrate.calcCommissionValue(rbtcToRedeem);

    uint256 btcTotalWithoutCommission = rbtcToRedeem.sub(btcCommission);

    emit RiskProxRedeem(
      bucket,
      account,
      btcCommission,
      bproxAmount,
      btcTotalWithoutCommission,
      rbtcInterests,
      bucketLev,
      mocState.getBitcoinPrice()
    );

    return (btcTotalWithoutCommission.add(rbtcInterests), btcCommission);
  }

  /**
    @dev Burns user BProx and sends the equivalent amount of RBTC
    to the account without caring if transaction succeeds
    @param bucket Bucket where the BProxs are hold
    @param account user address to redeem bprox from
    @param bproxAmount Amount of BProx to redeem [using mocPrecision]
    @param bproxPrice Price of one BProx in RBTC [using reservePrecision]
    @return result of the RBTC sending transaction [using reservePrecision]
  **/
  function forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice
  ) public onlyWhitelisted(msg.sender) returns(bool) {
    // Do burning part of the redemption
    uint256 btcTotalAmount = burnBProxFor(bucket, account, bproxAmount, bproxPrice);

    // Send transaction can only fail for external code
    // if transaction fails, user will lost his RBTC and BProx
    return moc.sendToAddress(account, btcTotalAmount);
  }

  /**
    @dev Burns user BProx
    @param bucket Bucket where the BProxs are hold
    @param account user address to redeem bprox from
    @param bproxAmount Amount of BProx to redeem [using mocPrecision]
    @param bproxPrice Price of one BProx in RBTC [using reservePrecision]
    @return Bitcoin total value of the redemption [using reservePrecision]

  **/
  function burnBProxFor(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice
  ) public onlyWhitelisted(msg.sender) returns(uint256) {
    // Calculate total RBTC
    uint256 btcTotalAmount = mocConverter.bproToBtcWithPrice(bproxAmount, bproxPrice);
    bproxManager.removeBProx(bucket, account, bproxAmount, btcTotalAmount);

    return btcTotalAmount;
  }

  /**
    @dev Calculates the amount of RBTC that one bucket should move to another in
    BProx minting/redemption. This extra makes BProx more leveraging than BPro.
    @param bucketFrom Origin bucket from which the BTC are moving
    @param bucketTo Destination bucket to which the BTC are moving
    @param totalBtc Amount of BTC moving between buckets [using reservePrecision]
    @param lev lev of the L bucket [using mocPrecision]
  **/
  function moveExtraFundsToBucket(bytes32 bucketFrom, bytes32 bucketTo, uint256 totalBtc, uint256 lev
  ) internal {
    uint256 btcToMove = mocLibConfig.bucketTransferAmount(totalBtc, lev);
    uint256 docsToMove = mocConverter.btcToDoc(btcToMove);

    uint256 btcToMoveFinal = Math.min(btcToMove, bproxManager.getBucketNBTC(bucketFrom));
    uint256 docsToMoveFinal = Math.min(docsToMove, bproxManager.getBucketNDoc(bucketFrom));

    bproxManager.moveBtcAndDocs(bucketFrom, bucketTo, btcToMoveFinal, docsToMoveFinal);
  }

  /**
  * @dev Returns RBTCs for user in concept of interests refund
  * @param bucket Bucket where the BProxs are hold
  * @param rbtcToRedeem Total RBTC value of the redemption [using reservePrecision]
  * @return Interests [using reservePrecision]
  **/
  function recoverInterests(bytes32 bucket, uint256 rbtcToRedeem) internal returns(uint256) {
    uint256 rbtcInterests = mocInrate.calcFinalRedeemInterestValue(bucket, rbtcToRedeem);

    return bproxManager.recoverInrate(BUCKET_C0, rbtcInterests);
  }

  function doDocRedeem(address userAddress, uint256 docAmount, uint256 totalBtc) internal {
    docToken.burn(userAddress, docAmount);
    bproxManager.substractValuesFromBucket(BUCKET_C0, totalBtc, docAmount, 0);
  }

  function initializeContracts() internal {
    moc = MoC(connector.moc());
    docToken = DocToken(connector.docToken());
    bproToken = BProToken(connector.bproToken());
    bproxManager = MoCBProxManager(connector.bproxManager());
    mocState = MoCState(connector.mocState());
    mocConverter = MoCConverter(connector.mocConverter());
    mocInrate = MoCInrate(connector.mocInrate());
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}







contract PartialExecutionData_v019 {
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
        function() internal returns (uint256)  getStepCount;
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
contract PartialExecution_v019 is PartialExecutionData_v019 {
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
        function() internal returns (uint256)  _getStepCount,
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






contract MoCSettlement_v019 is
    MoCSettlementEvents,
    MoCBase,
    PartialExecution_v019,
    Governed
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
    }

    // Contracts
    MoCState internal mocState;
    MoCExchange internal mocExchange;
    DocToken internal docToken;
    MoCBProxManager internal bproxManager;

    /**
    @dev Block Number of the last successful execution
  **/
    uint256 internal lastProcessedBlock;
    /**
    @dev Min number of blocks settlement should be re evaluated on
  **/
    uint256 internal blockSpan;
    /**
    @dev Information for Settlement execution
  **/
    SettlementInfo internal settlementInfo;
    /**
    @dev Redeem queue
  **/
    RedeemRequest[] private redeemQueue;
    uint256 private redeemQueueLength;

    mapping(address => UserRedeemRequest) private redeemMapping;

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
  * @dev Runs settlement process in steps
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

    function initializeContracts() internal {
        docToken = DocToken(connector.docToken());
        bproxManager = MoCBProxManager(connector.bproxManager());
        mocState = MoCState(connector.mocState());
        mocExchange = MoCExchange(connector.mocExchange());
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

        settlementInfo.docRedeemCount = redeemQueueLength;
        settlementInfo.deleveragingCount = bproxManager.getActiveAddressesCount(
            BUCKET_X2
        );
        settlementInfo.finalCommissionAmount = 0;
        settlementInfo.partialCommissionAmount = 0;
        settlementInfo.startBlockNumber = block.number;

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

        clear();
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
    function fixTasksPointer() public {
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


        bytes32[] memory tasks = new bytes32[](2);
        tasks[0] = DELEVERAGING_TASK;
        tasks[1] = DOC_REDEMPTION_TASK;
        
        resetTaskGroupPointers(
            SETTLEMENT_TASK,
            tasks,
            initializeSettlement,
            finishSettlement,
            true
        );
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
