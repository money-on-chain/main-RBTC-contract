const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

const { BN } = web3.utils;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";

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
    this.mocToken = mocHelper.mocToken;
    this.mockMocStateChanger = mocHelper.mockMocStateChanger;
  });

  describe('BProx redeem with commissions and without interests', function() {
    describe('Redeem BProxs', function() {
      const scenarios = [
        // RBTC commission
        {
          // redeem 1 BProx
          params: {
            docsToMint: 10000,
            bproxsToRedeem: 1,
            commissionRate: 0.006,
            bproxToMint: 1,
            bproToMint: 100,
            mocAmount: 0
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 0.994,
            commissionAddressBalance: 0.006,
            commissionsOnRBTC: 0.006, // (REDEEM_BTCX_FEES_RBTC = 0.006)
            commissionAmountMoC: 0,
            mocAmount: 0
          }
        },
        {
          // Redeeming limited by max available to redeem.
          params: {
            docsToMint: 50000,
            bproxsToRedeem: 50,
            commissionRate: 0.006,
            bproxToMint: 5,
            bproToMint: 100,
            mocAmount: 0
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 4.97,
            commissionAddressBalance: 0.03,
            commissionsOnRBTC: 0.03, // (REDEEM_BTCX_FEES_RBTC = 0.006)
            commissionAmountMoC: 0,
            mocAmount: 0
          }
        },
        // MoC commission
        {
          // redeem 1 BProx
          params: {
            docsToMint: 10000,
            bproxsToRedeem: 1,
            commissionRate: 0,
            bproxToMint: 1,
            bproToMint: 100,
            mocAmount: 1000
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 1,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.012, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            mocAmount: '999.268' // mocAmount - commissionAmountMoC - commissionMintBpro (0.7) - commissionMintDoc (0.009) - commissionMintBprox (0.011)
          }
        },
        {
          // Redeeming limited by max available to redeem.
          params: {
            docsToMint: 50000,
            bproxsToRedeem: 50,
            commissionRate: 0,
            bproxToMint: 5,
            bproToMint: 100,
            mocAmount: 1000
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 5,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.06, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            mocAmount: '999.14' // mocAmount - commissionAmountMoC - commissionMintBpro (0.7) - commissionMintDoc (0.045) - commissionMintBprox (0.055)
          }
        }
      ];

      scenarios.forEach(async scenario => {
        describe(`GIVEN ${scenario.params.bproToMint} BitPro and DOC is minted`, function() {
          let prevUserBtcBalance;
          let prevUserBproxBalance;
          let prevCommissionsAccountBtcBalance;
          let usedGas;
          let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
          let prevCommissionsAccountMoCBalance;

          beforeEach(async function() {
            await mocHelper.revertState();
            // this make the interests zero
            await this.mocState.setDaysToSettlement(0);

            // Commission rates for test are set in functionHelper.js
            await mocHelper.mockMocInrateChanger.setCommissionRates(
              await mocHelper.getCommissionsArrayNonZero()
            );

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
            const txTypeMintBPro =
              scenario.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
            const txTypeMintDoc =
              scenario.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
            const txTypeMintBtcx =
              scenario.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
            await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint, txTypeMintBPro);
            await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint, txTypeMintDoc);
            await mocHelper.mintBProxAmount(
              userAccount,
              BUCKET_X2,
              scenario.params.bproxToMint,
              txTypeMintBtcx
            );

            // Calculate balances before redeeming
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            prevUserBproxBalance = toContractBN(
              await mocHelper.getBProxBalance(BUCKET_X2, userAccount)
            );
            prevCommissionsAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
            prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);

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
            it(`THEN the user BProx balance decreased ${scenario.params.bproxsToRedeem} BPROXs`, async function() {
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
            it(`THEN commissions account increase balance by ${scenario.expect.commissionAddressBalance} RBTC`, async function() {
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
              const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(
                commissionsAccount
              );
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

    describe('Non-scenario tests', function() {
      beforeEach(async function() {
        await mocHelper.revertState();
        // this make the interests zero
        await this.mocState.setDaysToSettlement(0);

        // Commission rates for test are set in functionHelper.js
        await mocHelper.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayNonZero()
        );

        // set commissions address
        await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
        // update params
        await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
      });
      describe('GIVEN since there is no allowance to pay comission in MoC', function() {
        it('WHEN a user tries to redeem BProx with no MoC allowance, THEN commission is paid in RBTC', async function() {
          const mocAmountToMint = 1000;
          const mocAmountToApprove = 0;
          const rbtcExpectedBalance = 0;
          await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const tx = await this.moc.redeemBProx(
            BUCKET_X2,
            toContractBN(10 * mocHelper.RESERVE_PRECISION),
            {
              from: userAccount
            }
          );
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diffMoC = prevUserMoCBalance.sub(userMoCBalance);
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const usedGas = toContractBN(await mocHelper.getTxCost(tx));
          const diffRbtc = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);

          // Check that the used paid in RBTC because MoC allowance is 0
          mocHelper.assertBigRBTC(diffMoC, mocAmountToApprove, 'user MoC balance is incorrect');

          mocHelper.assertBigRBTC(diffRbtc, rbtcExpectedBalance, 'user RBTC balance is incorrect');
        });
      });
      describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
        it('WHEN a user tries to redeem BProx with MoC allowance, THEN commission is paid in RBTC', async function() {
          // DO NOT mint MoC token on purpose
          await mocHelper.mintMoCToken(userAccount, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, userAccount);

          const expectedMoCAmount = 0;
          const expectedMoCCommission = 0;
          const docsToMint = 10000;
          const bproxToMint = 1;
          const bproxsToRedeem = 1;
          const bproToMint = 100;
          // commission = bproxsToRedeem * REDEEM_BTCX_FEES_RBTC()
          const expectedRbtcCommission = 0.006;
          const expectedRbtcAmount = 0.994;

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
          await mocHelper.mintBProAmount(userAccount, bproToMint, txTypeMintBPro);
          await mocHelper.mintDocAmount(userAccount, docsToMint, txTypeMintDoc);
          await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, bproxToMint, txTypeMintBtcx);

          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(
            commissionsAccount
          );

          const redeemBprox = await this.moc.redeemBProx(
            BUCKET_X2,
            toContractBN(bproxsToRedeem * mocHelper.RESERVE_PRECISION),
            {
              from: userAccount
            }
          );
          const usedGas = toContractBN(await mocHelper.getTxCost(redeemBprox));

          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const diffMoCAmount = prevUserMoCBalance.sub(userMoCBalance);
          const diffMoCCommission = commissionsAccountMoCBalance.sub(
            prevCommissionsAccountMoCBalance
          );

          // RBTC commission
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diffRbtcCommission = commissionsAccountBtcBalance.sub(
            prevCommissionsAccountBtcBalance
          );
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diffRbtcAmount = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);

          mocHelper.assertBigRBTC(
            diffMoCAmount,
            expectedMoCAmount,
            'user MoC balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffMoCCommission,
            expectedMoCCommission,
            'MoC commission is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcAmount,
            expectedRbtcAmount,
            'user rbtc balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcCommission,
            expectedRbtcCommission,
            'commissions account balance is incorrect'
          );
        });
      });
      describe('GIVEN since the user does not have MoC nor BPro balance, but there is MoC allowance', function() {
        it('WHEN a user tries to redeem BProx, THEN expect exception', async function() {
          const password = '!@superpassword';
          const failingAddress = await web3.eth.personal.newAccount(password);
          await web3.eth.personal.unlockAccount(failingAddress, password, 600);
          // User does not have BPro to redeem

          try {
            await mocHelper.mintMoCToken(failingAddress, 0, owner);
            await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
            const tx = await this.moc.redeemBProx(
              BUCKET_X2,
              toContractBN(10 * mocHelper.RESERVE_PRECISION),
              {
                from: userAccount
              }
            );
            assert(tx === null, 'This should not happen');
          } catch (err) {
            assert(
              err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
              'Sender does not have enough funds'
            );
          }
        });
      });
      describe('GIVEN since the address of the MoCToken is 0x0', function() {
        it('WHEN a user tries to redeem BProx, THEN commission is paid in RBTC', async function() {
          const mocTokenAddress = this.mocToken.address;
          // Set MoCToken address to 0
          const zeroAddress = '0x0000000000000000000000000000000000000000';
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);

          const expectedMoCAmount = 0;
          const expectedMoCCommission = 0;
          const docsToMint = 10000;
          const bproxToMint = 1;
          const bproxsToRedeem = 1;
          const bproToMint = 100;
          // commission = bproxsToRedeem * REDEEM_BTCX_FEES_RBTC()
          const expectedRbtcCommission = 0.006;
          const expectedRbtcAmount = 0.994;

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
          await mocHelper.mintBProAmount(userAccount, bproToMint, txTypeMintBPro);
          await mocHelper.mintDocAmount(userAccount, docsToMint, txTypeMintDoc);
          await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, bproxToMint, txTypeMintBtcx);

          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(
            commissionsAccount
          );

          const redeemBprox = await this.moc.redeemBProx(
            BUCKET_X2,
            toContractBN(bproxsToRedeem * mocHelper.RESERVE_PRECISION),
            {
              from: userAccount
            }
          );

          const usedGas = toContractBN(await mocHelper.getTxCost(redeemBprox));

          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const diffMoCAmount = prevUserMoCBalance.sub(userMoCBalance);
          const diffMoCCommission = commissionsAccountMoCBalance.sub(
            prevCommissionsAccountMoCBalance
          );

          // RBTC commission
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diffRbtcCommission = commissionsAccountBtcBalance.sub(
            prevCommissionsAccountBtcBalance
          );
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diffRbtcAmount = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);

          // Set MoCToken address back to its original address
          await this.mockMocStateChanger.setMoCToken(mocTokenAddress);
          await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);

          mocHelper.assertBigRBTC(
            diffMoCAmount,
            expectedMoCAmount,
            'user MoC balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffMoCCommission,
            expectedMoCCommission,
            'MoC commission is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcAmount,
            expectedRbtcAmount,
            'user rbtc balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcCommission,
            expectedRbtcCommission,
            'commissions account balance is incorrect'
          );
        });
      });
      describe('GIVEN since the MoC price drops to 5000', function() {
        let prevUserBtcBalance;
        let prevUserBproxBalance;
        let prevCommissionsAccountBtcBalance;
        let usedGas;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;

        const mocPrice = 5000;
        const mocAmount = 1000;
        const bproToMint = 100;
        const docsToMint = 10000;
        const bproxToMint = 1;
        const bproxsToRedeem = 1;
        const bproxsToRedeemOnRBTC = 1;
        const commissionAddressBalance = 0;
        const commissionAmountMoC = 0.024;
        // eslint-disable-next-line max-len
        const mocAmountExpected = 998.536; // mocAmount - commissionAmountMoC - commissionMintBpro (1.4) - commissionMintDoc (0.018) - commissionMintBprox (0.022)

        beforeEach(async function() {
          await mocHelper.revertState();
          // this make the interests zero
          await this.mocState.setDaysToSettlement(0);

          // Commission rates for test are set in functionHelper.js
          await mocHelper.mockMocInrateChanger.setCommissionRates(
            await mocHelper.getCommissionsArrayNonZero()
          );

          // set commissions address
          await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
          // update params
          await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

          // Set MoC price
          await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, mocAmount, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmount, userAccount);

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
          await mocHelper.mintBProAmount(userAccount, bproToMint, txTypeMintBPro);
          await mocHelper.mintDocAmount(userAccount, docsToMint, txTypeMintDoc);
          await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, bproxToMint, txTypeMintBtcx);

          // Calculate balances before redeeming
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserBproxBalance = toContractBN(
            await mocHelper.getBProxBalance(BUCKET_X2, userAccount)
          );
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);

          const redeemTx = await this.moc.redeemBProx(
            BUCKET_X2,
            toContractBN(bproxsToRedeem * mocHelper.RESERVE_PRECISION),
            {
              from: userAccount
            }
          );
          usedGas = await mocHelper.getTxCost(redeemTx);
        });
        describe(`WHEN ${bproxsToRedeem} BProxs to redeeming`, function() {
          it(`THEN the user has ${bproxsToRedeemOnRBTC} more rbtc`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const diff = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);
            mocHelper.assertBigRBTC(diff, bproxsToRedeemOnRBTC, 'user rbtc balance is incorrect');
          });
          it(`THEN the user BProx balance decreased ${bproxsToRedeem} BPROXs`, async function() {
            const userBproxBalance = toContractBN(
              await mocHelper.getBProxBalance(BUCKET_X2, userAccount)
            );
            const diff = prevUserBproxBalance.sub(userBproxBalance);
            mocHelper.assertBigRBTC(diff, bproxsToRedeem, 'user Bprox balance is incorrect');
          });
          it(`THEN commissions account increase balance by ${commissionAddressBalance} RBTC`, async function() {
            const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
            const diff = btcBalance.sub(prevCommissionsAccountBtcBalance);
            mocHelper.assertBigRBTC(
              diff,
              commissionAddressBalance,
              `Balance does not increase by ${commissionAddressBalance} RBTC`
            );
          });
          it(`THEN the user MoC balance has decreased by ${commissionAmountMoC} MoCs by commissions`, async function() {
            const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
            const diffAmount = new BN(prevUserMoCBalance).sub(
              new BN(web3.utils.toWei(commissionAmountMoC.toString()))
            );
            const diffCommission = prevUserMoCBalance.sub(userMoCBalance);

            mocHelper.assertBigRBTC(diffAmount, mocAmountExpected, 'user MoC balance is incorrect');
            mocHelper.assertBigRBTC(
              diffCommission,
              commissionAmountMoC,
              'MoC commission is incorrect'
            );
          });
          it(`THEN the commissions account MoC balance has increased by ${commissionAmountMoC} MoCs`, async function() {
            const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
            const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);

            mocHelper.assertBigRBTC(
              diff,
              commissionAmountMoC,
              'commissions account MoC balance is incorrect'
            );
          });
        });
      });
    });
  });
});
