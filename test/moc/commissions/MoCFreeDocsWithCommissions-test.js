const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

const { BN } = web3.utils;

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
    this.mockMocStateChanger = mocHelper.mockMocStateChanger;
  });

  describe('Free Doc redeem with commissions and without interests', function() {
    describe('Redeem free docs', function() {
      const scenarios = [
        // RBTC commission
        {
          // redeem 100 Docs when has 1000 free Docs
          params: {
            docsToMint: 1000,
            docsToRedeem: 100,
            // commissionsRate: 4, // REDEEM_DOC_FEES_RBTC = 0.004
            bproToMint: 1,
            initialBtcPrice: 10000,
            mocAmount: 0
          },
          expect: {
            docsToRedeem: 100,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.00996,
            commissionAddressBalance: 0.00004,
            commissionAmountMoC: 0,
            mocAmount: 0
          }
        },
        {
          // Redeeming limited by free doc amount and user doc balance.
          params: {
            docsToMint: 500,
            docsToRedeem: 600,
            // commissionsRate: 0.2,
            bproToMint: 1,
            initialBtcPrice: 10000,
            mocAmount: 0
          },
          expect: {
            docsToRedeem: 500,
            // (docsToRedeem / btcPrice) - ((docsToRedeem / btcPrice) * commissionRate)
            docsToRedeemOnRBTC: 0.0498,
            commissionAddressBalance: 0.0002,
            commissionAmountMoC: 0,
            mocAmount: 0
          }
        },
        // MoC commission
        {
          // redeem 100 Docs when has 1000 free Docs
          params: {
            docsToMint: 1000,
            docsToRedeem: 100,
            // commissionsRate: 0,
            bproToMint: 1,
            initialBtcPrice: 10000,
            mocAmount: 1000
          },
          expect: {
            docsToRedeem: 100,
            docsToRedeemOnRBTC: 0.01,
            commissionAddressBalance: 0,
            // eslint-disable-next-line max-len
            commissionAmountMoC: 0.0001, // (btcPrice * docsToRedeemOnRBTC / mocPrice) * REDEEM_DOC_FEES_MOC = 0.01
            // eslint-disable-next-line max-len
            mocAmount: 999.992 // mocAmount - commissionAmountMoC - commissionMintBpro (0.007) - commissionMintDoc (0.0009)
          }
        },
        {
          // Redeeming limited by free doc amount and user doc balance.
          params: {
            docsToMint: 500,
            docsToRedeem: 600,
            // commissionsRate: 0,
            bproToMint: 1,
            initialBtcPrice: 10000,
            mocAmount: 1000
          },
          expect: {
            docsToRedeem: 500,
            docsToRedeemOnRBTC: 0.05,
            commissionAddressBalance: 0,
            // eslint-disable-next-line max-len
            commissionAmountMoC: 0.0005, // (btcPrice * docsToRedeemOnRBTC / mocPrice) * REDEEM_DOC_FEES_MOC = 0.01
            // eslint-disable-next-line max-len
            mocAmount: 999.99205 // mocAmount - commissionAmountMoC - commissionMintBpro (0.007) - commissionMintDoc (0.00045)
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
          describe(`WHEN ${scenario.params.docsToRedeem} doc are redeeming`, function() {
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
              const commissionWithPrecision =
                scenario.expect.commissionAmountMoC * mocHelper.MOC_PRECISION;
              const diffCommission = prevUserMoCBalance.sub(userMoCBalance);
              const diffAmount = prevUserMoCBalance.sub(
                toContractBN(commissionWithPrecision.toString())
              );

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
        it('WHEN a user tries to redeem DoC with no MoC allowance, THEN commission is paid in RBTC', async function() {
          const mocAmountToMint = 1000;
          const mocAmountToApprove = 0;
          const rbtcExpectedBalance = 0;
          await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const tx = await mocHelper.redeemFreeDoc({ userAccount, docAmount: 10 });
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
        it('WHEN a user tries to redeem DoC with MoC allowance, THEN commission is paid in RBTC', async function() {
          const accounts = await web3.eth.getAccounts();
          const otherAddress = accounts[1];
          // DO NOT mint MoC token on purpose
          await mocHelper.mintMoCToken(userAccount, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
          // eslint-disable-next-line max-len
          const prevUserMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress); // No MoC balance
          const expectedMoCAmount = 0;
          const expectedMoCCommission = 0;
          const mintBproAmount = 1;
          const mintAmount = 1000;
          const redeemAmount = 100;
          // eslint-disable-next-line max-len
          // commission = mintBproAmount * MINT_BPRO_FEES_RBTC() + mintAmount * MINT_DOC_FEES_RBTC()  + redeemAmount * REDEEM_DOC_FEES_RBTC()
          const expectedRbtcCommission = 0.00134;
          const prevUserBtcBalanceOtherAddress = toContractBN(
            await web3.eth.getBalance(otherAddress)
          );
          // eslint-disable-next-line max-len
          // total cost = mintBproAmount + mintAmount / btcPrice - redeemAmount / btcPrice + expectedRbtcCommission
          const expectedRbtcAmount = 1.09 + expectedRbtcCommission;
          const prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );

          // Mint
          const txTypeMintBpro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const mintBpro = await mocHelper.mintBProAmount(
            otherAddress,
            mintBproAmount,
            txTypeMintBpro
          );
          const mintDoc = await mocHelper.mintDocAmount(otherAddress, mintAmount, txTypeMintDoc);

          const redeem = await mocHelper.redeemFreeDoc({
            userAccount: otherAddress,
            docAmount: redeemAmount
          });
          const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro)).add(
            toContractBN(await mocHelper.getTxCost(mintDoc)).add(
              toContractBN(await mocHelper.getTxCost(redeem))
            )
          );

          const userMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress);
          const diffMoCAmount = prevUserMoCBalanceOtherAddress.sub(new BN(expectedMoCCommission));
          const diffMoCCommission = prevUserMoCBalanceOtherAddress.sub(userMoCBalanceOtherAddress);

          // RBTC commission
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diffRbtcCommission = commissionsAccountBtcBalance.sub(
            prevCommissionsAccountBtcBalance
          );
          const userBtcBalanceOtherAccount = toContractBN(await web3.eth.getBalance(otherAddress));
          const diffRbtcAmount = prevUserBtcBalanceOtherAddress
            .sub(userBtcBalanceOtherAccount)
            .sub(usedGas);

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
      describe('GIVEN since the user does not have MoC nor DoC balance, but there is MoC allowance', function() {
        it('WHEN a user tries to redeem DoC, THEN expect exception', async function() {
          const password = '!@superpassword';
          const failingAddress = await web3.eth.personal.newAccount(password);
          await web3.eth.personal.unlockAccount(failingAddress, password, 600);
          // User does not have DoC to redeem

          try {
            await mocHelper.mintMoCToken(failingAddress, 0, owner);
            await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
            const tx = await mocHelper.redeemFreeDoc({
              userAccount: failingAddress,
              docAmount: 10
            });
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
        it('WHEN a user tries to redeem DoC, THEN commission is paid in RBTC', async function() {
          const accounts = await web3.eth.getAccounts();
          const otherAddress = accounts[1];
          const mocTokenAddress = this.mocToken.address;
          // Set MoCToken address to 0
          const zeroAddress = '0x0000000000000000000000000000000000000000';
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
          // eslint-disable-next-line max-len
          const prevUserMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress); // No MoC balance
          const expectedMoCAmount = 0;
          const expectedMoCCommission = 0;
          const mintBproAmount = 1;
          const mintAmount = 1000;
          const redeemAmount = 100;
          // eslint-disable-next-line max-len
          // commission = mintBproAmount * MINT_BPRO_FEES_RBTC() + mintAmount * MINT_DOC_FEES_RBTC()  + redeemAmount * REDEEM_DOC_FEES_RBTC()
          const expectedRbtcCommission = 0.00134;
          // eslint-disable-next-line max-len
          // const expectedRbtcCommissionWithPrecision = expectedRbtcCommission * mocHelper.MOC_PRECISION;
          const prevUserBtcBalanceOtherAddress = toContractBN(
            await web3.eth.getBalance(otherAddress)
          );
          // eslint-disable-next-line max-len
          // total cost = mintBproAmount + mintAmount / btcPrice - redeemAmount / btcPrice + expectedRbtcCommission
          const expectedRbtcAmount = 1.09 + expectedRbtcCommission;
          const prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );

          // Mint
          const txTypeMintBpro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const mintBpro = await mocHelper.mintBProAmount(
            otherAddress,
            mintBproAmount,
            txTypeMintBpro
          );
          const mintDoc = await mocHelper.mintDocAmount(otherAddress, mintAmount, txTypeMintDoc);

          const redeem = await mocHelper.redeemFreeDoc({
            userAccount: otherAddress,
            docAmount: redeemAmount
          });
          const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro)).add(
            toContractBN(await mocHelper.getTxCost(mintDoc)).add(
              toContractBN(await mocHelper.getTxCost(redeem))
            )
          );

          const userMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress);
          const diffMoCAmount = prevUserMoCBalanceOtherAddress.sub(new BN(expectedMoCCommission));
          const diffMoCCommission = prevUserMoCBalanceOtherAddress.sub(userMoCBalanceOtherAddress);

          // RBTC commission
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diffRbtcCommission = commissionsAccountBtcBalance.sub(
            prevCommissionsAccountBtcBalance
          );
          const userBtcBalanceOtherAccount = toContractBN(await web3.eth.getBalance(otherAddress));
          const diffRbtcAmount = prevUserBtcBalanceOtherAddress
            .sub(userBtcBalanceOtherAccount)
            .sub(usedGas);

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
    });
  });
});
