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
pragma experimental ABIEncoderV2;


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


interface IMOCMoCInrate {
    function commissionsAddress() external view returns(address payable);
    function getBitProInterestAddress() external view returns(address payable);
    function getBitProRate() external view returns(uint256);
    function commissionRatesByTxType(uint8 txType) external view returns(uint256);

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

    function setCommissionsAddress(address payable newCommissionsAddress)  external;
    function setBitProInterestAddress(address payable newBitProInterestAddress) external;
    function setBitProRate(uint256 newBitProRate) external;
    function setCommissionRateByTxType(uint8 txType, uint256 value) external;
}

interface IROCMoCInrate {
    function commissionsAddress() external view returns(address payable);
    function getRiskProInterestAddress() external view returns(address payable);
    function getRiskProRate() external view returns(uint256);
    function commissionRatesByTxType(uint8 txType) external view returns(uint256);

    function MINT_RISKPRO_FEES_RESERVE() external view returns(uint8);
    function REDEEM_RISKPRO_FEES_RESERVE() external view returns(uint8);
    function MINT_STABLETOKEN_FEES_RESERVE() external view returns(uint8);
    function REDEEM_STABLETOKEN_FEES_RESERVE() external view returns(uint8);
    function MINT_RISKPROX_FEES_RESERVE() external view returns(uint8);
    function REDEEM_RISKPROX_FEES_RESERVE() external view returns(uint8);
    function MINT_RISKPRO_FEES_MOC() external view returns(uint8);
    function REDEEM_RISKPRO_FEES_MOC() external view returns(uint8);
    function MINT_STABLETOKEN_FEES_MOC() external view returns(uint8);
    function REDEEM_STABLETOKEN_FEES_MOC() external view returns(uint8);
    function MINT_RISKPROX_FEES_MOC() external view returns(uint8);
    function REDEEM_RISKPROX_FEES_MOC() external view returns(uint8);

    function setCommissionsAddress(address payable newCommissionsAddress)  external;
    function setRiskProInterestAddress(address payable newRiskProInterestAddress) external;
    function setRiskProRate(uint256 newRiskProRate) external;
    function setCommissionRateByTxType(uint8 txType, uint256 value) external;
}

/**
  @notice This changer sets Fee increase & New commission splitters in MoC & RoC Platforms operations
 */
