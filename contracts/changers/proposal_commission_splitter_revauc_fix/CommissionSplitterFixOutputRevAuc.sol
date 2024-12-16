pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "../../auxiliar/CommissionSplitterV2.sol";
import "../../auxiliar/CommissionSplitterV3.sol";


/**
  @notice This changer sets the destination address for a part of the
  commissions of all Money on Chain
 */
contract CommissionSplitterFixOutputRevAuc is ChangeContract, Ownable {
  CommissionSplitterV2 public commissionSplitterV2;
  CommissionSplitterV3 public commissionSplitterV3;
  address payable public revAucBTC2MOC;
  address payable public revAucMOC2BTC;

  constructor(
              CommissionSplitterV2 commissionSplitterV2_,
              CommissionSplitterV3 commissionSplitterV3_,
              address payable revAucBTC2MOC_,
              address payable revAucMOC2BTC_) public {

    require(commissionSplitterV2_ != CommissionSplitterV2(0), "Wrong commission Splitter V2 contract address");
    require(commissionSplitterV3_ != CommissionSplitterV3(0), "Wrong commission Splitter V3 contract address");
    require(revAucBTC2MOC_ != address(0), "Wrong revAucBTC2MOC contract address");
    require(revAucMOC2BTC_ != address(0), "Wrong revAucMOC2BTC contract address");

    commissionSplitterV2 = commissionSplitterV2_;
    commissionSplitterV3 = commissionSplitterV3_;
    revAucBTC2MOC = revAucBTC2MOC_;
    revAucMOC2BTC = revAucMOC2BTC_;
    
  }

  function execute() external {
    require(revAucBTC2MOC != address(0), "This changer is only for use once time");

    commissionSplitterV2.setOutputAddress_2(revAucBTC2MOC);
    commissionSplitterV2.setOutputTokenGovernAddress_2(revAucMOC2BTC);
    commissionSplitterV3.setOutputAddress_2(revAucBTC2MOC);

    // Execute only one time
    revAucBTC2MOC = address(0);
  }
}