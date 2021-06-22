pragma solidity ^0.5.8;

interface IMoCSettlement {
    function getRedeemRequestAt(uint256 _index) external view returns (address payable, uint256);

    function redeemQueueSize() external view returns (uint256);

    function docAmountToRedeem(address _who) external view returns (uint256);

    function addRedeemRequest(uint256 amount, address payable redeemer) external;

    function alterRedeemRequestAmount(bool isAddition, uint256 delta, address redeemer) external;

    function isSettlementEnabled() external view returns (bool);

    function runSettlement(uint256 steps) external returns (uint256);

    function isSettlementReady() external view returns (bool);

    function nextSettlementBlock() external view returns (uint256);
}