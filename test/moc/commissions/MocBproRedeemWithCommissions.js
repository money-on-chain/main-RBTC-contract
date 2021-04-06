const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";
const zeroAddress = '0x0000000000000000000000000000000000000000';

contract('MoC: MoCExchange', function([
  owner,
  userAccount,
  commissionsAccount,
  vendorAccount,
  otherAddress
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    this.mocToken = mocHelper.mocToken;
    this.mockMocStateChanger = mocHelper.mockMocStateChanger;
    this.mocVendors = mocHelper.mocVendors;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0.01, owner);

    // Commission rates for test are set in functionHelper.js
    await this.mockMocInrateChanger.setCommissionRates(
      await mocHelper.getCommissionsArrayNonZero()
    );

    // set commissions address
    await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('BPro redeeming with commissions', function() {
    const scenarios = [
      // RBTC fees
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 0,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproRedeemed: 100,
          // eslint-disable-next-line max-len
          bproToRedeemOnRBTC: 98.8, // (bproToRedeem) - (bproToRedeem * commissionRate) - (bproToRedeem * markup)
          commissionAmountRbtc: 0.2, // (bproToRedeem * REDEEM_BPRO_FEES_RBTC = 0.002)
          commissionAmountMoC: 0,
          vendorAmountRbtc: 1, // (bproToMint * markup = 0.01)
          vendorAmountMoC: 0
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 0,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0.1, // (bproToRedeem * REDEEM_BPRO_FEES_RBTC = 0.002)
          // eslint-disable-next-line max-len
          bproToRedeemOnRBTC: 49.4, // (bproToRedeem) - (bproToRedeem * commissionRate) - (bproToRedeem * markup)
          commissionAmountMoC: 0,
          vendorAmountRbtc: 0.5, // (bproToRedeem * markup = 0.01)
          vendorAmountMoC: 0
        }
      },
      // MoC fees
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 100,
          commissionAmountRbtc: 0,
          commissionAmountMoC: 0.8, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 1 // (bproToRedeem * markup = 0.01)
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0,
          bproToRedeemOnRBTC: 50,
          commissionAmountMoC: 0.4, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0.5 // (bproToRedeem * markup = 0.01)
        }
      },
      // MoC fees NO VENDOR
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount: zeroAddress
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 100,
          commissionAmountRbtc: 0,
          commissionAmountMoC: 0.8, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount: zeroAddress
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0,
          bproToRedeemOnRBTC: 50,
          commissionAmountMoC: 0.4, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0
        }
      }
    ];

    scenarios.forEach(async scenario => {
      describe(`WHEN he tries to redeem ${scenario.params.bproToRedeem} BPros`, function() {
        let initialBProBalance;
        let prevCommissionAccountBalance;
        let prevUserBtcBalance;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountBtcBalance;
        let prevVendorAccountMoCBalance;
        let tx;
        let txCost;

        beforeEach(async function() {
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
          const txTypeMint =
            scenario.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          await mocHelper.mintBProAmount(
            userAccount,
            scenario.params.bproToMint,
            scenario.params.vendorAccount,
            txTypeMint
          );
          // Calculate balances before redeeming
          initialBProBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(scenario.params.vendorAccount)
          );
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(
            scenario.params.vendorAccount
          );

          tx = await mocHelper.redeemBPro(
            userAccount,
            scenario.params.bproToRedeem,
            scenario.params.vendorAccount
          );
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });

        it(`THEN the user has ${scenario.expect.bproToRedeemOnRBTC} more rbtc`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = userBtcBalance.sub(prevUserBtcBalance).add(txCost);

          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToRedeemOnRBTC,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN he receives only the max redeem amount', async function() {
          const bproBalance = await mocHelper.getBProBalance(userAccount);
          const balanceDiff = initialBProBalance.sub(bproBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.bproRedeemed,
            'The redemption bpro amount was incorrect'
          );
        });
        it(`THEN commission account balance increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const balanceDiff = btcBalance.sub(prevCommissionAccountBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.commissionAmountRbtc,
            'The commission account balance is incorrect'
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
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
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

    describe('Non-scenario tests', function() {
      beforeEach(async function() {
        // MoC token for vendor
        const vendorStaking = 100;
        await mocHelper.mintMoCToken(vendorAccount, vendorStaking, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, vendorStaking, vendorAccount);
        await this.mocVendors.addStake(toContractBN(vendorStaking * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });
      });
      describe('GIVEN since there is no allowance to pay fees in MoC', function() {
        it('WHEN a user tries to redeem BPros with no MoC allowance, THEN fees are paid in RBTC', async function() {
          const mocAmountToMint = 1000;
          const mocAmountToApprove = 0;
          const rbtcExpectedBalance = 0;
          await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
          const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const tx = await mocHelper.redeemBPro(userAccount, 10, vendorAccount);
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
        it('WHEN a user tries to redeem BPros with MoC allowance, THEN fees are paid in RBTC', async function() {
          // DO NOT mint MoC token on purpose
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
          const expectedMoCFees = 0; // commission + vendor fee
          const mintAmount = 100;
          const redeemAmount = 100;
          const expectedRbtcCommission = 0.2; // redeemAmount * REDEEM_BPRO_FEES_RBTC()
          const expectedRbtcVendorFee = 1; // redeemAmount * markup

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
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
          await mocHelper.redeemBPro(otherAddress, redeemAmount, vendorAccount);

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
        it('WHEN a user tries to redeem BPros, THEN expect exception', async function() {
          const password = '!@superpassword';
          const failingAddress = await web3.eth.personal.newAccount(password);
          await web3.eth.personal.unlockAccount(failingAddress, password, 600);
          // User does not have BPro to redeem

          try {
            await mocHelper.mintMoCToken(failingAddress, 0, owner);
            await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
            const tx = await mocHelper.redeemBPro(failingAddress, 10, vendorAccount);
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
        it('WHEN a user tries to redeem BPros, THEN fees are paid in RBTC', async function() {
          const mocTokenAddress = this.mocToken.address;

          // Set MoCToken address to 0
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await this.governor.executeChange(mocHelper.mockMocStateChanger.address);

          const expectedMoCFees = 0; // commission + markup
          const mintAmount = 100;
          const redeemAmount = 100;
          const expectedRbtcCommission = 0.2; // redeemAmount * REDEEM_BPRO_FEES_RBTC()
          const expectedRbtcVendorFee = 1; // redeemAmount * markup

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
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
          await mocHelper.redeemBPro(otherAddress, redeemAmount, vendorAccount);

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
        let prevCommissionAccountBalance;
        let usedGas;
        let prevUserMoCBalance;
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountBtcBalance;
        let prevVendorAccountMoCBalance;

        const mocPrice = 5000;
        const bproToMint = 1000;
        const bproToRedeem = 1000;
        const bproToRedeemOnRbtc = 1000;
        const commissionAmountRbtc = 0;
        const vendorAmountRbtc = 0;
        const commissionAmountMoC = 16;
        const vendorAmountMoC = 20;
        const mocAmount = 1000;

        beforeEach(async function() {
          // Set MoC price
          await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, mocAmount, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmount, userAccount);

          // Mint
          const txTypeMint = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          await mocHelper.mintBProAmount(userAccount, bproToMint, vendorAccount, txTypeMint);

          // Calculate balances before redeeming
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);

          const redeemTx = await mocHelper.redeemBPro(userAccount, bproToRedeem, vendorAccount);
          usedGas = toContractBN(await mocHelper.getTxCost(redeemTx));
        });
        describe('WHEN user tries to redeem BPros and fees are paid in MoC', function() {
          it(`THEN the user has ${bproToRedeemOnRbtc} more rbtc`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const diff = userBtcBalance.sub(prevUserBtcBalance).add(usedGas);

            mocHelper.assertBigRBTC(diff, bproToRedeemOnRbtc, 'user rbtc balance is incorrect');
          });
          it(`THEN commission account balance increase by ${commissionAmountRbtc} Rbtcs`, async function() {
            const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
            const balanceDiff = btcBalance.sub(prevCommissionAccountBalance);

            mocHelper.assertBigRBTC(
              balanceDiff,
              commissionAmountRbtc,
              'The commission account balance is incorrect'
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
