const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

const CONTRACT_IS_PAUSED = 'contract_is_paused';

let mocHelper;
let toContractBN;
const blockSpan = 41;

contract('MoC Paused', function([owner, userAccount, vendorAccount, ...accounts]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
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

  describe('DoC Redeem', function() {
    describe(`GIVEN a user owns 1000 Docs, BTC price is 4000 USD, 1 BTC in Bucket blockSpan is ${blockSpan}`, function() {
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
      describe('WHEN he tries to redeem 2000 Docs', function() {
        describe(`AND MoC contract is paused before ${blockSpan} blocks`, function() {
          let userPreBalance;
          let txCost;
          let tx;
          let centsToRedeem;
          beforeEach(async function() {
            userPreBalance = toContractBN(await web3.eth.getBalance(userAccount));
            centsToRedeem = toContractBN(2000, 'USD');
            tx = await this.moc.redeemDocRequest(centsToRedeem, { from });
            txCost = await mocHelper.getTxCost(tx);

            await mocHelper.stopper.pause(mocHelper.moc.address);
            const paused = await mocHelper.moc.paused();
            assert(paused, 'MoC contract must be paused');

            await mocHelper.waitNBlocks(blockSpan);
          });
          it('THEN runSettlement is executed and must revert', async function() {
            await expectRevert(
              mocHelper.moc.runSettlement(blockSpan, { from: owner }),
              CONTRACT_IS_PAUSED
            );
          });
          describe(`AND MoC contract is paused before ${blockSpan} blocks`, function() {
            beforeEach(async function() {
              await mocHelper.stopper.unpause(mocHelper.moc.address);
              const paused = await mocHelper.moc.paused();
              assert(!paused, 'MoC contract must not be paused');
            });
            it('THEN all his 1000 DOCs get redeemed', async function() {
              tx = await mocHelper.moc.runSettlement(blockSpan, { from: owner });
              const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
              const balanceDiff = userPreBalance.sub(userBalance).sub(txCost);
              mocHelper.assertBigRBTC(balanceDiff, -0.25, 'He should receive 0.25 BTC');
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(docBalance, 0, 'Should be 0');
            });
          });
        });
      });
    });
  });

  describe('GIVEN a user with 1000 DOC, BTC Prices 4000 and a redeem position of 200', function() {
    describe('AND Moc Contract is paused', function() {
      const from = userAccount;
      const toMint = 0.25;
      beforeEach(async function() {
        await mocHelper.setBitcoinPrice(toContractBN(4000 * mocHelper.MOC_PRECISION));
        await this.moc.sendTransaction({
          value: 1 * mocHelper.RESERVE_PRECISION
        });
        await this.mockMoCSettlementChanger.setBlockSpan(1);
        await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
        await mocHelper.stopper.pause(mocHelper.moc.address);
        const paused = await mocHelper.moc.paused();
        assert(paused, 'MoC contract must be paused');
      });
      it('THEN mintDoc and redeemDocRequest must revert', async function() {
        await expectRevert(mocHelper.mintDoc(from, toMint, vendorAccount), CONTRACT_IS_PAUSED);
        await expectRevert(
          this.moc.redeemDocRequest(toContractBN(200, 'USD'), {
            from
          }),
          CONTRACT_IS_PAUSED
        );
      });
      describe('WHEN MoC contract is unpaused it AND settlement is executed', function() {
        let toCancel;
        let tx;
        beforeEach(async function() {
          await mocHelper.stopper.unpause(mocHelper.moc.address);
          const paused = await mocHelper.moc.paused();
          assert(!paused, 'MoC contract must not be paused');

          await mocHelper.mintDoc(from, toMint, vendorAccount);
          await this.moc.redeemDocRequest(toContractBN(200, 'USD'), {
            from
          });

          await mocHelper.mintDoc(accounts[2], toMint, vendorAccount);
          await this.moc.redeemDocRequest(toContractBN(200, 'USD'), {
            from: accounts[2]
          });
          toCancel = toContractBN(200, 'USD');
          tx = await this.moc.alterRedeemRequestAmount(false, toCancel, { from });
        });
        it('THEN he still have his 1000 DOCs', async function() {
          const expect = { redeemer: from };
          const r = await mocHelper.findEvents(tx, 'RedeemRequestAlter', expect);
          const [redeemEvent] = r;
          mocHelper.assertBigDollar(redeemEvent.delta, 200, 'Amount must be 200');

          const toRedeem = await this.moc.docAmountToRedeem(from);
          mocHelper.assertBigDollar(toRedeem, 0, 'Amount to redeem value is incorrrect');

          await this.moc.runSettlement(blockSpan, { from: owner });
          const docBalance = await mocHelper.getDoCBalance(from);
          mocHelper.assertBigDollar(docBalance, 1000, 'Balance must not change');
        });
      });
    });
  });
});
