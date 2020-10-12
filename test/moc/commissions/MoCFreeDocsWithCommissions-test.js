const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";

// TODO: test free docs redeems with interests
contract('MoC', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.mocToken = mocHelper.mocToken;
    this.mocConnector = mocHelper.mocConnector;
  });

  describe.only('Free Doc redeem with commissions and without interests', function() {
    describe('Redeem free docs', function() {
      const scenarios = [
        // RBTC commission
        {
          // redeem 100 Docs when has 1000 free Docs
          params: {
            docsToMint: 1000,
            docsToRedeem: 100,
            commissionsRate: 4, // REDEEM_DOC_FEES_RBTC = 0.004
            bproToMint: 1,
            mocAmount: 0,
            initialBtcPrice: 10000
          },
          expect: {
            docsToRedeem: 100,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.008,
            commissionAddressBalance: 0.002,
            commissionAmountMoC: 0,
            mocAmount: 0
          }
        },
        {
          // Redeeming limited by free doc amount and user doc balance.
          params: {
            docsToMint: 500,
            docsToRedeem: 600,
            commissionsRate: 0.2,
            bproToMint: 1,
            initialBtcPrice: 10000
          },
          expect: {
            docsToRedeem: 500,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.04,
            commissionAddressBalance: 0.01
          }
        },
        // MoC commission
        {
          // redeem 100 Docs when has 1000 free Docs
          params: {
            docsToMint: 1000,
            docsToRedeem: 100,
            commissionsRate: 0.2, //REDEEM_DOC_FEES_MOC
            bproToMint: 1,
            initialBtcPrice: 10000
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
            bproToMint: 1,
            initialBtcPrice: 10000
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
          let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
          let prevCommissionsAccountMoCBalance;

          beforeEach(async function() {
            await mocHelper.revertState();
            // this make the interests zero
            await this.mocState.setDaysToSettlement(0);

            // Commission rates are set in contractsBuilder.js

            // set commissions address
            await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
            // update params
            await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

            await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
            await mocHelper.approveMoCToken(
              mocHelper.moc.address,
              scenario.params.mocAmount,
              userAccount
            );
            // Mint according to scenario
            const txTypeMintBpro =
              scenario.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
              const txTypeMintDoc =
                scenario.params.mocAmount === 0
                  ? await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  : await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
            await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint, txTypeMintBpro);
            await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint, txTypeMintDoc);
            // Calculate balances before redeeming
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            prevUserDocBalance = toContractBN(await mocHelper.getDoCBalance(userAccount));
            prevCommissionsAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
            prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
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
            it(`THEN the user MoC balance has decreased by ${scenario.expect.commissionAmountMoC} MoCs by commissions`, async function() {
              const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
              const diffAmount = new BN(prevUserMoCBalance).sub(
                new BN(web3.utils.toWei(scenario.expect.commissionAmountMoC.toString()))
              );
              const diffCommission = prevUserMoCBalance.sub(userMoCBalance);

              mocHelper.assertBigRBTC(
                diffAmount,
                scenario.expect.mocAmount,
                'user MoC balance is incorrect'
              );
              mocHelper.assertBigRBTC(
                diffCommission,
                scenario.expect.commissionAmountMoC,
                'MoC commission is incorrect'
              );
            });
            it(`THEN the commissions account MoC balance has increased by ${scenario.expect.commissionAmountMoC} MoCs`, async function() {
              const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
              const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);

              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.commissionAmountMoC,
                'commissions account MoC balance is incorrect'
              );
            });
          });
        });
      });
    });
  });
});
