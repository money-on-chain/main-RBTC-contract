const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";
const zeroAddress = '0x0000000000000000000000000000000000000000';

// TODO: test BProx redeems with interests
contract('MoC', function([owner, userAccount, commissionsAccount, vendorAccount, otherAddress]) {
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
    this.mocVendors = mocHelper.mocVendors;
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
            mocAmount: 0,
            vendorStaking: 100,
            vendorAccount
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 0.984,
            commissionAddressBalance: 0.006,
            commissionsOnRBTC: 0.006, // (REDEEM_BTCX_FEES_RBTC = 0.006)
            commissionAmountMoC: 0,
            vendorAmountRbtc: 0.01, // (bproxsToRedeem * markup = 0.01)
            vendorAmountMoC: 0
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
            mocAmount: 0,
            vendorStaking: 100,
            vendorAccount
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 4.92,
            commissionAddressBalance: 0.03,
            commissionsOnRBTC: 0.03, // (REDEEM_BTCX_FEES_RBTC = 0.006)
            commissionAmountMoC: 0,
            vendorAmountRbtc: 0.05, // (bproxsToRedeem * markup = 0.01)
            vendorAmountMoC: 0
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
            mocAmount: 1000,
            vendorStaking: 100,
            vendorAccount
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 1,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.012, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            vendorAmountRbtc: 0,
            vendorAmountMoC: 0.01 // (bproxsToRedeem * markup = 0.01)
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
            mocAmount: 1000,
            vendorStaking: 100,
            vendorAccount
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 5,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.06, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            vendorAmountRbtc: 0,
            vendorAmountMoC: 0.05 // (bproxsToRedeem * markup = 0.01)
          }
        },
        // MoC commission NO VENDOR
        {
          // redeem 1 BProx
          params: {
            docsToMint: 10000,
            bproxsToRedeem: 1,
            commissionRate: 0,
            bproxToMint: 1,
            bproToMint: 100,
            mocAmount: 1000,
            vendorStaking: 100,
            vendorAccount: zeroAddress
          },
          expect: {
            bproxsToRedeem: 1,
            bproxsToRedeemOnRBTC: 1,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.012, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            vendorAmountRbtc: 0,
            vendorAmountMoC: 0
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
            mocAmount: 1000,
            vendorStaking: 100,
            vendorAccount: zeroAddress
          },
          expect: {
            bproxsToRedeem: 5,
            bproxsToRedeemOnRBTC: 5,
            commissionAddressBalance: 0,
            commissionsOnRBTC: 0,
            commissionAmountMoC: 0.06, // (bproxsToRedeem * REDEEM_BTCX_FEES_MOC = 0.012)
            vendorAmountRbtc: 0,
            vendorAmountMoC: 0
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
          let prevVendorAccountBtcBalance;
          let prevVendorAccountMoCBalance;

          beforeEach(async function() {
            await mocHelper.revertState();

            // Register vendor for test
            await mocHelper.registerVendor(vendorAccount, 0.01, owner);

            // this make the interests zero
            await this.mocState.setDaysToSettlement(0);

            // Commission rates for test are set in functionHelper.js
            await this.mockMocInrateChanger.setCommissionRates(
              await mocHelper.getCommissionsArrayNonZero()
            );

            // set commissions address
            await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
            // update params
            await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);

            await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
            await mocHelper.approveMoCToken(
              mocHelper.moc.address,
              scenario.params.mocAmount,
              userAccount
            );
            if (scenario.params.vendorAccount !== zeroAddress) {
              await mocHelper.mintMoCToken(
                scenario.params.vendorAccount,
                scenario.params.vendorStaking,
                owner
              );
              await mocHelper.approveMoCToken(
                this.mocVendors.address,
                scenario.params.vendorStaking,
                scenario.params.vendorAccount
              );
              await this.mocVendors.addStake(
                toContractBN(scenario.params.vendorStaking * mocHelper.MOC_PRECISION),
                { from: scenario.params.vendorAccount }
              );
            }
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
            await mocHelper.mintBProAmount(
              userAccount,
              scenario.params.bproToMint,
              scenario.params.vendorAccount,
              txTypeMintBPro
            );
            await mocHelper.mintDocAmount(
              userAccount,
              scenario.params.docsToMint,
              scenario.params.vendorAccount,
              txTypeMintDoc
            );
            await mocHelper.mintBProxAmount(
              userAccount,
              BUCKET_X2,
              scenario.params.bproxToMint,
              scenario.params.vendorAccount,
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
            prevVendorAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(scenario.params.vendorAccount)
            );
            prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(
              scenario.params.vendorAccount
            );

            const redeemTx = await mocHelper.redeemBProx(
              userAccount,
              BUCKET_X2,
              scenario.params.bproxsToRedeem,
              scenario.params.vendorAccount
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
            it(`THEN the vendor account rbtc balance has increase by ${scenario.expect.vendorAmountRbtc} Rbtcs`, async function() {
              const vendorAccountBtcBalance = toContractBN(
                await web3.eth.getBalance(scenario.params.vendorAccount)
              );
              const diff =
                scenario.params.vendorAccount === zeroAddress
                  ? 0 // zero address gets fees for block and transactions in ganache
                  : vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.vendorAmountRbtc,
                'vendor account balance is incorrect'
              );
            });
            it(`THEN the user MoC balance has decreased by ${scenario.expect.commissionAmountMoC} MoCs by commissions + ${scenario.expect.vendorAmountMoC} MoCs by vendor markup`, async function() {
              const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
              const fees = toContractBN(
                scenario.expect.commissionAmountMoC * mocHelper.MOC_PRECISION
              ).add(toContractBN(scenario.expect.vendorAmountMoC * mocHelper.MOC_PRECISION));
              const diffFees = prevUserMoCBalance.sub(userMoCBalance);

              mocHelper.assertBig(diffFees, fees, 'MoC fees are incorrect');
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
            it(`THEN the vendor account MoC balance has increased by ${scenario.expect.vendorAmountMoC} MoCs`, async function() {
              const vendorAccountMoCBalance = await mocHelper.getMoCBalance(
                scenario.params.vendorAccount
              );
              const diff = vendorAccountMoCBalance.sub(prevVendorAccountMoCBalance);
              mocHelper.assertBigRBTC(
                diff,
                scenario.expect.vendorAmountMoC,
                'vendor account MoC balance is incorrect'
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

        // Register vendor for test
        await mocHelper.registerVendor(vendorAccount, 0.01, owner);

        // MoC token for vendor
        const vendorStaking = 100;
        await mocHelper.mintMoCToken(vendorAccount, vendorStaking, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, vendorStaking, vendorAccount);
        await this.mocVendors.addStake(toContractBN(vendorStaking * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });

        // Commission rates for test are set in functionHelper.js
        await this.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayNonZero()
        );

        // set commissions address
        await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
        // update params
        await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);
      });
      describe('GIVEN since there is no allowance to pay fees in MoC', function() {
        it('WHEN a user tries to redeem BProx with no MoC allowance, THEN fees are paid in RBTC', async function() {
          const mocAmountToMint = 1000;
          const mocAmountToApprove = 0;
          const rbtcExpectedBalance = 0;
          await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const tx = await mocHelper.redeemBProx(userAccount, BUCKET_X2, 10, vendorAccount);
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
        it('WHEN a user tries to redeem BProx with MoC allowance, THEN fees are paid in RBTC', async function() {
          // DO NOT mint MoC token on purpose
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
          const expectedMoCFees = 0; // commission + vendor fee
          const docsToMint = 10000;
          const bproxToMint = 1;
          const bproxsToRedeem = 1;
          const bproToMint = 100;
          const expectedRbtcCommission = 0.006; // bproxsToRedeem * REDEEM_BTCX_FEES_RBTC()
          const expectedRbtcVendorFee = 0.01; // bproxsToRedeem * markup

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
          await mocHelper.mintBProAmount(otherAddress, bproToMint, vendorAccount, txTypeMintBPro);
          await mocHelper.mintDocAmount(otherAddress, docsToMint, vendorAccount, txTypeMintDoc);
          await mocHelper.mintBProxAmount(
            otherAddress,
            BUCKET_X2,
            bproxToMint,
            vendorAccount,
            txTypeMintBtcx
          );

          // Calculate balances before redeeming
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Redeem
          await mocHelper.redeemBProx(otherAddress, BUCKET_X2, bproxsToRedeem, vendorAccount);

          const userMoCBalance = await mocHelper.getMoCBalance(otherAddress);
          const diffMoCFees = prevUserMoCBalance.sub(userMoCBalance);

          const commissionsBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diffRbtcCommission = commissionsBalance.sub(prevCommissionAccountBalance);

          const vendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          const diffRbtcVendorFee = vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

          mocHelper.assertBigRBTC(diffMoCFees, expectedMoCFees, 'MoC fees are incorrect');
          mocHelper.assertBigRBTC(
            diffRbtcCommission,
            expectedRbtcCommission,
            'commissions account balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcVendorFee,
            expectedRbtcVendorFee,
            'vendor account rbtc balance is incorrect'
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
            const tx = await mocHelper.redeemBProx(userAccount, BUCKET_X2, 10, vendorAccount);
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
        it('WHEN a user tries to redeem BProx, THEN fees are paid in RBTC', async function() {
          const mocTokenAddress = this.mocToken.address;

          // Set MoCToken address to 0
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await this.governor.executeChange(mocHelper.mockMocStateChanger.address);

          const expectedMoCFees = 0; // commission + vendor fee
          const docsToMint = 10000;
          const bproxToMint = 1;
          const bproxsToRedeem = 1;
          const bproToMint = 100;
          const expectedRbtcCommission = 0.006; // bproxsToRedeem * REDEEM_BTCX_FEES_RBTC()
          const expectedRbtcVendorFee = 0.01; // bproxsToRedeem * markup

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
          await mocHelper.mintBProAmount(otherAddress, bproToMint, vendorAccount, txTypeMintBPro);
          await mocHelper.mintDocAmount(otherAddress, docsToMint, vendorAccount, txTypeMintDoc);
          await mocHelper.mintBProxAmount(
            otherAddress,
            BUCKET_X2,
            bproxToMint,
            vendorAccount,
            txTypeMintBtcx
          );

          // Calculate balances before redeeming
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Redeem
          await mocHelper.redeemBProx(otherAddress, BUCKET_X2, bproxsToRedeem, vendorAccount);

          const userMoCBalance = await mocHelper.getMoCBalance(otherAddress);
          const diffMoCFees = prevUserMoCBalance.sub(userMoCBalance);

          const commissionsBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diffRbtcCommission = commissionsBalance.sub(prevCommissionAccountBalance);

          const vendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          const diffRbtcVendorFee = vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

          // Set MoCToken address back to its original address
          await this.mockMocStateChanger.setMoCToken(mocTokenAddress);
          await this.governor.executeChange(mocHelper.mockMocStateChanger.address);

          mocHelper.assertBigRBTC(diffMoCFees, expectedMoCFees, 'MoC fees are incorrect');
          mocHelper.assertBigRBTC(
            diffRbtcCommission,
            expectedRbtcCommission,
            'commissions account balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffRbtcVendorFee,
            expectedRbtcVendorFee,
            'vendor account rbtc balance is incorrect'
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
        let prevVendorAccountBtcBalance;
        let prevVendorAccountMoCBalance;

        const mocPrice = 5000;
        const mocAmount = 1000;
        const bproToMint = 100;
        const docsToMint = 10000;
        const bproxToMint = 1;
        const bproxsToRedeem = 1;
        const bproxsToRedeemOnRBTC = 1;
        const commissionAddressBalance = 0;
        const commissionAmountMoC = 0.024;
        const vendorAmountRbtc = 0;
        const vendorAmountMoC = 0.02;

        beforeEach(async function() {
          // Set MoC price
          await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, mocAmount, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmount, userAccount);

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
          const txTypeMintBtcx = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
          await mocHelper.mintBProAmount(userAccount, bproToMint, vendorAccount, txTypeMintBPro);
          await mocHelper.mintDocAmount(userAccount, docsToMint, vendorAccount, txTypeMintDoc);
          await mocHelper.mintBProxAmount(
            userAccount,
            BUCKET_X2,
            bproxToMint,
            vendorAccount,
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
          prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);

          const redeemTx = await mocHelper.redeemBProx(
            userAccount,
            BUCKET_X2,
            bproxsToRedeem,
            vendorAccount
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
          it(`THEN the vendor account rbtc balance has increase by ${vendorAmountRbtc} Rbtcs`, async function() {
            const vendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
            const diff = vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

            mocHelper.assertBigRBTC(diff, vendorAmountRbtc, 'vendor account balance is incorrect');
          });
          it(`THEN the user MoC balance has decreased by ${commissionAmountMoC} MoCs by commissions + ${vendorAmountMoC} MoCs by vendor markup`, async function() {
            const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
            const fees = toContractBN(commissionAmountMoC * mocHelper.MOC_PRECISION).add(
              toContractBN(vendorAmountMoC * mocHelper.MOC_PRECISION)
            );
            const diffFees = prevUserMoCBalance.sub(userMoCBalance);

            mocHelper.assertBig(diffFees, fees, 'MoC fees are incorrect');
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
          it(`THEN the vendor account MoC balance has increased by ${vendorAmountMoC} MoCs`, async function() {
            const vendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);
            const diff = vendorAccountMoCBalance.sub(prevVendorAccountMoCBalance);
            mocHelper.assertBigRBTC(
              diff,
              vendorAmountMoC,
              'vendor account MoC balance is incorrect'
            );
          });
        });
      });
    });
  });
});
