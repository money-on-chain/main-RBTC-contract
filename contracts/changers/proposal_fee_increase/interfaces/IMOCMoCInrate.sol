pragma solidity ^0.5.8;

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