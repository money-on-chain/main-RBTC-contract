pragma solidity ^0.5.8;

interface IMoCInrate {
    // Transaction types
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

    function dailyInratePayment() external returns(uint256);

    function payBitProHoldersInterestPayment() external returns(uint256);

    function calculateBitProHoldersInterest() external view returns(uint256, uint256);

    function getBitProInterestAddress() external view returns(address payable);

    function getBitProRate() external view returns(uint256);

    function getBitProInterestBlockSpan() external view returns(uint256);

    function isDailyEnabled() external view returns(bool);

    function isBitProInterestEnabled() external view returns(bool);

    function commissionsAddress() external view returns(address payable);

    function calcCommissionValue(uint256 rbtcAmount, uint8 txType) external view returns(uint256);

    function calculateVendorMarkup(address vendorAccount, uint256 amount) external view returns (uint256 markup);

    function calcDocRedInterestValues(uint256 docAmount, uint256 rbtcAmount) external view returns(uint256);

    function calcMintInterestValues(bytes32 bucket, uint256 rbtcAmount) external view returns(uint256);

    function calcFinalRedeemInterestValue(bytes32 bucket, uint256 rbtcToRedeem) external view returns(uint256);

    function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) external;
}