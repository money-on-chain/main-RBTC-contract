const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
const BTCX_OWNERS_QUANTITY = 9;

const initializeSettlement = async (owner, vendorAccount, btcxOwners) => {
  await mocHelper.revertState();
  await mocHelper.mintBProAmount(owner, 10000, vendorAccount);
  await mocHelper.mintDocAmount(owner, 1000, vendorAccount);
  const promises = [...Array(100).keys()].map(() =>
    mocHelper.moc.redeemDocRequest(toContractBN(1, 'USD'), {
      from: owner
    })
  );

  await Promise.all(
    promises.concat(
      btcxOwners.map(acc => mocHelper.mintBProx(acc, BUCKET_X2, 0.001, vendorAccount))
    )
  );
  // Enabling Settlement
  await mocHelper.mocSettlement.setBlockSpan(1);
};

contract('MoC: Gas limit on settlement', function([owner, vendorAccount, ...btcxOwners]) {
  const btcxAccounts = btcxOwners.slice(0, BTCX_OWNERS_QUANTITY);
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2 } = mocHelper);

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe(`GIVEN there are 100 redeemRequests and ${BTCX_OWNERS_QUANTITY} btcx owners`, function() {
    before(async function() {
      await initializeSettlement(owner, vendorAccount, btcxAccounts);
    });
    describe('WHEN the settlement is executed with 150 steps', function() {
      describe('WHEN settlement is executed in transactions of 50 steps each', function() {
        let txs = [];
        before(async function() {
          txs = await Promise.all([
            mocHelper.moc.runSettlement(50, { gas: 7e6 }),
            mocHelper.moc.runSettlement(50, { gas: 7e6 }),
            mocHelper.moc.runSettlement(50, { gas: 7e6 })
          ]);
          // This makes next settlement far away in time
          await mocHelper.mocSettlement.setBlockSpan(1000);
        });
        it('THEN all transactions execute successfully', async function() {
          assert(txs[0].receipt.status, 'First transaction reverted');
          assert(txs[1].receipt.status, 'Second transaction reverted');
          assert(txs[2].receipt.status, 'Third transaction reverted');
        });
        it('AND Settlement is not in running state', async function() {
          const running = await mocHelper.mocSettlement.isSettlementRunning();

          assert(!running, 'Settlement is still in running state');
        });
        it('AND Settlement is not enabled', async function() {
          const enabled = await mocHelper.mocSettlement.isSettlementEnabled();

          assert(!enabled, 'Settlement is still enabled');
        });
      });
    });
  });
});
