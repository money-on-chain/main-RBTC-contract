pragma solidity ^0.5.8;
import "../auxiliar/CommissionSplitter.sol";
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
/**
 * @dev This contract is used to update the configuration of MocInrate
 * with MoC --- governance.
 */

contract CommissionSplitterChanger is ChangeContract, Ownable {
  CommissionSplitter public commissionSplitter;
  address payable public commissionsAddress;
  uint256 public mocProportion;
  address public mocToken;
  address public mocTokenCommissionsAddress;

  constructor(
    CommissionSplitter _commissionSplitter,
    address payable _commissionsAddress,
    uint256 _mocProportion,
    address _mocToken,
    address _mocTokenCommissionsAddress
  ) public {
    commissionSplitter = _commissionSplitter;
    commissionsAddress = _commissionsAddress;
    mocProportion = _mocProportion;
    mocToken = _mocToken;
    mocTokenCommissionsAddress = _mocTokenCommissionsAddress;
  }

  function execute() external {
    commissionSplitter.setCommissionAddress(commissionsAddress);
    commissionSplitter.setMocProportion(mocProportion);
    commissionSplitter.setMocToken(mocToken);
    commissionSplitter.setMocTokenCommissionAddress(mocTokenCommissionsAddress);
  }

  function setCommissionAddress(address payable _commissionsAddress) public onlyOwner() {
    commissionsAddress = _commissionsAddress;
  }

  function setMocProportion(uint256 _mocProportion) public onlyOwner() {
    mocProportion = _mocProportion;
  }

  function setMocTokenCommissionAddress(address _mocTokenCommissionsAddress) public onlyOwner() {
    mocTokenCommissionsAddress = _mocTokenCommissionsAddress;
  }


}
