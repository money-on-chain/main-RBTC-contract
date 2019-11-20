const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

contract('MoC: MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
  });

  describe('BPro rediming with commissions', function() {
    const scenarios = [
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100
        },
        expect: {
          // (bproToMint * commissionRate = 0.002)
          bproRedeemed: 100,
          // (bproToRedeem) - (bproToRedeem * commissionRate)
          bproToRedeemOnRBTC: 99.8,
          commissionAmountRbtc: 0.2
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50
        },
        expect: {
          // (bproToMint * commissionRate = 0.002)
          bproRedeemed: 50,
          commissionAmountRbtc: 0.1,
          // (bproToRedeem) - (bproToRedeem * commissionRate)
          bproToRedeemOnRBTC: 49.9
        }
      }
    ];
    let initialBProBalance;
    let prevCommissionAccountBalance;
    let prevUserBtcBalance;
    scenarios.forEach(async scenario => {
      beforeEach(async function() {
        await mocHelper.revertState();
        // set commissions rate
        await mocHelper.mockMocInrateChanger.setCommissionRate(toContractBN(0.002, 'RAT'));
        // set commissions address
        await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
        // update params
        await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

        await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint);

        initialBProBalance = await mocHelper.getBProBalance(userAccount);
        prevCommissionAccountBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
        prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
      });

      describe(`WHEN he tries to redeem ${scenario.params.bproToRedeem} BPros`, function() {
        it(`THEN the user has ${scenario.expect.bproToRedeemOnRBTC} more rbtc`, async function() {
          const tx = await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);
          const txCost = toContractBN(await mocHelper.getTxCost(tx));

          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = userBtcBalance.sub(prevUserBtcBalance).add(txCost);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToRedeemOnRBTC,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN he receives only the max redeem amount', async function() {
          await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);

          const bproBalance = await mocHelper.getBProBalance(userAccount);
          const balanceDiff = initialBProBalance.sub(bproBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.bproRedeemed,
            'The redemption bpro amount was incorrect'
          );
        });
        it(`THEN commission account balance increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);

          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const balanceDiff = btcBalance.sub(prevCommissionAccountBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.commissionAmountRbtc,
            'The commission account balance is incorrect'
          );
        });
      });
    });
  });
});
