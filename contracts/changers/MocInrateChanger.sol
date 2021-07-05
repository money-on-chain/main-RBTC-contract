pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

import "../MoCInrate.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MocInrate v017
 * with MoC --- governance.
 */
contract MocInrateChanger is ChangeContract, Ownable {
  MoCInrate private mocInrate;
  uint256 public bitProInterestBlockSpan;
  uint256 public btxcTmin;
  uint256 public btxcTmax;
  uint256 public btxcPower;
  uint256 public newBitProRate;
  /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
  /** DEPRECATED **/
  // solium-disable-next-line mixedcase
  uint256 public DEPRECATED_newCommissionRate;
  address payable public newBitProInterestAddress;
  address payable public newCommissionsAddress;
  uint256 public docTmin;
  uint256 public docTmax;
  uint256 public docPower;

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/

  CommissionRates[] public commissionRates;
  uint8 public constant COMMISSION_RATES_ARRAY_MAX_LENGTH = 50;

  struct CommissionRates {
    uint8 txType;
    uint256 fee;
  }

  /** END UPDATE V0112: 24/09/2020 **/

  constructor(
    MoCInrate _mocInrate,
    uint256 _bProIntBlockSpan,
    uint256 _btxcTmin,
    uint256 _btxcTmax,
    uint256 _btxcPower,
    uint256 _newBProRate,
    //uint256 _newComRate,
    uint256 _docTmin,
    uint256 _docTmax,
    uint256 _docPower,
    CommissionRates[] memory _commissionRates
  ) public {
    mocInrate = _mocInrate;
    bitProInterestBlockSpan = _bProIntBlockSpan;
    btxcTmin = _btxcTmin;
    btxcTmax = _btxcTmax;
    btxcPower = _btxcPower;
    newBitProRate = _newBProRate;
    //newCommissionRate = _newComRate;
    docTmin = _docTmin;
    docTmax = _docTmax;
    docPower = _docPower;

    setCommissionRatesInternal(_commissionRates);
  }

  function execute() external {
    mocInrate.setBitProInterestBlockSpan(bitProInterestBlockSpan);
    mocInrate.setBtcxTmin(btxcTmin);
    mocInrate.setBtcxTmax(btxcTmax);
    mocInrate.setBtcxPower(btxcPower);

    mocInrate.setBitProRate(newBitProRate);
    if (address(0) != newCommissionsAddress){
      mocInrate.setCommissionsAddress(newCommissionsAddress);
    }
    if (address(0) != newBitProInterestAddress){
      mocInrate.setBitProInterestAddress(newBitProInterestAddress);
    }

    //mocInrate.setCommissionRate(newCommissionRate);

    mocInrate.setDoCTmin(docTmin);
    mocInrate.setDoCTmax(docTmax);
    mocInrate.setDoCPower(docPower);

    /** UPDATE V0112: 24/09/2020 - Upgrade to support multiple commission rates **/
    initializeCommissionRates();
  }

  function setBitProInterestBlockSpan(uint256 _bitProInterestBlockSpan) public onlyOwner(){
    bitProInterestBlockSpan = _bitProInterestBlockSpan;
  }

  function setBtcxTmin(uint256 _btxcTmin) public onlyOwner(){
    btxcTmin = _btxcTmin;
  }

  function setBtcxTmax(uint256 _btxcTmax) public onlyOwner(){
    btxcTmax = _btxcTmax;
  }

  function setBtcxPower(uint256 _btxcPower) public onlyOwner(){
    btxcPower = _btxcPower;
  }

  function setBitProInterestAddress(address payable _newBitProInterestAddress) public onlyOwner(){
    newBitProInterestAddress = _newBitProInterestAddress;
  }

  function setBitProRate(uint256 _newBitProRate) public onlyOwner(){
    newBitProRate = _newBitProRate;
  }

  function setCommissionsAddress(address payable _newCommissionsAddress) public onlyOwner(){
    newCommissionsAddress = _newCommissionsAddress;
  }

  // function setCommissionRate(uint256 _newCommissionRate) public onlyOwner(){
  //   newCommissionRate = _newCommissionRate;
  // }

  function setDoCTmin(uint256 _docTmin) public onlyOwner(){
    docTmin = _docTmin;
  }

  function setDoCTmax(uint256 _docTmax) public onlyOwner(){
    docTmax = _docTmax;
  }

  function setDoCPower(uint256 _docPower) public onlyOwner(){
    docPower = _docPower;
  }

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Public functions **/

  /**
    @dev returns the commission rate fees array length
  */
  function commissionRatesLength() public view returns (uint256) {
    return commissionRates.length;
  }

  function setCommissionRates(CommissionRates[] memory _commissionRates) public onlyOwner(){
    setCommissionRatesInternal(_commissionRates);
  }

  /** END UPDATE V0112: 24/09/2020 **/

  /************************************/
  /***** UPGRADE v0110      ***********/
  /************************************/

  /** START UPDATE V0112: 24/09/2020  **/
  /** Upgrade to support multiple commission rates **/
  /** Internal functions **/

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

  /** END UPDATE V0112: 24/09/2020 **/
}