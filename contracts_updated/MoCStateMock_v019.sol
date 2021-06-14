pragma solidity ^0.5.8;

import "../MoCState.sol";

contract MoCStateMock_v019 is MoCState {
  uint256 internal _daysToSettlement;

  constructor() MoCState() public { }

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
    _daysToSettlement = 4;
    super.initialize(
      connectorAddress,
      _governor,
      _btcPriceProvider,
      _liq,
      _utpdu,
      _maxDiscRate,
      _dayBlockSpan,
      _ema,
      _smoothFactor,
      _emaBlockSpan,
      _maxMintBPro
    );
  }

  function setDaysToSettlement(uint256 daysToSettl) public {
    _daysToSettlement = daysToSettl;
  }

  function daysToSettlement() public view returns(uint256) {
    return _daysToSettlement;
  }
}