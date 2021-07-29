pragma solidity ^0.5.8;

import "moc-governance/contracts/Governance/Governed.sol";
import "moc-governance/contracts/Governance/IGovernor.sol";
import "../interface/IMoC.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-eth/contracts/utils/ReentrancyGuard.sol";

/**
  @dev Contract that split his balance between two addresses based on a
  proportion defined by Governance. One of those addresses should
  be a Money on Chain main contract.
 */
contract CommissionSplitter is Governed, ReentrancyGuard {
  event SplitExecuted(uint256 commissionAmount, uint256 mocAmount, uint256 mocTokenCommissionAmount);
  // Math
  using SafeMath for uint256;
  uint256 public constant PRECISION = 10**18;

  // Final receiver address
  address payable public commissionsAddress;
  // Proportion of the balance to send to moc
  uint256 public mocProportion;

  // Contracts
  IMoC public moc;

  IERC20 public mocToken;
  address public mocTokenCommissionsAddress;

  /**
    @dev Initialize commission splitter contract
    @param _mocAddress the address of MoC contract
    @param _commissionsAddress the address in which the remaining commissions (profit ones) are sent
    @param _mocProportion the proportion of commission that moc will keep, it should have PRECISION precision
    @param _governor the address of the IGovernor contract
    @param _mocToken the address of MoC Token contract
    @param _mocTokenCommissionsAddress the address in which the Moc Token commissions are sent
   */
  function initialize(
    IMoC _mocAddress,
    address payable _commissionsAddress,
    uint256 _mocProportion,
    IGovernor _governor,
    IERC20 _mocToken,
    address _mocTokenCommissionsAddress
  ) public initializer {
    _setMocProportion(_mocProportion);
    moc = _mocAddress;
    commissionsAddress = _commissionsAddress;
    mocToken = _mocToken;
    mocTokenCommissionsAddress = _mocTokenCommissionsAddress;

    Governed.initialize(_governor);
  }

  /**
  @dev Split current balance of the contract, and sends one part
  to destination address and the other to MoC Reserves.
   */
  function split() public nonReentrant {
    uint256 currentBalance = address(this).balance;
    uint256 mocAmount = currentBalance.mul(mocProportion).div(PRECISION);
    uint256 commissionAmount = currentBalance.sub(mocAmount);

    _sendReservesToMoC(mocAmount);
    _sendReserves(commissionAmount, commissionsAddress);

    uint256 mocTokenAmount = mocToken.balanceOf(address(this));
    if (mocTokenAmount > 0) {
      mocToken.transfer(mocTokenCommissionsAddress, mocTokenAmount);
    }

    emit SplitExecuted(commissionAmount, mocAmount, mocTokenAmount);
  }

  // Governance Setters
  function setCommissionAddress(address payable _commissionsAddress)
    public
    onlyAuthorizedChanger
  {
    commissionsAddress = _commissionsAddress;
  }

  function setMocProportion(uint256 _mocProportion)
    public
    onlyAuthorizedChanger
  {
    _setMocProportion(_mocProportion);
  }

  function setMocToken(address _mocToken) public onlyAuthorizedChanger {
    require(_mocToken != address(0), "MocToken must not be 0x0");
    mocToken = IERC20(_mocToken);
  }

  function setMocTokenCommissionAddress(address _mocTokenCommissionsAddress) public onlyAuthorizedChanger {
    require(_mocTokenCommissionsAddress != address(0), "MocTokenCommissionAddress must not be 0x0");
    mocTokenCommissionsAddress = _mocTokenCommissionsAddress;
  }

  function _setMocProportion(uint256 _mocProportion) internal {
    require(
      _mocProportion <= PRECISION,
      "Proportion should not be higher than precision"
    );
    mocProportion = _mocProportion;
  }

  /**
  @dev Sends tokens to Money on chain reserves
   */
  function _sendReservesToMoC(uint256 amount) internal {
    _sendReserves(amount, address(moc));
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
