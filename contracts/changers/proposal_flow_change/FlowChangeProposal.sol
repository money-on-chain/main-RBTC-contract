pragma solidity ^0.5.8;
// Historical governance changer. Its contract interfaces target the deployment
// it originally changed and do not represent the current protocol interfaces.


import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

interface IIMoCInrate {
    function setCommissionsAddress(address newCommissionsAddress) external;
    function setBitProInterestAddress(address newBitProInterestAddress ) external;
}

interface IIMoCSettlement {
    function setBlockSpan(uint256 bSpan) external;
}

interface IIMoCState {
    function setDayBlockSpan(uint256 blockSpan) external;
    function setMoCPriceProvider(address mocProviderAddress) external;
}

/**
  @notice This changer sets new commission splitter (Flow) & Change MoC Price provider
 */
contract FlowChangeProposal is ChangeContract, Ownable {
  IIMoCInrate public mocInrate;
  IIMoCState public mocState;
  IIMoCSettlement public mocSettlement;

  address public commissionSplitterV2;
  address public commissionSplitterV3;
  address public mocProviderAddress;

  uint256 public blockSpan;
  uint256 public blockSpanBitProInterest;
  uint256 public blockSpanSettlement;
  uint256 public blockSpanEMA;

  constructor(
    IIMoCInrate _mocInrate,
    IIMoCState _mocState,
    IIMoCSettlement _mocSettlement,
    address payable _commissionSplitterV2,
    address payable _commissionSplitterV3,
    address payable _mocProviderAddress,
    uint256 _blockSpan,
    uint256 _blockSpanBitProInterest,
    uint256 _blockSpanSettlement,
    uint256 _blockSpanEMA
  ) public {
    require(_mocInrate != IIMoCInrate(0), "Wrong MoC MoCInrate contract address");
    require(_commissionSplitterV2 != address(0), "Wrong MoC Commission Address");
    require(_commissionSplitterV3 != address(0), "Wrong MoC BitPro Interest target Address");
    require(_mocProviderAddress != address(0), "Wrong MoC Price Provider target Address");

    mocInrate = _mocInrate;
    mocState = _mocState;
    mocSettlement = _mocSettlement;
    commissionSplitterV2 = _commissionSplitterV2;
    commissionSplitterV3 = _commissionSplitterV3;
    mocProviderAddress = _mocProviderAddress;

    blockSpan = _blockSpan;
    blockSpanBitProInterest = _blockSpanBitProInterest;
    blockSpanSettlement = _blockSpanSettlement;
    blockSpanEMA = _blockSpanEMA;
  }

  function execute() external {
    require(mocInrate != IIMoCInrate(0), "This changer is only for use once time");

    mocInrate.setCommissionsAddress(commissionSplitterV2);
    mocInrate.setBitProInterestAddress(commissionSplitterV3);
    mocState.setMoCPriceProvider(mocProviderAddress);

    mocState.setDayBlockSpan(blockSpan);
    mocSettlement.setBlockSpan(blockSpanSettlement);

    // Execute only one time
    mocInrate = IIMoCInrate(0);
  }



}