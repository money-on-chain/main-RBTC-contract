pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IMOCMoCInrate.sol";

/**
  @notice This changer sets Fee increase & New commission splitters in MoC Platform operations
 */
contract FeeIncreaseProposal is ChangeContract, Ownable {
  IMOCMoCInrate public mocInrate;
  address payable public commissionAddress;
  address payable public bitProInterestAddress;
  uint256 public bitProRate;
  CommissionRates[] public commissionRates;
  uint8 public constant COMMISSION_RATES_ARRAY_MAX_LENGTH = 50;
  uint256 public constant PRECISION = 10**18;

  struct CommissionRates {
    uint8 txType;
    uint256 fee;
  }

  constructor(
    IMOCMoCInrate _mocInrate,
    address payable _commissionAddress,
    address payable _bitProInterestAddress,
    uint256 _bitProRate,
    CommissionRates[] memory _commissionRates
  ) public {
    require(_mocInrate != IMOCMoCInrate(0), "Wrong MoCInrate contract address");
    require(_commissionAddress != address(0), "Wrong Commission Address");
    require(_bitProInterestAddress != address(0), "Wrong BitPro Interest target Address");
    require(
          _bitProRate <= PRECISION,
          "Wrong bitProRate should not be higher than precision"
        );

    mocInrate = _mocInrate;
    commissionAddress = _commissionAddress;
    bitProInterestAddress = _bitProInterestAddress;
    bitProRate = _bitProRate;
    setCommissionRatesInternal(_commissionRates);
  }

  function execute() external {
    require(mocInrate != IMOCMoCInrate(0), "Wrong MoCInrate contract address");

    mocInrate.setCommissionsAddress(commissionAddress);
    mocInrate.setBitProInterestAddress(bitProInterestAddress);
    mocInrate.setBitProRate(bitProRate);
    initializeCommissionRates();

    // Execute only one time
    mocInrate = IMOCMoCInrate(0);
  }

  /**
    @dev returns the commission rate fees array length
  */
  function commissionRatesLength() public view returns (uint256) {
    return commissionRates.length;
  }

  /**
    @dev initializes the commission rate fees by transaction type to use in the MoCInrate contract
  */
  function initializeCommissionRates() internal {
    require(commissionRates.length > 0, "commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "commissionRates length must be between 1 and 50");

    for (uint256 i = 0; i < commissionRates.length; i++) {
      mocInrate.setCommissionRateByTxType(commissionRates[i].txType, commissionRates[i].fee);
    }
  }

  function setCommissionRatesInternal(CommissionRates[] memory _commissionRates) internal {
    require(_commissionRates.length > 0, "commissionRates cannot be empty");
    // Change the error message according to the value of the COMMISSION_RATES_ARRAY_MAX_LENGTH constant
    require(_commissionRates.length <= COMMISSION_RATES_ARRAY_MAX_LENGTH, "commissionRates length must be between 1 and 50");

    delete commissionRates;

    for (uint256 i = 0; i < _commissionRates.length; i++){
      commissionRates.push(_commissionRates[i]);
    }
  }

}