pragma solidity 0.5.8;
import "moc-governance/contracts/Governance/ChangeContract.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../MoCBucketContainer.sol";
/**
 * @dev This contract is used to update the configuration of MocBucketContiner
 * with MoC --- governance.
 */
contract MoCBucketContainerChanger is ChangeContract, Ownable {
  MoCBucketContainer public mocContainer;
  bytes32 constant BUCKET_X2 = "X2";
  bytes32 constant BUCKET_C0 = "C0";
  uint256 public cobjC0;
  uint256 public cobjX2;

  constructor(MoCBucketContainer _mocContainer, uint256 _cobjC0, uint _cobjX2) public {
    mocContainer = _mocContainer;
    cobjC0 = _cobjC0;
    cobjX2 = _cobjX2;
  }

  //TODO: The X2 bucket must be updated after analyzing the impact that the model can have when configuring cobj
  function execute() external {
    if (cobjC0 > 0){
      mocContainer.setBucketCobj(BUCKET_C0, cobjC0);
    }
    if (cobjX2 > 0)
      mocContainer.setBucketCobj(BUCKET_X2, cobjX2);
  }

  function setCobjBucketC0(uint256 _cobj) public onlyOwner() {
    cobjC0 = _cobj;
  }

  function setCobjBucketX2(uint256 _cobj) public onlyOwner() {
    cobjX2 = _cobj;
  }
}
