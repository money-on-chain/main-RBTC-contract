pragma solidity ^0.5.8;

interface IMoC {
    function() external payable;

    function sendToAddress(address payable receiver, uint256 btcAmount) external returns(bool);
}