contract FeeIncreaseProposalCombined is ChangeContract, Ownable {
  IMOCMoCInrate public MOC_mocInrate;
  address payable public MOC_commissionAddress;
  address payable public MOC_bitProInterestAddress;
  uint256 public MOC_bitProRate;
  CommissionRates[] public MOC_commissionRates;

  IROCMoCInrate public ROC_mocInrate;
  address payable public ROC_commissionAddress;
  address payable public ROC_riskProInterestAddress;
  uint256 public ROC_riskProRate;
  CommissionRates[] public ROC_commissionRates;

  uint8 public constant COMMISSION_RATES_ARRAY_MAX_LENGTH = 50;
  uint256 public constant PRECISION = 10**18;

  struct CommissionRates {
    uint8 txType;
    uint256 fee;
  }

  constructor(
    IMOCMoCInrate _MOC_mocInrate,
    address payable _MOC_commissionAddress,
    address payable _MOC_bitProInterestAddress,
    uint256 _MOC_bitProRate,
    CommissionRates[] memory _MOC_commissionRates,
    IROCMoCInrate _ROC_mocInrate,
    address payable _ROC_commissionAddress,
    address payable _ROC_riskProInterestAddress,
    uint256 _ROC_riskProRate,
    CommissionRates[] memory _ROC_commissionRates
  ) public {

    // MoC Platform
    require(_MOC_mocInrate != IMOCMoCInrate(0), "Wrong MoC MoCInrate contract address");
    require(_MOC_commissionAddress != address(0), "Wrong MoC Commission Address");
    require(_MOC_bitProInterestAddress != address(0), "Wrong MoC BitPro Interest target Address");
    require(
          _MOC_bitProRate <= PRECISION,
          "Wrong MoC bitProRate should not be higher than precision"
        );

    // RoC Platform
    require(_ROC_mocInrate != IROCMoCInrate(0), "Wrong RoC MoCInrate contract address");
    require(_ROC_commissionAddress != address(0), "Wrong RoC Commission Address");
    require(_ROC_riskProInterestAddress != address(0), "Wrong RoC RiskPro Interest target Address");
    require(
          _ROC_riskProRate <= PRECISION,
          "Wrong RoC riskProProRate should not be higher than precision"
        );

    // MoC Platform
    MOC_mocInrate = _MOC_mocInrate;
    MOC_commissionAddress = _MOC_commissionAddress;
    MOC_bitProInterestAddress = _MOC_bitProInterestAddress;
    MOC_bitProRate = _MOC_bitProRate;
    MOC_setCommissionRatesInternal(_MOC_commissionRates);

    // RoC Platform
    ROC_mocInrate = _ROC_mocInrate;
    ROC_commissionAddress = _ROC_commissionAddress;
    ROC_riskProInterestAddress = _ROC_riskProInterestAddress;
    ROC_riskProRate = _ROC_riskProRate;
    ROC_setCommissionRatesInternal(_ROC_commissionRates);
  }

  function execute() external {
    require(MOC_mocInrate != IMOCMoCInrate(0), "Wrong MoC MoCInrate contract address");
    require(ROC_mocInrate != IROCMoCInrate(0), "Wrong RoC MoCInrate contract address");

    // MoC Platform
    MOC_mocInrate.setCommissionsAddress(MOC_commissionAddress);
    MOC_mocInrate.setBitProInterestAddress(MOC_bitProInterestAddress);
    MOC_mocInrate.setBitProRate(MOC_bitProRate);
    MOC_initializeCommissionRates();

    // RoC Platform
    ROC_mocInrate.setCommissionsAddress(ROC_commissionAddress);
    ROC_mocInrate.setRiskProInterestAddress(ROC_riskProInterestAddress);
    ROC_mocInrate.setRiskProRate(ROC_riskProRate);
    ROC_initializeCommissionRates();

    // Execute only one time
    MOC_mocInrate = IMOCMoCInrate(0);
    ROC_mocInrate = IROCMoCInrate(0);
  }

  /**
    @dev returns the commission rate fees array length
  */
  function MOC_commissionRatesLength() public view returns (uint256) {
    return MOC_commissionRates.length;
  }

  /**
    @dev initializes the commission rate fees by transaction type to use in the MoCInrate contract
  */
  function MOC_initializeCommissionRates() internal {
    require(MOC_commissionRates.length > 0, "MoC commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(MOC_commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "MoC commissionRates length must be between 1 and 50");

    for (uint256 i = 0; i < MOC_commissionRates.length; i++) {
      MOC_mocInrate.setCommissionRateByTxType(MOC_commissionRates[i].txType, MOC_commissionRates[i].fee);
    }
  }

  function MOC_setCommissionRatesInternal(CommissionRates[] memory _commissionRates) internal {
    require(_commissionRates.length > 0, "MoC commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(_commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "MoC commissionRates length must be between 1 and 50");

    delete MOC_commissionRates;

    for (uint256 i = 0; i < _commissionRates.length; i++){
      MOC_commissionRates.push(_commissionRates[i]);
    }
  }

  /**
    @dev returns the commission rate fees array length
  */
  function ROC_commissionRatesLength() public view returns (uint256) {
    return ROC_commissionRates.length;
  }

  /**
    @dev initializes the commission rate fees by transaction type to use in the MoCInrate contract
  */
  function ROC_initializeCommissionRates() internal {
    require(ROC_commissionRates.length > 0, "RoC commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(ROC_commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "RoC commissionRates length must be between 1 and 50");

    for (uint256 i = 0; i < ROC_commissionRates.length; i++) {
      ROC_mocInrate.setCommissionRateByTxType(ROC_commissionRates[i].txType, ROC_commissionRates[i].fee);
    }
  }

  function ROC_setCommissionRatesInternal(CommissionRates[] memory _commissionRates) internal {
    require(_commissionRates.length > 0, "RoC commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(_commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "RoC commissionRates length must be between 1 and 50");

    delete ROC_commissionRates;

    for (uint256 i = 0; i < _commissionRates.length; i++){
      ROC_commissionRates.push(_commissionRates[i]);
    }
  }

}
