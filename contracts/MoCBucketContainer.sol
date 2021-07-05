pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "./base/MoCBase.sol";
import "moc-governance/contracts/Governance/Governed.sol";

contract MoCBucketContainer is MoCBase, Governed {
  using SafeMath for uint256;
  using Math for uint256;

  struct BProxBalance {
    uint256 value;
    uint index; // Index start in 1, zero is reserved for NULL
  }

  struct MoCBucket {
    bytes32 name;
    bool isBase;
    uint256 nDoc;
    uint256 nBPro;
    uint256 nBTC;
    uint256 cobj;
    // Should only be used in L buckets
    mapping(address => BProxBalance) bproxBalances;
    address payable[] activeBalances;
    uint256 activeBalancesLength;
    // Should only be used in Base buckets (C0)
    uint256 inrateBag;
    bool available;
  }

  event BucketMovement(
    bytes32 from,
    bytes32 to,
    uint256 reserves,
    uint256 stableTokens
  );

  event BucketCreation(
    bytes32 name,
    uint256 cobj
  );

  event BucketStateUpdate(
    bytes32 name,
    uint256 nReserve,
    uint256 nStable,
    uint256 nRiskProx,
    uint256 inrateBag
  );

  mapping(bytes32 => MoCBucket) internal mocBuckets;

   /**
   GETTERS
   */
  function getBucketNBTC(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBTC;
  }

  function getBucketNBPro(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nBPro;
  }

  function getBucketNDoc(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].nDoc;
  }

  function getBucketCobj(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].cobj;
  }

  function getInrateBag(bytes32 bucket) public view returns(uint256) {
    return mocBuckets[bucket].inrateBag;
  }

  /**
   * @dev Sets the objective coverage (cobj) on an specficied bucket.
   * @param  _bucket - name of the bucket
   * @param  _cobj - new value of cobj
   */
  function setBucketCobj(bytes32 _bucket, uint256 _cobj) public onlyAuthorizedChanger(){
    //TODO: It is necessary to analyze the impact in the model it has when changing X2. This
    mocBuckets[_bucket].cobj = _cobj;
  }

  /**
    @dev returns true if the bucket is a base bucket
    @param bucket Name of the bucket
  */
  function isBucketBase(bytes32 bucket) public view returns(bool){
    return mocBuckets[bucket].isBase;
  }

  /**
    @dev returns true if the bucket have docs in it
    @param bucket Name of the bucket
  */
  function isBucketEmpty(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].nDoc == 0;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddresses(bytes32 bucket) public view returns(address payable[] memory) {
    return mocBuckets[bucket].activeBalances;
  }

  /**
    @dev Returns all the address that currently have bprox position for this bucket
    @param bucket bucket of the active address
  */
  function getActiveAddressesCount(bytes32 bucket) public view returns(uint256 count) {
    return mocBuckets[bucket].activeBalancesLength;
  }

  /**
    @dev Add values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function addValuesToBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.add(btc);
    bucket.nDoc = bucket.nDoc.add(doc);
    bucket.nBPro = bucket.nBPro.add(bprox);
  }

  /**
    @dev Substract values to all variables of the bucket
    @param bucketName Name of the bucket
    @param btc BTC amount [using reservePrecision]
    @param doc Doc amount [using mocPrecision]
    @param bprox BPro amount [using mocPrecision]
  */
  function substractValuesFromBucket(bytes32 bucketName, uint256 btc, uint256 doc, uint256 bprox)
  public onlyWhitelisted(msg.sender)  {
    MoCBucket storage bucket = mocBuckets[bucketName];

    bucket.nBTC = bucket.nBTC.sub(btc);
    bucket.nDoc = bucket.nDoc.sub(doc);
    bucket.nBPro = bucket.nBPro.sub(bprox);
  }

  /**
    @dev Moves BTC from inrateBag to main BTC bucket bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
   */
  function deliverInrate(bytes32 bucketName, uint256 amount) public
   onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toMove = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toMove);
    bucket.nBTC = bucket.nBTC.add(toMove);
  }

  /**
    @dev Removes Interests rate from Inrate bag
    @param bucketName Name of the bucket to operate
    @param amount value to move from inrateBag to main bag [using reservePrecision]
    @return Retrieved value
   */
  function recoverInrate(bytes32 bucketName, uint256 amount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) bucketStateUpdate(bucketName) returns(uint256) {
    MoCBucket storage bucket = mocBuckets[bucketName];

    uint256 toRetrieve = Math.min(bucket.inrateBag, amount);

    bucket.inrateBag = bucket.inrateBag.sub(toRetrieve);

    return toRetrieve;
  }

  /**
    @dev Moves BTC from origin bucket to destination bucket inrateBag
    @param bucketName name of the bucket to from which takes
    @param btcAmount value to add to main bag [using reservePrecision]
  */
  function payInrate(bytes32 bucketName, uint256 btcAmount) public
  onlyWhitelisted(msg.sender) onlyBaseBucket(bucketName) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.inrateBag = bucket.inrateBag.add(btcAmount);
  }

  /**
    @dev Move Btcs and Docs from one bucket to another
    @param from Name of bucket from where the BTCs will be removed
    @param to Name of bucket from where the BTCs will be added
    @param btc BTCs amount [using reservePrecision]
    @param docs Docs amount [using mocPrecision]
  */
  function moveBtcAndDocs(bytes32 from, bytes32 to, uint256 btc, uint256 docs) public
  onlyWhitelisted(msg.sender) bucketStateUpdate(from) bucketStateUpdate(to) {
    MoCBucket storage bucketFrom = mocBuckets[from];
    MoCBucket storage bucketTo = mocBuckets[to];

    bucketFrom.nBTC = bucketFrom.nBTC.sub(btc);
    bucketTo.nBTC = bucketTo.nBTC.add(btc);

    bucketFrom.nDoc = bucketFrom.nDoc.sub(docs);
    bucketTo.nDoc = bucketTo.nDoc.add(docs);

    emit BucketMovement(from, to, btc, docs);
  }

  /**
    @dev Clears completely the origin bucket, removing all Docs, RBTCs and bproxs
    @param toLiquidate Bucket to be cleared out
    @param destination Bucket that will receive the Docs and RBTCs
   */
  function liquidateBucket(bytes32 toLiquidate, bytes32 destination) public onlyWhitelisted(msg.sender) {
    require(!isBucketBase(toLiquidate), "Cannot liquidate a base bucket");

    clearBucketBalances(toLiquidate);
    emptyBucket(toLiquidate, destination);
  }

  /**
    @dev Clears Docs and BTC from bucket origin and sends them to destination bucket
    @param origin Bucket to clear out
    @param destination Destination bucket
  */
  function emptyBucket(bytes32 origin, bytes32 destination) public onlyWhitelisted(msg.sender) {
    moveBtcAndDocs(origin, destination, mocBuckets[origin].nBTC, mocBuckets[origin].nDoc);
  }

  /**
   * @dev checks if a bucket exists
   * @param bucket name of the bucket
   */
  function isAvailableBucket(bytes32 bucket) public view returns(bool) {
    return mocBuckets[bucket].available;
  }

  /**
    @dev Put all bucket BProx balances in zero
    @param bucketName Bucket to clear out
   */
  function clearBucketBalances(bytes32 bucketName) public onlyWhitelisted(msg.sender) {
    MoCBucket storage bucket = mocBuckets[bucketName];
    bucket.nBPro = 0;
    bucket.activeBalancesLength = 0;
  }

  /**
    @dev Creates bucket
    @param name Name of the bucket
    @param cobj Target Coverage of the bucket
    @param isBase Indicates if it is a base bucket (true) or not (false)
  */
  function createBucket(bytes32 name, uint256 cobj, bool isBase) internal {
    mocBuckets[name].name = name;
    mocBuckets[name].nDoc = 0;
    mocBuckets[name].nBPro = 0;
    mocBuckets[name].nBTC = 0;
    mocBuckets[name].cobj = cobj;
    mocBuckets[name].isBase = isBase;
    mocBuckets[name].available = true;
    emit BucketCreation(name, cobj);
  }

  modifier onlyBaseBucket(bytes32 bucket) {
    require(isBucketBase(bucket), "Bucket should be a base type bucket");
    _;
  }

  modifier bucketStateUpdate(bytes32 bucket) {
    _;
    emit BucketStateUpdate(
      bucket,
      mocBuckets[bucket].nBTC,
      mocBuckets[bucket].nDoc,
      mocBuckets[bucket].nBPro,
      mocBuckets[bucket].inrateBag
      );
  }

  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}
