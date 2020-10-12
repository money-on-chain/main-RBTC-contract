const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

contract('MoC: Doc Redeem on Settlement with commissions', function([
  owner,
  commissionsAccount,
  ...accounts
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocSettlement = mocHelper.mocSettlement;
  });
  describe('GIVEN there are commisions set and there are 3 users with doc redeem requests', function() {
    let prevCommissionsAccountBtcBalance;
    let prevUserBtcBalance;

    before(async function() {

      // Commission rates are set in contractsBuilder.js

      // set commissions address
      await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
      // update params
      await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

      const txTypeMintBpro = "";
      const txTypeMintDoc = "";

      const usersAccounts = accounts.slice(0, 3);
      await Promise.all(usersAccounts.map(account => mocHelper.mintBProAmount(account, 1000, txTypeMintBpro)));
      await Promise.all(usersAccounts.map(account => mocHelper.mintDocAmount(account, 10, txTypeMintDoc)));
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

      it('THEN commissions account increase balance by 0.000006 RBTC', async function() {
        const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
        const diff = btcBalance.sub(prevCommissionsAccountBtcBalance);
        mocHelper.assertBigRBTC(diff, '0.000006', 'commissions account rbtc balance is incorrect');
      });
      it('THEN user account increase balance by 0.000998 RBTC ', async function() {
        const userBtcBalance = toContractBN(await web3.eth.getBalance(accounts[0]));
        const diff = userBtcBalance.sub(prevUserBtcBalance);
        mocHelper.assertBigRBTC(diff, '0.000998', 'commissions account rbtc balance is incorrect');
      });
    });
  });
});
