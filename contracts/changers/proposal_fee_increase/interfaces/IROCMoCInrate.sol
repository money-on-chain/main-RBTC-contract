pragma solidity ^0.5.8;

interface IROCMoCInrate {
    function commissionsAddress() external view returns(address payable);
    function getRiskProInterestAddress() external view returns(address payable);
    function getRiskProRate() external view returns(uint256);
    function commissionRatesByTxType(uint8 txType) external view returns(uint256);

    function MINT_RISKPRO_FEES_RESERVE() external view returns(uint8);
    function REDEEM_RISKPRO_FEES_RESERVE() external view returns(uint8);
    function MINT_STABLETOKEN_FEES_RESERVE() external view returns(uint8);
    function REDEEM_STABLETOKEN_FEES_RESERVE() external view returns(uint8);
    function MINT_RISKPROX_FEES_RESERVE() external view returns(uint8);
    function REDEEM_RISKPROX_FEES_RESERVE() external view returns(uint8);
    function MINT_RISKPRO_FEES_MOC() external view returns(uint8);
    function REDEEM_RISKPRO_FEES_MOC() external view returns(uint8);
    function MINT_STABLETOKEN_FEES_MOC() external view returns(uint8);
    function REDEEM_STABLETOKEN_FEES_MOC() external view returns(uint8);
    function MINT_RISKPROX_FEES_MOC() external view returns(uint8);
    function REDEEM_RISKPROX_FEES_MOC() external view returns(uint8);

    function setCommissionsAddress(address payable newCommissionsAddress)  external;
    function setRiskProInterestAddress(address payable newRiskProInterestAddress) external;
    function setRiskProRate(uint256 newRiskProRate) external;
    function setCommissionRateByTxType(uint8 txType, uint256 value) external;
}