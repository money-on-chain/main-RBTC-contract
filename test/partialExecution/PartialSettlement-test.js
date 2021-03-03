const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let initialBalances;
let BUCKET_X2;

const { BN } = web3.utils;

// Asserts
const assertStartSettlementEvent = async (
  settlementCompleteEvent,
  btcPrice,
  docCount,
  deleverCount
) => {
  mocHelper.assertBigDollar(
    settlementCompleteEvent.reservePrice,
    btcPrice,
    'BTC Price is not correct'
  );
  mocHelper.assertBig(
    settlementCompleteEvent.stableTokenRedeemCount,
    docCount,
    'Redeem requests processed value is incorrect'
  );
  mocHelper.assertBig(
    settlementCompleteEvent.deleveragingCount,
    deleverCount,
    'BTCx accounts liquidated value is incorrect'
  );
};

// Returns a promise that execute
// Price set and settlement
const executeSettlementRound = async round => {
  await mocHelper.setBitcoinPrice(toContractBN(round.btcPrice, 'USD'));
  return mocHelper.moc.runSettlement(round.step);
};

const initializeSettlement = async (vendorAccount, owner, accounts) => {
  await mocHelper.revertState();

  // Register vendor for test
  await mocHelper.registerVendor(vendorAccount, 0, owner);

  // Avoid interests
  await mocHelper.mocState.setDaysToSettlement(0);
  const docAccounts = accounts.slice(0, 5);
  const btcxAccounts = accounts.slice(5, 8);
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

  await Promise.all(
    btcxAccounts.map(account => mocHelper.mintBProxAmount(account, BUCKET_X2, 1, vendorAccount))
  );
  initialBalances = await Promise.all(accounts.map(address => mocHelper.getUserBalances(address)));
  await mocHelper.mocSettlement.setBlockSpan(1);
};

// Returns a promise that execute
// Run settlement for all rounds in the scenario in order
const runScenario = scenario => {
  const txs = [];
  const reduced = scenario.rounds.reduce(
    (prevPromise, round) =>
      prevPromise.then(tx => {
        if (tx) txs.push(tx);
        return executeSettlementRound(round);
      }),
    Promise.resolve()
  );
  return reduced.then(lastTx => txs.concat(lastTx));
};

