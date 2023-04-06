/*
Copyright MOC Investments Corp. 2020. All rights reserved.

You acknowledge and agree that MOC Investments Corp. (“MOC”) (or MOC’s licensors) own all legal right, title and interest in and to the work, software, application, source code, documentation and any other documents in this repository (collectively, the “Program”), including any intellectual property rights which subsist in the Program (whether those rights happen to be registered or not, and wherever in the world those rights may exist), whether in source code or any other form.

Subject to the limited license below, you may not (and you may not permit anyone else to) distribute, publish, copy, modify, merge, combine with another program, create derivative works of, reverse engineer, decompile or otherwise attempt to extract the source code of, the Program or any part thereof, except that you may contribute to this repository.

You are granted a non-exclusive, non-transferable, non-sublicensable license to distribute, publish, copy, modify, merge, combine with another program or create derivative works of the Program (such resulting program, collectively, the “Resulting Program”) solely for Non-Commercial Use as long as you:
 1. give prominent notice (“Notice”) with each copy of the Resulting Program that the Program is used in the Resulting Program and that the Program is the copyright of MOC Investments Corp.; and
 2. subject the Resulting Program and any distribution, publication, copy, modification, merger therewith, combination with another program or derivative works thereof to the same Notice requirement and Non-Commercial Use restriction set forth herein.

“Non-Commercial Use” means each use as described in clauses (1)-(3) below, as reasonably determined by MOC Investments Corp. in its sole discretion:
 1. personal use for research, personal study, private entertainment, hobby projects or amateur pursuits, in each case without any anticipated commercial application;
 2. use by any charitable organization, educational institution, public research organization, public safety or health organization, environmental protection organization or government institution; or
 3. the number of monthly active users of the Resulting Program across all versions thereof and platforms globally do not exceed 100 at any time.

You will not use any trade mark, service mark, trade name, logo of MOC Investments Corp. or any other company or organization in a way that is likely or intended to cause confusion about the owner or authorized user of such marks, names or logos.

If you have any questions, comments or interest in pursuing any other use cases, please reach out to us at moc.license@moneyonchain.com.

*/

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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard is Initializable {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    function initialize() public initializer {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

    uint256[50] private ______gap;
}


/**
  @dev Contract that split his balance between two addresses based on a
  proportion defined by Governance.
 */
contract CommissionSplitterV2 is Governed, ReentrancyGuard {

  event SplitExecuted(uint256 outputAmount_1, uint256 outputAmount_2, uint256 outputAmount_3, uint256 outputTokenGovernAmount_1, uint256 outputTokenGovernAmount_2);

  // Math
  using SafeMath for uint256;
  uint256 public constant PRECISION = 10**18;

  // Collateral asset splitter

  // Output_1 receiver address
  address payable public outputAddress_1;

  // Output_2 receiver address
  address payable public outputAddress_2;

  // Output_3 receiver address
  address payable public outputAddress_3;

  // Proportion of the balance to Output 1
  uint256 public outputProportion_1;

  // Proportion of the balance to Output 2
  uint256 public outputProportion_2;

  // Token Govern splitter

  // Output Token Govern #1 receiver address
  address payable public outputTokenGovernAddress_1;

  // Output Token Govern #2 receiver address
  address payable public outputTokenGovernAddress_2;

  // Proportion of the balance of Token Govern to Output 1
  uint256 public outputProportionTokenGovern_1;

  // Token Govern Address
  IERC20 public tokenGovern;

  /**
    @dev Initialize commission splitter contract
    @param _governor the address of the IGovernor contract
    @param _outputAddress_1 the address receiver #1
    @param _outputAddress_2 the address receiver #2
    @param _outputAddress_3 the address receiver #3
    @param _outputProportion_1 the proportion of commission will send to address #1, it should have PRECISION precision
    @param _outputProportion_2 the proportion of commission will send to address #2, it should have PRECISION precision
    @param _outputTokenGovernAddress_1 the address receiver #1
    @param _outputTokenGovernAddress_2 the address receiver #2
    @param _outputProportionTokenGovern_1 the proportion of commission will send to address #1, it should have PRECISION precision
    @param _tokenGovern the address of Token Govern contract
   */
  function initialize(
    IGovernor _governor,
    address payable _outputAddress_1,
    address payable _outputAddress_2,
    address payable _outputAddress_3,
    uint256 _outputProportion_1,
    uint256 _outputProportion_2,
    address payable _outputTokenGovernAddress_1,
    address payable _outputTokenGovernAddress_2,
    uint256 _outputProportionTokenGovern_1,
    IERC20 _tokenGovern
  ) public initializer {

    require(
      _outputProportion_1 <= PRECISION,
      "Output Proportion #1 should not be higher than precision"
    );

    require(
      _outputProportion_1.add(_outputProportion_2) <= PRECISION,
      "Output Proportion #1 and Output Proportion #2 should not be higher than precision"
    );

    require(
      _outputProportionTokenGovern_1 <= PRECISION,
      "Output Proportion Token Govern should not be higher than precision"
    );

    outputAddress_1 = _outputAddress_1;
    outputAddress_2 = _outputAddress_2;
    outputAddress_3 = _outputAddress_3;
    outputProportion_1 = _outputProportion_1;
    outputProportion_2 = _outputProportion_2;
    outputTokenGovernAddress_1 = _outputTokenGovernAddress_1;
    outputTokenGovernAddress_2 = _outputTokenGovernAddress_2;
    outputProportionTokenGovern_1 = _outputProportionTokenGovern_1;
    tokenGovern = _tokenGovern;
    Governed.initialize(_governor);

  }

  /**
  @dev Split current balance of the contract, and sends one part
  to destination address #1 and the other to destination address #2.
   */
  function split() public nonReentrant {

    // Split collateral Assets

    uint256 currentBalance = address(this).balance;
    uint256 outputAmount_1 = currentBalance.mul(outputProportion_1).div(PRECISION);
    uint256 outputAmount_2 = currentBalance.mul(outputProportion_2).div(PRECISION);
    uint256 outputAmount_3 = currentBalance.sub(outputAmount_1.add(outputAmount_2));

    _sendReserves(outputAmount_1, outputAddress_1);
    _sendReserves(outputAmount_2, outputAddress_2);
    _sendReserves(outputAmount_3, outputAddress_3);

    // Split Token Govern

    uint256 tokenGovernBalance = tokenGovern.balanceOf(address(this));
    uint256 outputTokenGovernAmount_1 = tokenGovernBalance.mul(outputProportionTokenGovern_1).div(PRECISION);
    uint256 outputTokenGovernAmount_2 = tokenGovernBalance.sub(outputTokenGovernAmount_1);

    if (tokenGovernBalance > 0) {
      tokenGovern.transfer(outputTokenGovernAddress_1, outputTokenGovernAmount_1);
      tokenGovern.transfer(outputTokenGovernAddress_2, outputTokenGovernAmount_2);
    }

    emit SplitExecuted(outputAmount_1, outputAmount_2, outputAmount_3, outputTokenGovernAmount_1, outputTokenGovernAmount_2);
  }

  // Governance Setters

  function setOutputAddress_1(address payable _outputAddress_1)
    public
    onlyAuthorizedChanger
  {
    outputAddress_1 = _outputAddress_1;
  }

  function setOutputAddress_2(address payable _outputAddress_2)
    public
    onlyAuthorizedChanger
  {
    outputAddress_2 = _outputAddress_2;
  }

  function setOutputAddress_3(address payable _outputAddress_3)
    public
    onlyAuthorizedChanger
  {
    outputAddress_3 = _outputAddress_3;
  }

  function setOutputProportion_1(uint256 _outputProportion_1)
    public
    onlyAuthorizedChanger
  {
    require(
          _outputProportion_1 <= PRECISION,
          "Output Proportion #1 should not be higher than precision"
        );
    outputProportion_1 = _outputProportion_1;
  }

  function setOutputProportion_2(uint256 _outputProportion_2)
    public
    onlyAuthorizedChanger
  {
    require(
      _outputProportion_2 <= PRECISION,
      "Output Proportion #2 should not be higher than precision"
    );
    outputProportion_2 = _outputProportion_2;
  }

  function setOutputTokenGovernAddress_1(address payable _outputTokenGovernAddress_1)
    public
    onlyAuthorizedChanger
  {
    outputTokenGovernAddress_1 = _outputTokenGovernAddress_1;
  }

  function setOutputTokenGovernAddress_2(address payable _outputTokenGovernAddress_2)
    public
    onlyAuthorizedChanger
  {
    outputTokenGovernAddress_2 = _outputTokenGovernAddress_2;
  }

  function setOutputProportionTokenGovern_1(uint256 _outputProportionTokenGovern_1)
    public
    onlyAuthorizedChanger
  {
    require(
          _outputProportionTokenGovern_1 <= PRECISION,
          "Output Proportion Token Govern should not be higher than precision"
        );
    outputProportionTokenGovern_1 = _outputProportionTokenGovern_1;
  }

  function setTokenGovern(address _tokenGovern) public onlyAuthorizedChanger {
    require(_tokenGovern != address(0), "Govern Token must not be 0x0");
    tokenGovern = IERC20(_tokenGovern);
  }

  /**
  @dev Sends reserves to address reserves
   */
  function _sendReserves(uint256 amount, address payable receiver) internal {
    // solium-disable-next-line security/no-call-value
    (bool success, ) = address(receiver).call.value(amount)("");
    require(success, "Failed while sending reserves");
  }

  function() external payable {}

}

