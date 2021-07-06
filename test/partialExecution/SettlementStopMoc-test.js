const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
const ACCOUNTS_QUANTITY = 10;

const testFunctionPromises = vendorAccount => {
  const testFunctions = [
    { name: 'mintBProxVendors', args: [BUCKET_X2, 0, vendorAccount] },
    { name: 'redeemBProxVendors', args: [BUCKET_X2, 0, vendorAccount] },
    { name: 'redeemDocRequest', args: [0] },
    { name: 'alterRedeemRequestAmount', args: [true, 1] }
  ];

  // Get all tx promises
  return testFunctions.map(func => mocHelper.moc[func.name](...func.args));
};

const assertNonStoppedFunctions = async vendorAccount => {
  const promises = testFunctionPromises(vendorAccount);
  const txResults = await Promise.all(promises);

  return assert(txResults.every(result => result.receipt.status), 'Some transactions reverted');
};

const assertAllStoppedFunctions = vendorAccount => {
  const promises = testFunctionPromises(vendorAccount);
  return Promise.all(
    promises.map(tx => expectRevert(tx, 'Function can only be called when settlement is ready'))
  );
};

const initializeSettlement = async (vendorAccount, owner, accounts) => {
  await mocHelper.revertState();

  // Register vendor for test
  await mocHelper.registerVendor(vendorAccount, 0, owner);

  // Avoid interests
  await mocHelper.mocState.setDaysToSettlement(0);
  const docAccounts = accounts.slice(0, 5);
  await Promise.all(
    docAccounts.map(account => mocHelper.mintBProAmount(account, 10000, vendorAccount))
  );
  await Promise.all(
    docAccounts.map(account => mocHelper.mintDocAmount(account, 10000, vendorAccount))
  );
  await Promise.all(
    docAccounts.map(account =>
      mocHelper.moc.redeemDocRequest(toContractBN(10, 'USD'), {
        from: account
      })
    )
  );

  await mocHelper.mocSettlement.setBlockSpan(1);
};

const setToStall = async () =>
  mocHelper.governor.executeChange(mocHelper.mockMoCStallSettlementChanger.address);

const restartSettlement = async () =>
  mocHelper.governor.executeChange(mocHelper.mockMoCRestartSettlementChanger.address);

contract('MoC: Partial Settlement execution', function([owner, vendorAccount, ...accounts]) {
  const testAccounts = accounts.slice(0, ACCOUNTS_QUANTITY);
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2 } = mocHelper);
    this.governor = mocHelper.governor;
  });

  describe('WHEN the settlement is only partially executed', function() {
    let tx;
    before(async function() {
      await initializeSettlement(vendorAccount, owner, testAccounts);
      tx = await mocHelper.moc.runSettlement(2);
    });
    after(function() {
      return mocHelper.revertState();
    });

    it('THEN only 2 Doc redemption events are emitted', function() {
      const docRedeemEvents = mocHelper.findEvents(tx, 'RedeemRequestProcessed');

      assert(docRedeemEvents.length === 2, 'Not all redeem requests were processed');
    });
    it('AND Settlement is in running state', async function() {
      const running = await mocHelper.mocSettlement.isSettlementRunning();

      assert(running, 'Settlement is not in running state');
    });
    it('AND Settlement is still enabled', async function() {
      const enabled = await mocHelper.mocSettlement.isSettlementEnabled();

      assert(enabled, 'Settlement is not enabled');
    });
    it('THEN BPRox and Doc Redeem Request transactions should revert', async function() {
      await assertAllStoppedFunctions(vendorAccount);
    });
  });
  describe('WHEN the settlement is set to stall AND executed with 100 steps', function() {
    before(async function() {
      await initializeSettlement(vendorAccount, owner, testAccounts);
      await setToStall();
      await mocHelper.moc.runSettlement(100);
    });
    after(function() {
      return mocHelper.revertState();
    });

    it('THEN Settlement is not running state', async function() {
      const running = await mocHelper.mocSettlement.isSettlementRunning();

      assert(!running, 'Settlement is still in running state');
    });
    it('THEN Settlement is not in ready state', async function() {
      const ready = await mocHelper.mocSettlement.isSettlementReady();

      assert(!ready, 'Settlement is in ready state');
    });
    it('AND BPRox and Doc Redeem Request transactions should revert', async function() {
      await assertAllStoppedFunctions(vendorAccount);
    });
    describe('WHEN settlement is set to restart', function() {
      before(function() {
        return restartSettlement();
      });
      it('THEN Settlement is in ready state', async function() {
        const ready = await mocHelper.mocSettlement.isSettlementReady();

        assert(ready, 'Settlement is in ready state');
      });
      it('AND all operations are again available', async function() {
        await assertNonStoppedFunctions(vendorAccount);
      });
    });
  });
});
