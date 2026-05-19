const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_C0;

contract('MoC: MoCExchange', function([owner, userAccount, vendorAccount]) {
  /*
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_C0 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('BPro minting', function() {
    describe('GIVEN sends 100 RBTC to mint BPro', function() {
      [(0, 100)].forEach(nBPros => {
        describe(`AND there are ${nBPros} nBPros`, function() {
          let userPrevBalance;
          let txCost;
          let c0bproPrevBalance;
          beforeEach(async function() {
            if (nBPros) {
              await mocHelper.mintBProAmount(owner, nBPros, vendorAccount);
            }

            userPrevBalance = toContractBN(await web3.eth.getBalance(userAccount));
            c0bproPrevBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
            const tx = await mocHelper.mintBPro(userAccount, 100, vendorAccount);
            txCost = await mocHelper.getTxCost(tx);
          });
          it('THEN he receives 100 BPro on his account', async function() {
            const balance = await mocHelper.getBProBalance(userAccount);
            mocHelper.assertBigRBTC(balance, 100, 'userAccount BPro balance was not 10000');
          });
          it('AND GLOBAL balance increases by 100 RBTC', async function() {
            const mocEthBalance = await web3.eth.getBalance(this.moc.address);
            mocHelper.assertBigRBTC(
              mocEthBalance,
              100 + nBPros,
              'Should only increase the total amount of the sale'
            );
          });
          it('AND C0 Bucket balance increases by 100 RBTC', async function() {
            const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
            mocHelper.assertBigRBTC(
              c0BTCBalance,
              100 + nBPros,
              'C0 BTC amount should rise 10000 wei'
            );
          });
          it('AND C0 Bucket BPro balance increases by 100 BPro', async function() {
            const c0BProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
            const diff = c0BProBalance.sub(c0bproPrevBalance);
            mocHelper.assertBigRBTC(diff, 100, 'C0 BTC amount should rise 10000 wei');
          });
          it('AND User Balance decreases by 100 + fee', async function() {
            const userBalance = await web3.eth.getBalance(userAccount);
            const diff = toContractBN(userPrevBalance)
              .sub(toContractBN(userBalance))
              .sub(toContractBN(txCost));
            mocHelper.assertBigRBTC(
              diff,
              100,
              'Should decrease by the cost of the Token and the gas used'
            );
          });
        });
      });
    });

    describe('GIVEN a user owns 10 BPros', function() {
      let userPreBalance;
      let initialBProBalance;
      let c0PrevBProBalance;
      let c0PrevBTCBalance;
      let maxBPro;
      const from = userAccount;
      beforeEach(async function() {
        await mocHelper.mintBPro(from, 11, vendorAccount);
        c0PrevBProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
        c0PrevBTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
        initialBProBalance = await mocHelper.getBProBalance(userAccount);
        userPreBalance = toContractBN(await web3.eth.getBalance(userAccount));
      });
      describe('AND there are 50000 DOCs AND BTC Price falls to 8000', function() {
        beforeEach(async function() {
          await mocHelper.mintDocAmount(owner, 50000, vendorAccount);
          await mocHelper.setBitcoinPrice(8000 * mocHelper.MOC_PRECISION);
        });
        describe('WHEN he tries to redeem 3 BPros', function() {
          it('THEN reverts for having the Coverage below Cobj', async function() {
            const coverage = await this.mocState.globalCoverage();
            const cobj = 3 * mocHelper.MOC_PRECISION;
            assert(coverage < cobj, 'Coverage is not below Cobj');
            const bproRedemption = mocHelper.redeemBPro(from, 3, vendorAccount);
            await expectRevert.unspecified(bproRedemption);
          });
        });
      });
      describe('AND BTC Price rises to 16000', function() {
        beforeEach(async function() {
          await mocHelper.setBitcoinPrice(16000 * mocHelper.MOC_PRECISION);
          maxBPro = await this.mocState.absoluteMaxBPro();
        });
        describe('WHEN he tries to redeem 11 BPros', function() {
          it('THEN he receives only the max redeem amount', async function() {
            await mocHelper.redeemBPro(from, 11, vendorAccount);

            const bproBalance = await mocHelper.getBProBalance(userAccount);
            const balanceDiff = initialBProBalance.sub(bproBalance);

            mocHelper.assertBig(balanceDiff, maxBPro, 'The redemption bpro amount was incorrect');
          });
        });
      });
      describe('WHEN he tries to redeem 20 BPros', function() {
        it('THEN he redeems all his BPros', async function() {
          await mocHelper.redeemBPro(from, 20, vendorAccount);

          const bproBalance = await mocHelper.getBProBalance(userAccount);
          mocHelper.assertBig(bproBalance, 0, 'The redemption bpro amount was incorrect');
        });
      });
      describe('WHEN he tries to redeem 6 BPros', function() {
        let txCost;
        beforeEach(async function() {
          const tx = await mocHelper.redeemBPro(from, 6, vendorAccount);
          txCost = await mocHelper.getTxCost(tx);
        });
        it('THEN he receives the corresponding amount of BTCs AND his BPro balance is 4', async function() {
          const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const balanceDiff = userPreBalance.sub(userBalance).sub(txCost);
          mocHelper.assertBigRBTC(balanceDiff, -6, 'Should increase by the equivalent BPros');
          const bproBalance = await mocHelper.getBProBalance(userAccount);
          mocHelper.assertBigRBTC(bproBalance, 5, 'Should be 11 - 6');
        });
        it('AND C0 Bucket BTC balance decreases by 6 BTCs', async function() {
          const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
          const diff = c0BTCBalance.sub(c0PrevBTCBalance);
          mocHelper.assertBigRBTC(diff, -6, 'C0 BTC amount should rise 10000 wei');
        });
        it('AND C0 Bucket BPro balance decreases by 6 BPro', async function() {
          const c0BProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
          const diff = c0BProBalance.sub(c0PrevBProBalance);
          mocHelper.assertBigRBTC(diff, -6, 'C0 BTC amount should rise 6 wei');
        });
      });
    });
  });

   */
});
