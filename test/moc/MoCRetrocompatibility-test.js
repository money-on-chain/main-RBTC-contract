const testHelperBuilder = require('../mocHelper.js');

const { BN } = web3.utils;

let mocHelper;
let BUCKET_X2;

contract('MoC: Retrocompatibility', function([owner, userAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ BUCKET_X2 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    this.mocState = mocHelper.mocState;
    this.btcPrice = await this.mocState.getBitcoinPrice();
    this.bprox2Price = await this.mocState.bucketBProTecPrice(BUCKET_X2);
  });

  beforeEach(async function() {
    await mocHelper.revertState();
  });

  describe('GIVEN since the user wants to mint and redeem BPro with the retrocompatible functions', function() {
    it('WHEN a user tries to mint BPros, THEN operation is successful', async function() {
      const mintAmount = 100;

      // Mint
      await mocHelper.mintBPro(userAccount, mintAmount);
      const balance = await mocHelper.getBProBalance(userAccount);
      mocHelper.assertBigRBTC(balance, mintAmount, 'userAccount BPro balance was not mintAmount');
    });
    it('WHEN a user tries to redeem BPros, THEN operation is successful', async function() {
      const redeemAmount = 100;

      // Redeem
      await mocHelper.redeemBPro(userAccount, redeemAmount);
      const balance = await mocHelper.getBProBalance(userAccount);
      mocHelper.assertBigRBTC(balance, 0, 'userAccount BPro balance was not 0');
    });
  });
  describe('GIVEN since the user wants to mint and redeem DOC with the retrocompatible functions', function() {
    it('WHEN a user tries to mint DOCs, THEN operation is successful', async function() {
      // Mint BPros to be able to mint DoC
      await mocHelper.mintBPro(userAccount, 100);

      const mintAmount = 1;

      // Mint
      await mocHelper.mintDoc(userAccount, mintAmount);
      const balance = await mocHelper.getDoCBalance(userAccount);
      const mintAmountInDoC = new BN(mintAmount)
        .mul(this.btcPrice)
        .div(mocHelper.RESERVE_PRECISION);
      mocHelper.assertBigRBTC(
        balance,
        mintAmountInDoC,
        'userAccount DoC balance was not mintAmountInDoC'
      );
    });
    it('WHEN a user tries to redeem DOCs, THEN operation is successful', async function() {
      const redeemAmount = 1;

      // Redeem
      await mocHelper.redeemFreeDoc({
        userAccount,
        docAmount: redeemAmount
      });
      const balance = await mocHelper.getDoCBalance(userAccount);
      mocHelper.assertBigRBTC(balance, 0, 'userAccount DoC balance was not 0');
    });
  });
  describe('GIVEN since the user wants to mint and redeem BPROX with the retrocompatible functions', function() {
    it('WHEN a user tries to mint BPROXs, THEN operation is successful', async function() {
      // Mint BPros to be able to mint DoC
      await mocHelper.mintBPro(userAccount, 100);
      // Mint DOCs to be able to mint BTCX
      await mocHelper.mintDoc(userAccount, 100);

      const mintAmount = 1;

      // Mint
      await mocHelper.mintBProx(userAccount, BUCKET_X2, mintAmount);
      const balance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);
      const mintAmountInBTCX = new BN(mintAmount)
        .mul(mocHelper.MOC_PRECISION)
        .div(this.bprox2Price);
      mocHelper.assertBigRBTC(
        balance,
        mintAmountInBTCX,
        'userAccount BPROX balance was not mintAmountInBTCX'
      );
    });
    it('WHEN a user tries to redeem BPROXs, THEN operation is successful', async function() {
      const redeemAmount = 1;

      // Redeem
      await mocHelper.redeemBProx(userAccount, BUCKET_X2, redeemAmount);
      const balance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);
      mocHelper.assertBigRBTC(balance, 0, 'userAccount BPROX balance was not 0');
    });
  });
});
