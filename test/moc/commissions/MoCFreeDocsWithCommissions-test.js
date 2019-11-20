const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

// TODO: test free docs redeems with interests
contract('MoC', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
  });

  describe('Free Doc redeem with commissions and without interests', function() {
    describe('Redeem free docs', function() {
      const scenarios = [
        {
          // redeem 100 Docs when has 1000 free Docs
          params: {
            docsToMint: 1000,
            docsToRedeem: 100,
            commissionsRate: 0.2,
            bproToMint: 1
          },
          expect: {
            docsToRedeem: 100,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.008,
            commissionAddressBalance: 0.002
          }
        },
        {
          // Redeeming limited by free doc amount and user doc balance.
          params: {
            docsToMint: 500,
            docsToRedeem: 600,
            commissionsRate: 0.2,
            bproToMint: 1
          },
          expect: {
            docsToRedeem: 500,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.04,
            commissionAddressBalance: 0.01
          }
        }
      ];

      scenarios.forEach(async scenario => {
        describe(`GIVEN ${scenario.params.bproToMint} BitPro is minted and btc price is ${scenario.params.initialBtcPrice} usd`, function() {
          let prevUserBtcBalance;
          let prevUserDocBalance;
          let prevCommissionsAccountBtcBalance;
          let usedGas;
          beforeEach(async function() {
            await mocHelper.revertState();
            // this make the interests zero
            await this.mocState.setDaysToSettlement(0);
            // set commissions rate
            await mocHelper.mockMocInrateChanger.setCommissionRate(toContractBN(0.2, 'RAT'));
            // set commissions address
            await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
            // update params
            await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

            await mocHelper.mintBProAmount(owner, scenario.params.bproToMint);
            await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint);
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            prevUserDocBalance = toContractBN(await mocHelper.getDoCBalance(userAccount));
            prevCommissionsAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            const redeemTx = await this.moc.redeemFreeDoc(
              toContractBN(scenario.params.docsToRedeem * mocHelper.RESERVE_PRECISION),
              {
                from: userAccount
              }
            );
            usedGas = await mocHelper.getTxCost(redeemTx);
          });
          describe(`WHEN ${scenario.params.docsToMint} doc are redeeming`, function() {
            it(`THEN the user has ${scenario.expect.docsToRedeemOnRBTC} more rbtc`, async function() {
              const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
              const diff = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.docsToRedeemOnRBTC,
                'user rbtc balance is incorrect'
              );
            });
            it(`THEN the user docs balance decreased ${scenario.params.docsToRedeem} DOCs`, async function() {
              const userDocBalance = toContractBN(await mocHelper.getDoCBalance(userAccount));
              const diff = prevUserDocBalance.sub(userDocBalance);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.docsToRedeem,
                'user doc balance is incorrect'
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
