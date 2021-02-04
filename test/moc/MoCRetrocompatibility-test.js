const testHelperBuilder = require('../mocHelper.js');

let mocHelper;

contract.only('MoC: Retrocompatibility', function([
  owner,
  userAccount,
  commissionsAccount,
  otherAddress
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    this.mocState = mocHelper.mocState;
    this.btcPrice = await this.mocState.getBitcoinPrice();
  });

  beforeEach(async function() {
    await mocHelper.revertState();
    // Commission rates for test are set in functionHelper.js
    // await mocHelper.mockMocInrateChanger.setCommissionRates(
    //   await mocHelper.getCommissionsArrayNonZero()
    // );

    // // set commissions address
    // await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // // update params
    // await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('GIVEN since the user wants to mint and redeem BPro with the retrocompatible functions', function() {
    it('WHEN a user tries to mint BPros, THEN operation is successful', async function() {
      const mintAmount = 100;

      // Mint
      await mocHelper.mintBPro(
        userAccount,
        mintAmount
      );
      const balance = await mocHelper.getBProBalance(userAccount);
      mocHelper.assertBigRBTC(balance, mintAmount, 'userAccount BPro balance was not mintAmount');
    });
    it('WHEN a user tries to redeem BPros, THEN operation is successful', async function() {
      const redeemAmount = 100;

      // Mint
      await mocHelper.redeemBPro(
        userAccount,
        redeemAmount
      );
      const balance = await mocHelper.getBProBalance(userAccount);
      mocHelper.assertBigRBTC(balance, 0, 'userAccount BPro balance was not 0');
    });
  });
  describe('GIVEN since the user wants to mint and redeem DOC with the retrocompatible functions', function() {
    it('WHEN a user tries to mint DOCs, THEN operation is successful', async function() {

      // Mint BPros
      await mocHelper.mintBPro(
        userAccount,
        100
      );

      const mintAmount = 1;

      // Mint
      await mocHelper.mintDoC(
        userAccount,
        mintAmount
      );
      const balance = await mocHelper.getDoCBalance(userAccount);
      const mintAmountInDoC = mintAmount.mul(this.btcPrice).div(mocHelper.RESERVE_PRECISION);
      mocHelper.assertBigRBTC(balance, mintAmountInDoC, 'userAccount DoC balance was not mintAmountInDoC');
    });
    it('WHEN a user tries to redeem DOCs, THEN operation is successful', async function() {

      const redeemAmount = 1;

      // Mint
      await mocHelper.redeemDoC(
        userAccount,
        redeemAmount
      );
      const balance = await mocHelper.getDoCBalance(userAccount);
      const redeemAmountInDoC = redeemAmount.mul(this.btcPrice).div(mocHelper.RESERVE_PRECISION);
      mocHelper.assertBigRBTC(balance, redeemAmountInDoC, 'userAccount DoC balance was not mintAmountInDoC');
    });
  });
});