const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

const DoC = artifacts.require('./contracts/DocToken.sol');

let mocHelper;
let toContractBN;
let BUCKET_C0;

contract('MoC', function([owner, userAccount, attacker, vendorAccount, ...accounts]) {
  const blockSpan = 41;

  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_C0 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocConnector = mocHelper.mocConnector;
    this.mocSettlement = mocHelper.mocSettlement;
    this.revertingContract = mocHelper.revertingContract;
    this.mockMoCSettlementChanger = mocHelper.mockMoCSettlementChanger;
    this.governor = mocHelper.governor;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('DoC Redeem DoS attack mitigation', function() {
    describe('GIVEN an honest user adds a DoC redeem request for 1000 DoCs AND an attacker adds a request for 100 DoCs', function() {
      const from = userAccount;
      beforeEach(async function() {
        await mocHelper.setBitcoinPrice(10000 * mocHelper.MOC_PRECISION);

        await mocHelper.mintBProAmount(owner, 3, vendorAccount);
        await mocHelper.mintDocAmount(from, 1000, vendorAccount);
        await this.moc.redeemDocRequest(toContractBN(1000 * mocHelper.MOC_PRECISION), {
          from
        });
        const toMint = toContractBN(0.1 * mocHelper.RESERVE_PRECISION);
        // Attacker mints and tries to redeem
        await this.revertingContract.mintDoc(toMint, vendorAccount, {
          value: toMint,
          from: attacker
        });
        await this.revertingContract.redeemDoCRequest(toContractBN(100 * mocHelper.MOC_PRECISION), {
          from: attacker
        });

        // From now reverting
        await this.revertingContract.setAcceptingMoney(false);
        // Enabling Settlement
        await this.mockMoCSettlementChanger.setBlockSpan(1);
        await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
      });

      describe('WHEN a settlement is run', function() {
        beforeEach(async function() {
          await mocHelper.executeSettlement();
        });
        it('AND the queue is empty', async function() {
          const redeemQueueSize = await this.moc.redeemQueueSize();

          mocHelper.assertBig(redeemQueueSize, 0, 'The redeem queue is not empty');
        });
        it('AND the honest user gets redeemed AND the attacker dont', async function() {
          const finalHonestDocBalance = await mocHelper.getDoCBalance(userAccount);
          const finalAttackerBalance = await mocHelper.getDoCBalance(
            this.revertingContract.address
          );

          mocHelper.assertBig(finalHonestDocBalance, 0, 'Honest Doc balance should be zero');
          mocHelper.assertBigDollar(
            finalAttackerBalance,
            1000,
            'Attackers Doc balance should be 1000'
          );
        });
      });
    });
  });

  describe('DoC Redeem', function() {
    describe(`GIVEN a user owns 1000 Docs, BTC price is 4000 USD, there is 1 BTC in Bucket 0 AND blockSpan is ${blockSpan}`, function() {
      const from = userAccount;
      beforeEach(async function() {
        await mocHelper.setBitcoinPrice(4000 * mocHelper.MOC_PRECISION);
        await this.moc.sendTransaction({
          value: 1 * mocHelper.RESERVE_PRECISION
        });
        await mocHelper.mintDoc(from, 0.25, vendorAccount);
        await this.mockMoCSettlementChanger.setBlockSpan(blockSpan);
        await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
      });
      it(`THEN blockSpan should be ${blockSpan}`, async function() {
        const actualBlockSpan = await this.mocSettlement.getBlockSpan();
        await mocHelper.assertBig(actualBlockSpan, blockSpan, 'Should be what we set it to be');
      });
      describe('WHEN a user tries to get element 1 of an empty queue', function() {
        it('THEN it reverts', async function() {
          const getRedeemRequestAtPromise = this.moc.getRedeemRequestAt(1);
          await expectRevert.unspecified(getRedeemRequestAtPromise);
        });
      });
      describe('WHEN he tries to redeem 2000 Docs', function() {
        describe(`AND after ${blockSpan} blocks, the settlement is executed`, function() {
          let userPreBalance;
          let txCost;
          beforeEach(async function() {
            userPreBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const centsToRedeem = toContractBN(2000 * mocHelper.MOC_PRECISION);
            const tx = await this.moc.redeemDocRequest(centsToRedeem, { from });
            txCost = await mocHelper.getTxCost(tx);

            await mocHelper.waitNBlocks(blockSpan);
            await mocHelper.executeSettlement();
          });
          it('THEN all his 1000 DOCs get redeemed', async function() {
            const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const balanceDiff = userPreBalance.sub(userBalance).sub(txCost);
            mocHelper.assertBigRBTC(balanceDiff, -0.25, 'He should receive 0.25 BTC');
            const docBalance = await mocHelper.getDoCBalance(userAccount);
            mocHelper.assertBigDollar(docBalance, 0, 'Should be 0');
          });
          it('AND amount to redeem value should be 0', async function() {
            const toRedeem = await this.moc.docAmountToRedeem(from);
            mocHelper.assertBigDollar(toRedeem, 0, 'Amount to redeem value is incorrect');
          });
        });
      });
      describe('WHEN he push a 400 Docs redeem request', function() {
        describe(`AND ${blockSpan} blocks are mined`, function() {
          let userPreBalance;
          let txCost;
          let c0PrevDocBalance;
          let c0PrevBTCBalance;
          beforeEach(async function() {
            userPreBalance = toContractBN(await web3.eth.getBalance(userAccount));

            c0PrevDocBalance = await this.mocState.getBucketNDoc(BUCKET_C0);
            c0PrevBTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
            const tx = await this.moc.redeemDocRequest(
              toContractBN(400 * mocHelper.MOC_PRECISION),
              { from }
            );
            txCost = await mocHelper.getTxCost(tx);
            const redeemQueueSize = await this.moc.redeemQueueSize();
            mocHelper.assertBig(redeemQueueSize, 1, 'Size should be one');
            const redeemRequest = await this.moc.getRedeemRequestAt(0);
            assert.equal(redeemRequest[0], from, 'Redeemer should be sender');
            mocHelper.assertBigDollar(redeemRequest[1], 400, 'Redeem amount should be 400');

            // Redeem Doc Request should emit an Event
            const [redeemEvent] = await mocHelper.findEvents(tx, 'RedeemRequestAlter');
            mocHelper.assertBigDollar(redeemEvent.delta, 400, 'Event amount should be 400');

            await mocHelper.waitNBlocks(blockSpan);
          });
          describe('AND settlement is executed', function() {
            it('THEN he receives 0.1 BTCs, his Doc balance is 600 AND redeemQueue is empty', async function() {
              const settlementTx = await mocHelper.executeSettlement();
              const redeemQueueSizeAfter = await this.moc.redeemQueueSize();
              mocHelper.assertBig(
                redeemQueueSizeAfter,
                0,
                'After settlement, queue should be empty'
              );

              // Settlement should be disabled
              const isSettlementEnable = await this.moc.isSettlementEnabled();
              assert.isFalse(isSettlementEnable, 'Settlement should be disabled');
              // Settlement execution should emit an Event
              const [event] = await mocHelper.findEvents(
                settlementTx,
                'SettlementRedeemStableToken'
              );
              mocHelper.assertBig(event.queueSize, 1, 'Queue size should be one');
              mocHelper.assertBigDollar(
                event.reservePrice,
                4000,
                'Btc Price should not had changed'
              );
              // Assert RedeemRequestProcessed Event as well
              const expect = { redeemer: from };
              const [redeemEvent] = await mocHelper.findEvents(
                settlementTx,
                'RedeemRequestProcessed',
                expect
              );
              mocHelper.assertBigDollar(redeemEvent.amount, 400, 'Amount should be 400');

              // User post settlement balances should have changed
              const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
              const balanceDiff = userPreBalance.sub(userBalance).sub(txCost);
              mocHelper.assertBigRBTC(balanceDiff, -0.1, 'He should receive 0.1 BTC');
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(docBalance, 600, 'Should be 1000 - 400');

              // If he places a second redeem request
              await this.moc.redeemDocRequest(toContractBN(200 * mocHelper.MOC_PRECISION), {
                from
              });
              const newRedeemQueueSize = await this.moc.redeemQueueSize();
              mocHelper.assertBig(newRedeemQueueSize, 1, 'New size should be one');
              const newDocBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(newDocBalance, 600, 'Doc Balance should not be affected');
            });

            it('AND the C0 contract balances decreases on 0.1 BTCs and 600 Docs', async function() {
              await mocHelper.executeSettlement();
              const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
              const btcDiff = c0BTCBalance.sub(c0PrevBTCBalance);
              mocHelper.assertBigRBTC(btcDiff, -0.1, 'C0 BTC amount should decrease 0.1 BTC');
              const c0DocBalance = await this.mocState.getBucketNDoc(BUCKET_C0);
              const docDiff = c0DocBalance.sub(c0PrevDocBalance);
              mocHelper.assertBigDollar(docDiff, -400, 'C0 BTC amount should decrease 400 Doc');
            });
          });
          describe('AND he then transfers 800 Docs to someone else', function() {
            it('THEN when settlement is executed, the redeem only fills 200 DOCs', async function() {
              const doc = await DoC.at(await this.mocConnector.docToken());
              await doc.transfer(accounts[2], toContractBN(800 * mocHelper.MOC_PRECISION), {
                from
              });
              const userBalance = toContractBN(await web3.eth.getBalance(userAccount));

              // Assert Amount to redeem function
              const toRedeem = await this.moc.docAmountToRedeem(from);
              mocHelper.assertBigDollar(toRedeem, 400, 'Amount to redeem value is incorrect');

              // Settlement is run
              const tx = await mocHelper.executeSettlement();
              // Assert SettlementRedeemStableToken Event
              const [redeemEvent] = await mocHelper.findEvents(tx, 'SettlementRedeemStableToken');
              mocHelper.assertBig(redeemEvent.queueSize, 1, 'Queue size should be one');

              // Assert RedeemRequestProcessed Event
              const expect = { redeemer: from };
              const [redeemProcEvent] = await mocHelper.findEvents(
                tx,
                'RedeemRequestProcessed',
                expect
              );
              mocHelper.assertBigDollar(redeemProcEvent.amount, 200, 'Amount should be 200');

              // User post settlement balances should have changed the total of the redemption
              const userPostSettlementBalance = toContractBN(
                await web3.eth.getBalance(userAccount)
              );
              const balanceDiff = userBalance.sub(userPostSettlementBalance);
              mocHelper.assertBigRBTC(balanceDiff, -0.05, 'He should receive 0.05 RBTC');
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(docBalance, 0, 'Should be 1000-800-200 = 0 left');

              // Other user balance should not be affected
              const otherUserDocBalance = await mocHelper.getDoCBalance(accounts[2]);
              mocHelper.assertBigDollar(otherUserDocBalance, 800, 'Should be 800');
            });
          });
        });
      });
    });
  });

  describe('DoC Redeem Alter', function() {
    describe('GIVEN a user with 1000 DOC and a redeem position of 200', function() {
      const from = userAccount;
      beforeEach(async function() {
        await mocHelper.setBitcoinPrice(toContractBN(4000 * mocHelper.MOC_PRECISION));
        await this.moc.sendTransaction({
          value: 1 * mocHelper.RESERVE_PRECISION
        });
        const toMint = 0.25;
        await mocHelper.mintDoc(from, toMint, vendorAccount);
        await this.moc.redeemDocRequest(toContractBN(200 * mocHelper.MOC_PRECISION), {
          from
        });

        // Add other redeemer
        await mocHelper.mintDoc(accounts[2], toMint, vendorAccount);
        await this.moc.redeemDocRequest(toContractBN(200 * mocHelper.MOC_PRECISION), {
          from: accounts[2]
        });

        await this.mockMoCSettlementChanger.setBlockSpan(1);
        await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
      });
      describe('WHEN he cancel it AND settlement is executed', function() {
        let toCancel;
        let tx;
        beforeEach(async function() {
          toCancel = toContractBN(200 * mocHelper.MOC_PRECISION);
          tx = await this.moc.alterRedeemRequestAmount(false, toCancel, { from });
        });
        it('THEN he still have his 1000 DOCs', async function() {
          // Assert RedeemRequestAlter Event
          const expect = { redeemer: from };
          const r = await mocHelper.findEvents(tx, 'RedeemRequestAlter', expect);
          const [redeemEvent] = r;
          mocHelper.assertBigDollar(redeemEvent.delta, 200, 'Amount should be 200');

          // Assert Amount to redeem function
          const toRedeem = await this.moc.docAmountToRedeem(from);
          mocHelper.assertBigDollar(toRedeem, 0, 'Amount to redeem value is incorrect');

          await mocHelper.executeSettlement();
          const docBalance = await mocHelper.getDoCBalance(from);
          mocHelper.assertBigDollar(docBalance, 1000, 'Balance should not change');
        });
        it('AND other redeem requests are not affected', async function() {
          await mocHelper.executeSettlement();
          const docBalance = await mocHelper.getDoCBalance(accounts[2]);
          mocHelper.assertBigDollar(docBalance, 800, 'Balance should had decrease by 200');
        });
      });
      describe('WHEN he adds 300 more to redeem', function() {
        beforeEach(async function() {
          const toAdd = toContractBN(300 * mocHelper.MOC_PRECISION);
          await this.moc.alterRedeemRequestAmount(true, toAdd, { from });
        });
        it('THEN his amount to redeem should be 500', async function() {
          const toRedeem = await this.moc.docAmountToRedeem(from);
          mocHelper.assertBigDollar(toRedeem, 500, 'Amount to redeem value is incorrect');
        });
        describe('AND settlement is run', function() {
          it('THEN his DOC balance is 500', async function() {
            await mocHelper.executeSettlement();
            const docBalance = await mocHelper.getDoCBalance(from);
            mocHelper.assertBigDollar(docBalance, 500, 'Remaining should be 1000-200-300');
          });
        });
      });
      describe('AND puts a new redeem position of 300', function() {
        describe('AND cancels 400', function() {
          it('THEN he redeem 100 DOCs', async function() {
            await this.moc.redeemDocRequest(toContractBN(300 * mocHelper.MOC_PRECISION), {
              from
            });

            const toCancel = toContractBN(400 * mocHelper.MOC_PRECISION);
            await this.moc.alterRedeemRequestAmount(false, toCancel, { from });

            await mocHelper.executeSettlement();
            const docBalance = await mocHelper.getDoCBalance(from);
            mocHelper.assertBigDollar(docBalance, 900, 'Balance should have decrease by 100');
          });
        });
      });
    });
  });

  describe('Coverage below protection mode', function() {
    describe(`GIVEN a user owns 1000 Docs, BTC price is 2000 USD, there is 1 BTC in Bucket 0 AND blockSpan is ${blockSpan}`, function() {
      const from = userAccount;
      const docAmount = 0.25;
      const lowPrice = 2000;
      const normalPrice = 10000;
      beforeEach(async function() {
        await this.moc.sendTransaction({
          value: 1 * mocHelper.RESERVE_PRECISION
        });
        await mocHelper.mintDoc(from, docAmount, vendorAccount);
        // Enabling Settlement
        await this.mockMoCSettlementChanger.setBlockSpan(1);
        await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
        await mocHelper.setBitcoinPrice(lowPrice * mocHelper.MOC_PRECISION);
      });
      describe('WHEN a settlement is run', function() {
        beforeEach(async function() {
          await mocHelper.executeSettlement();
        });
        it('THEN docRedemptionStepCount should be 0', async function() {
          const docRedemptionStepCount = await this.mocSettlement.docRedemptionStepCountForTest();
          await mocHelper.assertBig(
            docRedemptionStepCount,
            0,
            'docRedemptionStepCount Should be 0'
          );
        });
        it(`THEN if BTC price is back to ${normalPrice}, docRedemptionStepCount should be ${docAmount}`, async function() {
          await mocHelper.setBitcoinPrice(normalPrice * mocHelper.MOC_PRECISION);

          const docRedemptionStepCountNormal = await this.mocSettlement.docRedemptionStepCountForTest();
          await mocHelper.assertBig(
            docRedemptionStepCountNormal,
            docAmount,
            'docRedemptionStepCount Should be greater than 0'
          );
        });
      });
    });
  });
});
