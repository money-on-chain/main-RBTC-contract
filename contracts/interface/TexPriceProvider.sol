pragma solidity 0.5.8;

interface TexPriceProvider {
  /**
    @notice Getter for every value related to a pair
    @param _baseToken Address of the base token of the pair
    @param _secondaryToken Address of the secondary token of the pair
    @return lastClosingPrice - the last price from a successful matching
  */
  function getLastClosingPrice(address _baseToken, address _secondaryToken) external view returns (uint256 lastClosingPrice);
}