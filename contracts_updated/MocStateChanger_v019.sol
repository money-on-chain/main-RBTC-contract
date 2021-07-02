pragma solidity ^0.5.8;
import "../MoCState.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev This contract is used to update the configuration of MoCState v017
 * with MoC --- governance.
 */
contract MocStateChanger_v019 is ChangeContract, Ownable{
  MoCState public mocState;
  address public btcPriceProvider;
  uint256 public newPeg;
  uint256 public uptdu;
  uint256 public maxDiscRate;
  uint256 public dayBlockSpan;
  uint256 public liq;
  uint256 public smoothingFactor;
  uint256 public emaCalculationBlockSpan;
  uint256 public maxMintBPro;

  constructor(
    MoCState _mocState,
    address _btcPriceProvider,
    uint256 _newPeg,
    uint256 _uptdu,
    uint256 _maxDiscRate,
    uint256 _dayBlockSpan,
    uint256 _liq,
    uint256 _smoothingFactor,
    uint256 _emaCalculationBlockSpan,
    uint256 _maxMintBPro
  ) public {
    mocState = _mocState;
    newPeg = _newPeg;
    uptdu = _uptdu;
    maxDiscRate = _maxDiscRate;
    dayBlockSpan = _dayBlockSpan;
    liq = _liq;
    smoothingFactor = _smoothingFactor;
    emaCalculationBlockSpan = _emaCalculationBlockSpan;
    btcPriceProvider = _btcPriceProvider;
    maxMintBPro = _maxMintBPro;
  }

  function execute() external {
    mocState.setPeg(newPeg);
    mocState.setDayBlockSpan(dayBlockSpan);
    mocState.setLiq(liq);
    mocState.setUtpdu(uptdu);
    mocState.setMaxDiscountRate(maxDiscRate);
    mocState.setEmaCalculationBlockSpan(emaCalculationBlockSpan);
    mocState.setSmoothingFactor(smoothingFactor);
    mocState.setBtcPriceProvider(btcPriceProvider);
    mocState.setMaxMintBPro(maxMintBPro);
  }

  function setMaxMintBPro(uint256 _maxMintBPro) public onlyOwner() {
    maxMintBPro = _maxMintBPro;
  }

  function setBtcPriceProvider(address _btcPriceProvider) public onlyOwner() {
    btcPriceProvider = _btcPriceProvider;
  }

  function setSmoothingFactor(uint256 factor) public onlyOwner() {
    smoothingFactor = factor;
  }

  /**
  * @param blockSpan Defines how many blocks should pass between BMA calculations
  **/
  function setEmaCalculationBlockSpan(uint256 blockSpan) public onlyOwner() {
    emaCalculationBlockSpan = blockSpan;
  }

  function updatePegValue(uint256 _newPeg) public onlyOwner() {
    newPeg = _newPeg;
  }

  function updateUtpduValue(uint256 _uptdu) public onlyOwner() {
    uptdu = _uptdu;
  }

  function updatemaxDiscRateValue(uint256 _maxDiscRate) public onlyOwner() {
    maxDiscRate = _maxDiscRate;
  }

  function updateDayBlockSpanValue(uint256 _dayBlockSpan) public onlyOwner() {
    dayBlockSpan = _dayBlockSpan;
  }

  function updateLiqValue(uint256 _liq) public onlyOwner() {
    liq = _liq;
  }
}