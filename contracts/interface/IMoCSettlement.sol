pragma solidity ^0.5.8;

interface IMoCSettlement {
    function getRedeemRequestAt(uint256 _index) external pure returns (address payable, uint256);

    function redeemQueueSize() external pure returns (uint256);

    function docAmountToRedeem(address _who) external pure returns (uint256);

    function isSettlementEnabled() external view returns (bool);

    function runSettlement(uint256 steps) external returns (uint256);

    function nextSettlementBlock() external view returns (uint256);
}