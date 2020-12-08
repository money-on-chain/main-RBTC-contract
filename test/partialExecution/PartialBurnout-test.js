const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const { BN } = web3.utils;
const ACCOUNTS_QUANTITY = 10;

const initializeBurnout = async (owner, vendorAccount, accounts) => {
  await mocHelper.setBitcoinPrice(10000 * mocHelper.MOC_PRECISION);
  await mocHelper.mintBProAmount(owner, 1, vendorAccount);
  await Promise.all(
    accounts.map(async account => {
      await mocHelper.mintDocAmount(account, 500, vendorAccount);
      return mocHelper.moc.setBurnoutAddress(account, { from: account });
    })
  );
};

contract('MoC: Partial Burnout execution', function([owner, vendorAccount, ...accounts]) {
  const accountsTest = accounts.slice(0, ACCOUNTS_QUANTITY);
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocBurnout = mocHelper.mocBurnout;

    this.governor = mocHelper.governor;
    this.mockMoCVendorsChanger = mocHelper.mockMoCVendorsChanger;

    // Register vendor for test
    await this.mockMoCVendorsChanger.setVendorsToRegister(
      await mocHelper.getVendorToRegisterAsArray(vendorAccount, 0)
    );
    await this.governor.executeChange(this.mockMoCVendorsChanger.address);
  });

  describe('GIVEN there are 10 accounts with docs and burnout addresses', function() {
    describe('WHEN evalLiquidation is called with 10 steps', function() {
      let initialBalances;
      let tx;
      before(async function() {
        await initializeBurnout(owner, vendorAccount, accountsTest);
        await mocHelper.setBitcoinPrice(toContractBN(3400, 'USD'));
        initialBalances = await Promise.all(
          accountsTest.map(account => mocHelper.getUserBalances(account))
        );
        tx = await this.moc.evalLiquidation(10);
      });
      after(function() {
        return mocHelper.revertState();
      });
      it('THEN Burnout is not in running state', async function() {
        const running = await mocHelper.mocBurnout.isBurnoutRunning();

        assert(!running, 'Burnout is still in running state');
      });
      it('AND 10 BurnoutAddressProcessed are emitted', async function() {
        const burnoutEvents = mocHelper.findEvents(tx, 'BurnoutAddressProcessed');

        assert(burnoutEvents.length === 10, 'Events count is incorrect');
      });
      it('THEN all accounts get liquidated', async function() {
        const finalBalances = await Promise.all(
          accountsTest.map(account => mocHelper.getUserBalances(account))
        );

        initialBalances.forEach((initial, i) => {
          const final = finalBalances[i];
          const rbtcDiff = new BN(final.rbtc).sub(new BN(initial.rbtc));

          mocHelper.assertBig(final.doc, 0, `User ${i} doc balance is not correct`);
          mocHelper.assertBigRBTC(
            rbtcDiff,
            '0.147058823529411764',
            `User ${i} rbtc balance is not correct`
          );
        });
      });
    });
    describe('WHEN evalLiquidation is called with 2 steps', function() {
      let initialBalances;
      let firstTx;
      let secondTx;
      before(async function() {
        await initializeBurnout(owner, accountsTest);
        await mocHelper.setBitcoinPrice(toContractBN(2000, 'USD'));
        initialBalances = await Promise.all(
          accountsTest.map(account => mocHelper.getUserBalances(account))
        );
        firstTx = await this.moc.evalLiquidation(2);
      });
      after(function() {
        return mocHelper.revertState();
      });
      it('THEN burnout addresses can not be set', async function() {
        const tx = mocHelper.moc.setBurnoutAddress(owner, { from: owner });

        expectRevert(tx, 'Function cannot be called at this state.');
      });
      it('THEN Burnout is still in running state', async function() {
        const running = await mocHelper.mocBurnout.isBurnoutRunning();

        assert(running, 'Burnout is not in running state');
      });
      it('AND only 2 BurnoutAddressProcessed are emitted', async function() {
        const burnoutEvents = mocHelper.findEvents(firstTx, 'BurnoutAddressProcessed');

        assert(burnoutEvents.length === 2, 'Events count is incorrect');
      });
      describe('WHEN btcPrice goes to 5000 again AND evalLiquidation is called again with 10 steps', function() {
        before(async function() {
          await mocHelper.setBitcoinPrice(toContractBN(5000, 'USD'));
          secondTx = await this.moc.evalLiquidation(10);
        });
        it('THEN Burnout is not in running state', async function() {
          const running = await mocHelper.mocBurnout.isBurnoutRunning();

          assert(!running, 'Burnout is still in running state');
        });
        it('AND only 8 BurnoutAddressProcessed are emitted', async function() {
          const burnoutEvents = mocHelper.findEvents(secondTx, 'BurnoutAddressProcessed');

          assert(burnoutEvents.length === 8, 'Events count is incorrect');
        });
        it('AND all accounts get liquidated with the same price', async function() {
          const finalBalances = await Promise.all(
            accountsTest.map(account => mocHelper.getUserBalances(account))
          );

          initialBalances.forEach((initial, i) => {
            const final = finalBalances[i];
            const rbtcDiff = new BN(final.rbtc).sub(new BN(initial.rbtc));

            mocHelper.assertBig(final.doc, 0, `User ${i} doc balance is not correct`);
            mocHelper.assertBigRBTC(rbtcDiff, 0.15, `User ${i} rbtc balance is not correct`);
          });
        });
      });
    });
  });
});
