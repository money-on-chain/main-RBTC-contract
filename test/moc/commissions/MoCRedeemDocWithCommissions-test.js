const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

contract('MoC: Doc Redeem on Settlement with commissions', function([
  owner,
  commissionsAccount,
  vendorAccount,
  ...accounts
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocSettlement = mocHelper.mocSettlement;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
  });
  describe('GIVEN there are commisions set and there are 3 users with doc redeem requests', function() {
    let prevCommissionsAccountBtcBalance;
    let prevUserBtcBalance;

    before(async function() {
      // Register vendor for test
      await mocHelper.registerVendor(vendorAccount, 0.01, owner);

      // Commission rates for test are set in functionHelper.js
      await this.mockMocInrateChanger.setCommissionRates(
        await mocHelper.getCommissionsArrayNonZero()
      );

      // set commissions address
      await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
      // update params
      await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);

      const txTypeMintBpro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
      const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();

      const usersAccounts = accounts.slice(0, 3);
      await Promise.all(
        usersAccounts.map(account =>
          mocHelper.mintBProAmount(account, 1000, vendorAccount, txTypeMintBpro)
        )
      );
      await Promise.all(
        usersAccounts.map(account =>
          mocHelper.mintDocAmount(account, 10, vendorAccount, txTypeMintDoc)
        )
      );
      await Promise.all(
        usersAccounts.map(account =>
          this.moc.redeemDocRequest(toContractBN(10 * mocHelper.MOC_PRECISION), {
            from: account
          })
        )
      );

      prevCommissionsAccountBtcBalance = toContractBN(
        await web3.eth.getBalance(commissionsAccount)
      );

      prevUserBtcBalance = toContractBN(await web3.eth.getBalance(accounts[0]));
    });
    describe('WHEN the settlement is executed', function() {
      before(async function() {
        // Enabling Settlement
        await this.mocSettlement.setBlockSpan(1);
        await mocHelper.executeSettlement();
      });

      it('THEN commissions account increase balance by 0.000012 RBTC', async function() {
        const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
        const diff = btcBalance.sub(prevCommissionsAccountBtcBalance);
        mocHelper.assertBigRBTC(diff, '0.000012', 'commissions account rbtc balance is incorrect');
      });
      it('THEN user account increase balance by 0.000996 RBTC ', async function() {
        const userBtcBalance = toContractBN(await web3.eth.getBalance(accounts[0]));
        const diff = userBtcBalance.sub(prevUserBtcBalance);
        mocHelper.assertBigRBTC(diff, '0.000996', 'commissions account rbtc balance is incorrect');
      });
    });
  });
});
