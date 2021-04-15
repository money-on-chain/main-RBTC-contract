pragma solidity 0.5.8;

import "./interface/IMoCState.sol";
import "./MoCLibConnection.sol";
import "./base/MoCBase.sol";

contract MoCConverter is MoCBase, MoCLibConnection {
  IMoCState internal mocState;

  function initialize(address connectorAddress) public initializer {
    initializePrecisions();
    initializeBase(connectorAddress);
    mocState = IMoCState(connector.mocState());
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

  /**
  * @dev Converts BTC to BPro
  * @param btcAmount BTC amount
  * @return BPro amount
  */
  function btcToBPro(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxBProWithBtc(btcAmount, mocState.bproTecPrice());
  }

  /**
  * @dev BTC equivalent for the amount of bpro given applying the spotDiscountRate
  * @param amount amount of BPro [using mocPrecision]
  * @return BTC amount
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

  function bproxToBtcHelper(uint256 bproxAmount, bytes32 bucket) public view returns(uint256) {
    return mocLibConfig.bproBtcValue(bproxAmount, mocState.bucketBProTecPriceHelper(bucket));
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

  function mocToBtc(uint256 mocAmount) public view returns(uint256) {
    return mocLibConfig.mocBtcValue(mocAmount, mocState.getBitcoinPrice(), mocState.getMoCPrice());
  }

  function btcToMoC(uint256 btcAmount) public view returns(uint256) {
    return mocLibConfig.maxMoCWithBtc(btcAmount, mocState.getBitcoinPrice(), mocState.getMoCPrice());
  }

  function mocToBtcWithPrice(uint256 mocAmount, uint256 btcPrice, uint256 mocPrice) public view returns(uint256) {
    return mocLibConfig.mocBtcValue(mocAmount, btcPrice, mocPrice);
  }

  function btcToMoCWithPrice(uint256 btcAmount, uint256 btcPrice, uint256 mocPrice) public view returns(uint256) {
    return mocLibConfig.maxMoCWithBtc(btcAmount, btcPrice, mocPrice);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}