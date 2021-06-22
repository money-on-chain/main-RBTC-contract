pragma solidity ^0.5.8;

interface IMoCState {

     /******STATE MACHINE*********/
    enum States {
        // State 0
        Liquidated,
        // State 1
        BProDiscount,
        // State 2
        BelowCobj,
        // State 3
        AboveCobj
    }


    function addToRbtcInSystem(uint256 btcAmount) external;

    function subtractRbtcFromSystem(uint256 btcAmount) external;

    function coverage(bytes32 bucket) external view returns(uint256);

    function getRbtcRemainder() external view returns(uint256);

    function liq() external view returns(uint256);

    function state() external view returns(States);

    function peg() external view returns(uint256);

    function dayBlockSpan() external view returns(uint256);

    function getBitcoinPrice() external view returns(uint256);

    function getMoCPrice() external view returns(uint256);

    function getProtected() external view returns(uint256);

    function globalCoverage() external view returns(uint256);

    function getMoCVendors() external view returns(address);

    function getMoCToken() external view returns(address);

    function nextState() external;

    function maxBProWithDiscount() external view returns(uint256);

    function absoluteMaxBPro() external view returns(uint256);

    function absoluteMaxDoc() external view returns(uint256);

    function freeDoc() external view returns(uint256);

    function bproTecPrice() external view returns(uint256);

    function bproSpotDiscountRate() external view returns(uint256);

    function bproDiscountPrice() external view returns(uint256);

    function bucketBProTecPrice(bytes32 bucket) external view returns(uint256);

    function currentAbundanceRatio() external view returns(uint256);

    function abundanceRatio(uint256 doc0) external view returns(uint256);

    function daysToSettlement() external view returns(uint256);

    function leverage(bytes32 bucket) external view returns(uint256);

    function getBucketNBTC(bytes32 bucket) external view returns(uint256);

    function getLiquidationPrice() external view returns(uint256);

    function maxBProxBtcValue(bytes32 bucket) external view returns(uint256);

    function bucketBProTecPriceHelper(bytes32 bucket) external view returns(uint256);

    // Ex Mocconverter
    function docsToBtc(uint256 docAmount) external view returns(uint256);
    function btcToDoc(uint256 btcAmount) external view returns(uint256);
    function bproxToBtc(uint256 bproxAmount, bytes32 bucket) external view returns(uint256);
    function btcToBProx(uint256 btcAmount, bytes32 bucket) external view returns(uint256);


}