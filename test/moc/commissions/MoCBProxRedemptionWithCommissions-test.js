const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
// TODO: test BProx redeems with interests
contract('MoC', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    ({ BUCKET_X2 } = mocHelper);
  });

  describe('BProx redeem with commissions and without interests', function() {
    describe('Redeem BProxs', function() {
      const scenarios = [
        {
          // redeem 1 BProx
          params: {
            docsToMint: 10000,
            bproxsToRedeem: 1,
            commissionRate: 0.002,
            bproxToMint: 1,
            bproToMint: 100
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 0.998,
            commissionAddressBalance: 0.002,
            commissionsOnRBTC: 0.002
          }
        },
        {
          // Redeeming limited by max available to redeem.
          params: {
            docsToMint: 50000,
            bproxsToRedeem: 50,
            commissionRate: 0.002,
            bproxToMint: 5,
            bproToMint: 100
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 4.99,
            commissionAddressBalance: 0.01,
            commissionsOnRBTC: 0.01
          }
        }
      ];

      scenarios.forEach(async scenario => {
        describe(`GIVEN ${scenario.params.bproToMint} BitPro and DOC is minted`, function() {
          let prevUserBtcBalance;
          let prevUserBproxBalance;
          let prevCommissionsAccountBtcBalance;
          let usedGas;
          beforeEach(async function() {
            await mocHelper.revertState();
            // this make the interests zero
            await this.mocState.setDaysToSettlement(0);
            // set commissions rate
            await mocHelper.mockMocInrateChanger.setCommissionRate(toContractBN(0.002, 'RAT'));
            await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
            // update params
            await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

            // set commissions address

            await mocHelper.mintBProAmount(owner, scenario.params.bproToMint);
            await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint);
            await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, scenario.params.bproxToMint);
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            prevUserBproxBalance = toContractBN(
              await mocHelper.getBProxBalance(BUCKET_X2, userAccount)
            );
            prevCommissionsAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            const redeemTx = await this.moc.redeemBProx(
              BUCKET_X2,
              toContractBN(scenario.params.bproxsToRedeem * mocHelper.RESERVE_PRECISION),
              {
                from: userAccount
              }
            );
            usedGas = await mocHelper.getTxCost(redeemTx);
          });
          describe(`WHEN ${scenario.params.bproxsToRedeem} BProxs to redeeming`, function() {
            it(`THEN the user has ${scenario.expect.bproxsToRedeemOnRBTC} more rbtc`, async function() {
              const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
              const diff = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.bproxsToRedeemOnRBTC,
                'user rbtc balance is incorrect'
              );
            });
            it(`THEN the user BPox balance decreased ${scenario.params.bproxsToRedeem} BPROXs`, async function() {
              const userBproxBalance = toContractBN(
                await mocHelper.getBProxBalance(BUCKET_X2, userAccount)
              );
              const diff = prevUserBproxBalance.sub(userBproxBalance);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.bproxsToRedeem,
                'user Bprox balance is incorrect'
              );
            });
            it(`AND commissions account increase balance by ${scenario.expect.commissionAddressBalance} RBTC`, async function() {
              const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
              const diff = btcBalance.sub(prevCommissionsAccountBtcBalance);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.commissionAddressBalance,
                `Balance does not increase by ${scenario.expect.commissionAddressBalance} RBTC`
              );
            });
          });
        });
      });
    });
  });
});
