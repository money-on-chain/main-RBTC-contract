pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./base/MoCBase.sol";
import "./MoCBucketContainer_v018.sol";

contract MoCBProxManager_v018 is MoCBucketContainer_v018 {
  using SafeMath for uint256;
  uint256 constant MIN_ALLOWED_BALANCE = 0;
  function initialize(
    address connectorAddress,
    address _governor,
    uint256 _c0Cobj,
    uint256 _x2Cobj
  ) public initializer {
    initializeBase(connectorAddress);
    initializeValues(_governor);
    createBucket(BUCKET_C0, _c0Cobj, true);
    createBucket(BUCKET_X2, _x2Cobj, false);
  }

  /**
    @dev returns user balance
    @param bucket BProx corresponding bucket to get balance from
    @param userAddress user address to get balance from
    @return total balance for the userAddress
  */
  function bproxBalanceOf(bytes32 bucket, address userAddress) public view returns(uint256) {
    BProxBalance memory userBalance = mocBuckets[bucket].bproxBalances[userAddress];
    if (!hasValidBalance(bucket, userAddress, userBalance.index)) return 0;
    return userBalance.value;
  }

  /**
    @dev verifies that this user has assigned balance for the given bucket
    @param bucket corresponding Leveraged bucket to get balance from
    @param userAddress user address to verify balance for
    @param index index, starting from 1, where the address of the user is being kept
    @return true if the user has assigned balance
  */
  function hasValidBalance(bytes32 bucket, address userAddress, uint index) public view returns(bool) {
    return (index != 0) &&
      (index <= getActiveAddressesCount(bucket)) &&
      (mocBuckets[bucket].activeBalances[index - 1] == userAddress);
  }

  /**
    @dev  Assigns the amount of BProx
    @param bucket bucket from which the BProx will be removed
    @param account user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function assignBProx(bytes32 bucket, address payable account, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, account);

    setBProxBalanceOf(bucket, account, currentBalance.add(bproxAmount));
    addValuesToBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev  Removes the amount of BProx and substract BTC cost from bucket
    @param bucket bucket from which the BProx will be removed
    @param userAddress user address to redeem for
    @param bproxAmount bprox amount to redeem [using mocPresicion]
    @param totalCost btc value of bproxAmount [using reservePrecision]
  */
  function removeBProx(bytes32 bucket, address payable userAddress, uint256 bproxAmount, uint256 totalCost)
  public onlyWhitelisted(msg.sender) {
    uint256 currentBalance = bproxBalanceOf(bucket, userAddress);

    setBProxBalanceOf(bucket, userAddress, currentBalance.sub(bproxAmount));
    substractValuesFromBucket(bucket, totalCost, 0, bproxAmount);
  }

  /**
    @dev Sets the amount of BProx
    @param bucket bucket from which the BProx will be setted
    @param userAddress user address to redeem for
    @param value bprox amount to redeem [using mocPresicion]
  */
  function setBProxBalanceOf(bytes32 bucket, address payable userAddress, uint256 value) public onlyWhitelisted(msg.sender) {
    mocBuckets[bucket].bproxBalances[userAddress].value = value;
    uint256 index = mocBuckets[bucket].bproxBalances[userAddress].index;
    if (!hasValidBalance(bucket, userAddress, index))
      index = 0;

    bool hasBalance = value > MIN_ALLOWED_BALANCE;
    // The address is not in the array
    if (index == 0) {
      if (hasBalance) {
        if (mocBuckets[bucket].activeBalances.length == mocBuckets[bucket].activeBalancesLength) {
          mocBuckets[bucket].activeBalances.length += 1;
        }
        uint256 currentIndex = mocBuckets[bucket].activeBalancesLength++;
        mocBuckets[bucket].activeBalances[currentIndex] = userAddress;
        mocBuckets[bucket].bproxBalances[userAddress].index = mocBuckets[bucket].activeBalancesLength;
      }
    } else {
      if (!hasBalance) {
        // We need to delete this address from the tracker
        uint256 lastActiveIndex = mocBuckets[bucket].activeBalancesLength;
        address payable keyToMove = mocBuckets[bucket].activeBalances[lastActiveIndex - 1];
        mocBuckets[bucket].activeBalances[index - 1] = keyToMove;
        // Alternative index and array decreases lenght to prevent gas limit
        mocBuckets[bucket].activeBalancesLength--;
        // Update moved key index
        mocBuckets[bucket].bproxBalances[keyToMove].index = index;
        // Disable empty account index (0 == NULL)
        mocBuckets[bucket].bproxBalances[userAddress].index = 0;
      }
    }
  }

  /**
   * @dev intializes values of the contract
   */
  function initializeValues(address _governor) internal {
    governor = IGovernor(_governor);
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
