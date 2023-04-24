pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IMOCMoCInrate.sol";
import "./interfaces/IROCMoCInrate.sol";

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