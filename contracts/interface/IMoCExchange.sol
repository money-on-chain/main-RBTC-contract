pragma solidity ^0.5.8;

interface IMoCExchange {
    function getMoCTokenBalance(address owner, address spender) external view
    returns (uint256 mocBalance, uint256 mocAllowance);

    function mintBPro(address account, uint256 btcAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBPro(address account, uint256 bproAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function mintDoc(address account, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemBProx(address payable account, bytes32 bucket, uint256 bproxAmount, address vendorAccount)
    external returns (uint256, uint256, uint256, uint256, uint256);

    function mintBProx(address payable account, bytes32 bucket, uint256 btcToMint, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemFreeDoc(address account, uint256 docAmount, address vendorAccount) external
    returns (uint256, uint256, uint256, uint256, uint256);

    function redeemAllDoc(address origin, address payable destination) external
    returns (uint256);

    function forceRedeemBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 bproxPrice)
    external returns (bool);

    function redeemDocWithPrice(address payable userAddress, uint256 amount, uint256 btcPrice) external
    returns (bool, uint256);
}