contract('MoC: Partial Settlement execution', function([owner, vendorAccount, ...accounts]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2 } = mocHelper);
  });

  const scenarios = [
    {
      description: 'WHEN settlement es executed in 1 round of 10 steps',
      rounds: [{ btcPrice: 10000, step: 10 }]
    },
    {
      description:
        'WHEN settlement es executed in 2 rounds of 2 and 5 steps AND price change in the middle',
      rounds: [{ btcPrice: 10000, step: 2 }, { btcPrice: 8000, step: 6 }]
    },
    {
      description:
        'WHEN settlement es executed in 2 rounds of 5 and 2 steps AND price change in the middle',
      rounds: [{ btcPrice: 10000, step: 5 }, { btcPrice: 7000, step: 3 }]
    }
  ];

  describe('Step execution consistency', function() {
    describe('GIVEN there are 5 redeemRequests of 10 docs and 3 BTCx positions of 1 BTCx', function() {
      scenarios.forEach(async scenario => {
        let txs = [];
        describe(scenario.description, function() {
          before(async function() {
            await initializeSettlement(vendorAccount, owner, accounts);
            txs = await runScenario(scenario);
          });

          it('THEN settlementStarted Event is emitted with correct values', async function() {
            const [settlementStartedEvent] = mocHelper.findEventsInTxs(txs, 'SettlementStarted');
            await assertStartSettlementEvent(settlementStartedEvent, 10000, 5, 3);
          });
          it('THEN settlementCompleted Event is emitted', async function() {
            const [settlementCompleteEvent] = mocHelper.findEventsInTxs(txs, 'SettlementCompleted');
            assert(settlementCompleteEvent, 'Not all redeem requests were processed');
          });
          it('AND 5 Doc redemption events are emitted', function() {
            const docRedeemEvents = mocHelper.findEventsInTxs(txs, 'RedeemRequestProcessed');
            assert(docRedeemEvents.length === 5, 'Not all redeem requests were processed');
          });
          it('AND Settlement is no longer in running state', async function() {
            const running = await mocHelper.mocSettlement.isSettlementRunning();

            assert(!running, 'Settlement is still in running state');
          });
          it('AND all btcx owners got redeemed', async function() {
            const finalBalances = await Promise.all(
              accounts.slice(5, 8).map(address => mocHelper.getUserBalances(address))
            );

            finalBalances.forEach((balances, i) => {
              const initial = initialBalances[i + 5];
              const diff = new BN(balances.rbtc).sub(new BN(initial.rbtc));

              mocHelper.assertBig(balances.bpro2x, 0, 'User btcx balance is not zero');
              mocHelper.assertBigRBTC(diff, 1, 'User rbtc balance is not correct');
            });
          });
          it('AND all doc owners got redeemed', async function() {
            const finalBalances = await Promise.all(
              accounts.slice(0, 5).map(address => mocHelper.getUserBalances(address))
            );

            finalBalances.forEach((balances, i) => {
              const initial = initialBalances[i];
              const rbtcDiff = new BN(balances.rbtc).sub(new BN(initial.rbtc));
              const docDiff = new BN(initial.doc).sub(new BN(balances.doc));

              mocHelper.assertBigDollar(docDiff, 10, 'User doc balance is not correct');
              mocHelper.assertBigRBTC(rbtcDiff, 0.001, 'User rbtc balance is not correct');
            });
          });

          after(function() {
            return mocHelper.revertState();
          });
        });
      });
    });
  });

  describe('Consecutive Settlements', function() {
    describe('GIVEN first settlement is executed', function() {
      before(async function() {
        await initializeSettlement(vendorAccount, owner, accounts);
        await mocHelper.moc.runSettlement(4);
        await mocHelper.setBitcoinPrice(toContractBN(8000, 'USD'));
        await mocHelper.moc.runSettlement(4);
        // This makes settlement not always enabled
        await mocHelper.mocSettlement.setBlockSpan(100);
      });
      it('THEN Settlement is not enabled', async function() {
        const enabled = await mocHelper.mocSettlement.isSettlementEnabled();
        assert(!enabled, 'Settlement is still enabled');
      });
      describe('WHEN settlement is executed before block span passed', function() {
        it('THEN transaction reverts because the settlement is not enabled', async function() {
          const tx = mocHelper.moc.runSettlement(1);

          await expectRevert(tx, 'Settlement not yet enabled');
        });
      });

      describe('WHEN 100 blocks passes second settlement is executed', function() {
        let secondSettlementEvent;
        let beforeBalances;
        before(async function() {
          beforeBalances = await Promise.all(
            accounts.map(account => mocHelper.getUserBalances(account))
          );
          await mocHelper.waitNBlocks(100);
          const tx = await mocHelper.moc.runSettlement(1);
          [secondSettlementEvent] = mocHelper.findEvents(tx, 'SettlementStarted');
        });
        it('THEN Settlement is not enabled anymore', async function() {
          const enabled = await mocHelper.mocSettlement.isSettlementEnabled();
          assert(!enabled, 'Settlement is still enabled');
        });
        it('AND Settlement event have clean new values', async function() {
          await assertStartSettlementEvent(secondSettlementEvent, 8000, 0, 0);
        });
        it('AND no account change their balances', async function() {
          const finalBalances = await Promise.all(
            accounts.map(account => mocHelper.getUserBalances(account))
          );

          beforeBalances.forEach((initial, i) => {
            const final = finalBalances[i];

            mocHelper.assertBig(initial.doc, final.doc, 'User doc balance is not correct');
            mocHelper.assertBig(initial.bpro2x, final.bpro2x, 'User btc2x balance is not correct');
            mocHelper.assertBig(initial.rbtc, final.rbtc, 'User rbtc balance is not correct');
          });
        });
      });
    });
  });
});
