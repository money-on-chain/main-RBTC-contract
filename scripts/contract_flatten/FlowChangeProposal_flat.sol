/*
Copyright MOC Investments Corp. 2020. All rights reserved.

You acknowledge and agree that MOC Investments Corp. (“MOC”) (or MOC’s licensors) own all legal right, title and interest in and to the work, software, application, source code, documentation and any other documents in this repository (collectively, the “Program”), including any intellectual property rights which subsist in the Program (whether those rights happen to be registered or not, and wherever in the world those rights may exist), whether in source code or any other form.

Subject to the limited license below, you may not (and you may not permit anyone else to) distribute, publish, copy, modify, merge, combine with another program, create derivative works of, reverse engineer, decompile or otherwise attempt to extract the source code of, the Program or any part thereof, except that you may contribute to this repository.

You are granted a non-exclusive, non-transferable, non-sublicensable license to distribute, publish, copy, modify, merge, combine with another program or create derivative works of the Program (such resulting program, collectively, the “Resulting Program”) solely for Non-Commercial Use as long as you:
 1. give prominent notice (“Notice”) with each copy of the Resulting Program that the Program is used in the Resulting Program and that the Program is the copyright of MOC Investments Corp.; and
 2. subject the Resulting Program and any distribution, publication, copy, modification, merger therewith, combination with another program or derivative works thereof to the same Notice requirement and Non-Commercial Use restriction set forth herein.

“Non-Commercial Use” means each use as described in clauses (1)-(3) below, as reasonably determined by MOC Investments Corp. in its sole discretion:
 1. personal use for research, personal study, private entertainment, hobby projects or amateur pursuits, in each case without any anticipated commercial application;
 2. use by any charitable organization, educational institution, public research organization, public safety or health organization, environmental protection organization or government institution; or
 3. the number of monthly active users of the Resulting Program across all versions thereof and platforms globally do not exceed 100 at any time.

You will not use any trade mark, service mark, trade name, logo of MOC Investments Corp. or any other company or organization in a way that is likely or intended to cause confusion about the owner or authorized user of such marks, names or logos.

If you have any questions, comments or interest in pursuing any other use cases, please reach out to us at moc.license@moneyonchain.com.

*/

pragma solidity ^0.5.8;


/**
  @title ChangeContract
  @notice This interface is the one used by the governance system.
  @dev If you plan to do some changes to a system governed by this project you should write a contract
  that does those changes, like a recipe. This contract MUST not have ANY kind of public or external function
  that modifies the state of this ChangeContract, otherwise you could run into front-running issues when the governance
  system is fully in place.
 */
interface ChangeContract {

  /**
    @notice Override this function with a recipe of the changes to be done when this ChangeContract
    is executed
   */
  function execute() external;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IIMoCInrate {
    function setBitProInterestBlockSpan(uint256 newBitProBlockSpan) external;
    function setCommissionsAddress(address newCommissionsAddress) external;
    function setBitProInterestAddress(address newBitProInterestAddress ) external;
}

interface IIMoCSettlement {
    function setBlockSpan(uint256 bSpan) external;
}

interface IIMoCState {
    function setDayBlockSpan(uint256 blockSpan) external;
    function setEmaCalculationBlockSpan(uint256 blockSpan) external;
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
    mocInrate.setBitProInterestBlockSpan(blockSpanBitProInterest);
    mocSettlement.setBlockSpan(blockSpanSettlement);
    mocState.setEmaCalculationBlockSpan(blockSpanEMA);

    // Execute only one time
    mocInrate = IIMoCInrate(0);
  }



}
