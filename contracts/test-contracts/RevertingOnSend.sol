pragma solidity ^0.5.8;

import "../../contracts/MoC.sol";

contract RevertingOnSend {
  MoC moc;
  bool acceptMoney = true;

  /**
    @dev Constructor
    @param mocAddress MoC contract address
  */
  constructor (address payable mocAddress) public {
    moc = MoC(mocAddress);
  }

  // Reverts on fallback with value
  function () external payable  {
    require(acceptMoney, "Should not revert");
  }

  function setAcceptingMoney(bool accepting) public {
    acceptMoney = accepting;
  }

  function mintBProx(bytes32 bucket, uint256 bproxAmountToMint, address payable vendorAccount) public payable {
    moc.mintBProxVendors.value(msg.value)(bucket, bproxAmountToMint, vendorAccount);
  }

  function mintDoc(uint256 docAmountToMint, address payable vendorAccount) public payable {
    moc.mintDocVendors.value(msg.value)(docAmountToMint, vendorAccount);
  }

  function redeemDoCRequest(uint256 docAmount) public {
    moc.redeemDocRequest(docAmount);
  }
}