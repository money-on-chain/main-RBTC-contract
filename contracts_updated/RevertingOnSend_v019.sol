pragma solidity ^0.5.8;

import "../../contracts/MoC.sol";

contract RevertingOnSend_v019 {
  MoC moc;
  bool acceptMoney = true;

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

  function mintBProx(bytes32 bucket, uint256 bproxAmountToMint) public payable {
    moc.mintBProx.value(msg.value)(bucket, bproxAmountToMint);
  }

  function mintDoc(uint256 docAmountToMint) public payable {
    moc.mintDoc.value(msg.value)(docAmountToMint);
  }

  function redeemDoCRequest(uint256 docAmount) public {
    moc.redeemDocRequest(docAmount);
  }
}