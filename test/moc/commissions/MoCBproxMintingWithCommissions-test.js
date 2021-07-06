const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";
const zeroAddress = '0x0000000000000000000000000000000000000000';

contract('MoC : MoCExchange', function([
  owner,
  userAccount,
  commissionsAccount,
  vendorAccount,
  otherAddress
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_X2 } = mocHelper);
    this.mocToken = mocHelper.mocToken;
    this.mockMocStateChanger = mocHelper.mockMocStateChanger;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0.01, owner);

    await this.mocState.setDaysToSettlement(toContractBN(0, 'DAY'));

    // Commission rates for test are set in functionHelper.js
    await this.mockMocInrateChanger.setCommissionRates(
      await mocHelper.getCommissionsArrayNonZero()
    );

    // set commissions address
    await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('BProx minting with commissions', function() {
    const scenarios = [
      // RBTC fees
      {
        params: {
          nBProx: 5,
          mocAmount: 0,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5.075',
          commission: {
            nBtc: '0.025' // (nBProx * MINT_BTCX_FEES_RBTC = 0.005)
          },
          commissionAmountMoC: 0,
          vendorAmountRbtc: 0.05, // (nBProx * markup = 0.01)
          vendorAmountMoC: 0
        }
      },
      {
        params: {
          nBProx: 10,
          mocAmount: 0,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8.12',
          commission: {
            nBtc: '0.04' // (nBProx * MINT_BTCX_FEES_RBTC = 0.005)
          },
          commissionAmountMoC: 0,
          vendorAmountRbtc: 0.08, // (nBProx * markup = 0.01)
          vendorAmountMoC: 0
        }
      },
      // MoC fees
      {
        params: {
          nBProx: 5,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.055', // (nBProx * MINT_BTCX_FEES_MOC = 0.011)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0.05 // (nBProx * markup = 0.01)
        }
      },
      {
        params: {
          nBProx: 10,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.088', // (nBProx * MINT_BTCX_FEES_MOC = 0.011)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0.08 // (nBProx * markup = 0.01)
        }
      },
      // MoC fees NO VENDOR
      {
        params: {
          nBProx: 5,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount: zeroAddress
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.055', // (nBProx * MINT_BTCX_FEES_MOC = 0.011)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0
        }
      },
      {
        params: {
          nBProx: 10,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount: zeroAddress
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.088', // (nBProx * MINT_BTCX_FEES_MOC = 0.011)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0
        }
      }
    ];

    describe('GIVEN the user have 18 BPro and 8000 DOCs and no interest is charged', function() {
      scenarios.forEach(async s => {
        describe(`WHEN a user sends BTC to mint ${s.params.nBProx} Bprox`, function() {
          let initialCommissionAccountBalance;
          let prevUserBtcBalance;
          let txCost;
          let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
          let prevCommissionsAccountMoCBalance;
          let prevVendorAccountBtcBalance;
          let prevVendorAccountMoCBalance;

          beforeEach(async function() {
            await mocHelper.mintMoCToken(userAccount, s.params.mocAmount, owner);
            await mocHelper.approveMoCToken(mocHelper.moc.address, s.params.mocAmount, userAccount);
            if (s.params.vendorAccount !== zeroAddress) {
              await mocHelper.mintMoCToken(s.params.vendorAccount, s.params.vendorStaking, owner);
              await mocHelper.approveMoCToken(
                this.mocVendors.address,
                s.params.vendorStaking,
                s.params.vendorAccount
              );
              await this.mocVendors.addStake(
                toContractBN(s.params.vendorStaking * mocHelper.MOC_PRECISION),
                { from: s.params.vendorAccount }
              );
            }
            // Mint according to scenario
            const txTypeMintBPro =
              s.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
            const txTypeMintDoc =
              s.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
            await mocHelper.mintBProAmount(userAccount, 18, s.params.vendorAccount, txTypeMintBPro);
            await mocHelper.mintDocAmount(
              userAccount,
              80000,
              s.params.vendorAccount,
              txTypeMintDoc
            );

            // Calculate balances before minting
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
            prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
            prevVendorAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(s.params.vendorAccount)
            );
            prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(s.params.vendorAccount);

            // Set transaction type according to scenario
            const txType =
              s.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();

            const tx = await mocHelper.mintBProxAmount(
              userAccount,
              BUCKET_X2,
              s.params.nBProx,
              s.params.vendorAccount,
              txType
            );
            txCost = toContractBN(await mocHelper.getTxCost(tx));
          });
          it(`THEN he receives ${s.expect.nBProx} Bprox`, async function() {
            const balance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);
            mocHelper.assertBigRBTC(balance, s.expect.nBProx, 'Bprox balance is incorrect');
          });
          it(`THEN the user rbtc balance has decrease by ${s.expect.nBtc} Rbtcs by Mint + ${s.expect.commission.nBtc} Rbtcs by commissions + ${s.expect.vendorAmountRbtc} Rbtcs by markup`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const diff = prevUserBtcBalance.sub(userBtcBalance).sub(txCost);

            mocHelper.assertBigRBTC(
              diff,
              s.expect.totalCostOnBtc,
              'user rbtc balance is incorrect'
            );
          });
          it('THEN the commissions accounts balance increase', async function() {
            const balance = toContractBN(await web3.eth.getBalance(commissionsAccount));
            const diff = balance.sub(initialCommissionAccountBalance);
            const expected = toContractBN(s.expect.commission.nBtc, 'BTC');
            mocHelper.assertBig(diff, expected, 'the commissions accounts balance is not correct');
          });
          it(`THEN the vendor account rbtc balance has increase by ${s.expect.vendorAmountRbtc} Rbtcs`, async function() {
            const vendorAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(s.params.vendorAccount)
            );
            const diff =
              s.params.vendorAccount === zeroAddress
                ? 0 // zero address gets fees for block and transactions in ganache
                : vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

            mocHelper.assertBigRBTC(
              diff,
              s.expect.vendorAmountRbtc,
              'vendor account balance is incorrect'
            );
          });
          it(`THEN the user MoC balance has decreased by ${s.expect.commissionAmountMoC} MoCs by commissions + ${s.expect.vendorAmountMoC} MoCs by vendor markup`, async function() {
            const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
            const fees = toContractBN(s.expect.commissionAmountMoC * mocHelper.MOC_PRECISION).add(
              toContractBN(s.expect.vendorAmountMoC * mocHelper.MOC_PRECISION)
            );
            const diffFees = prevUserMoCBalance.sub(userMoCBalance);

            mocHelper.assertBig(diffFees, fees, 'MoC fees are incorrect');
          });
          it(`THEN the commissions account MoC balance has increased by ${s.expect.commissionAmountMoC} MoCs`, async function() {
            const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
            const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);
            mocHelper.assertBigRBTC(
              diff,
              s.expect.commissionAmountMoC,
              'commissions account MoC balance is incorrect'
            );
          });
          it(`THEN the vendor account MoC balance has increased by ${s.expect.vendorAmountMoC} MoCs`, async function() {
            const vendorAccountMoCBalance = await mocHelper.getMoCBalance(s.params.vendorAccount);
            const diff = vendorAccountMoCBalance.sub(prevVendorAccountMoCBalance);
            mocHelper.assertBigRBTC(
              diff,
              s.expect.vendorAmountMoC,
              'vendor account MoC balance is incorrect'
            );
          });
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
      describe('GIVEN since the user sends not enough amount to pay fees in RBTC', function() {
        it('WHEN a user tries to mint BProx with 10 RBTCs and does not send to pay fees, THEN expect revert', async function() {
          await mocHelper.mintBProAmount(
            userAccount,
            18,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
          );
          await mocHelper.mintDoc(userAccount, 1000, vendorAccount);
          const mint = mocHelper.mintBProx(userAccount, BUCKET_X2, 8, vendorAccount, 8);
          await expectRevert(mint, 'amount is not enough');
        });
      });
      describe('GIVEN since there is no allowance to pay fees in MoC', function() {
        it('WHEN a user tries to mint BProx with no MoC allowance, THEN expect revert', async function() {
          await mocHelper.mintMoCToken(userAccount, 1000, owner);
          // DO NOT approve MoC token on purpose
          await mocHelper.mintBProAmount(
            userAccount,
            18,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
          );
          await mocHelper.mintDoc(userAccount, 1000, vendorAccount);
          const mint = mocHelper.mintBProx(userAccount, BUCKET_X2, 8, vendorAccount, 8);
          await expectRevert(mint, 'amount is not enough');
        });
      });
      describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
        it('WHEN a user tries to mint BProx with MoC allowance, THEN fees are paid in RBTC', async function() {
          // DO NOT mint MoC token on purpose
          await mocHelper.mintMoCToken(userAccount, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
          const expectedMoCFees = 0; // commission + vendor fee
          const mintBproAmount = 1;
          const mintDocAmount = 1000;
          const mintAmount = 0.1;
          const expectedRbtcCommission = 0.0005; // mintAmount * MINT_BTCX_FEES_RBTC()
          const expectedRbtcVendorFee = 0.001; // mintAmount * markup

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintBproAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
          );
          await mocHelper.mintDocAmount(
            otherAddress,
            mintDocAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
          );

          // Calculate balances before minting
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Mint
          await mocHelper.mintBProxAmount(
            otherAddress,
            BUCKET_X2,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC()
          );

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
      describe('GIVEN since the user does not have MoC nor RBTC balance, but there is MoC allowance', function() {
        it('WHEN a user tries to mint BProx, THEN expect exception', async function() {
          const password = '!@superpassword';
          const failingAddress = await web3.eth.personal.newAccount(password);
          await web3.eth.personal.unlockAccount(failingAddress, password, 600);

          try {
            await web3.eth.sendTransaction({
              from: owner,
              to: failingAddress,
              value: '10000000000000'
            });
            await mocHelper.mintMoCToken(failingAddress, 0, owner);
            await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
            const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
            const mint = await mocHelper.mintBProxAmount(
              failingAddress,
              BUCKET_X2,
              10,
              vendorAccount,
              txType
            );
            assert(mint === null, 'This should not happen');
          } catch (err) {
            assert(
              err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
              'Sender does not have enough funds'
            );
          }
        });
      });
      describe('GIVEN since the address of the MoCToken is 0x0', function() {
        it('WHEN a user tries to mint BProx, THEN fees are paid in RBTC', async function() {
          const mocTokenAddress = this.mocToken.address;

          // Set MoCToken address to 0
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await this.governor.executeChange(this.mockMocStateChanger.address);

          const expectedMoCFees = 0; // commission + vendor fee
          const mintBproAmount = 1;
          const mintDocAmount = 1000;
          const mintAmount = 0.1;
          const expectedRbtcCommission = 0.0005; // mintAmount * MINT_BTCX_FEES_RBTC()
          const expectedRbtcVendorFee = 0.001; // mintAmount * markup

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintBproAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
          );
          await mocHelper.mintDocAmount(
            otherAddress,
            mintDocAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
          );

          // Calculate balances before minting
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Mint
          await mocHelper.mintBProxAmount(
            otherAddress,
            BUCKET_X2,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC()
          );

          const userMoCBalance = await mocHelper.getMoCBalance(otherAddress);
          const diffMoCFees = prevUserMoCBalance.sub(userMoCBalance);

          const commissionsBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diffRbtcCommission = commissionsBalance.sub(prevCommissionAccountBalance);

          const vendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          const diffRbtcVendorFee = vendorAccountBtcBalance.sub(prevVendorAccountBtcBalance);

          // Set MoCToken address back to its original address
          await this.mockMocStateChanger.setMoCToken(mocTokenAddress);
          await this.governor.executeChange(this.mockMocStateChanger.address);

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
        let initialCommissionAccountBalance;
        let prevUserBtcBalance;
        let txCost;
        let prevUserMoCBalance;
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountBtcBalance;
        let prevVendorAccountMoCBalance;

        const mocPrice = 5000;
        const mocAmount = 1000;
        const bproAmount = 18;
        const docAmount = 80000;
        const nBProx = 5;
        const nBtc = 5;
        const commissionBtc = 0;
        const totalCostOnBtc = 5;
        const commissionAmountMoC = '0.11'; // btcPrice * (nBProx * MINT_BTCX_FEES_MOC) / mocPrice
        const vendorAmountRbtc = 0;
        const vendorAmountMoC = '0.1'; // btcPrice * (nBProx * markup) / mocPrice

        beforeEach(async function() {
          // Set MoC price
          await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, mocAmount, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmount, userAccount);

          // Mint
          const txTypeMintBPro = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          const txTypeMintDoc = await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
          await mocHelper.mintBProAmount(userAccount, bproAmount, vendorAccount, txTypeMintBPro);
          await mocHelper.mintDocAmount(userAccount, docAmount, vendorAccount, txTypeMintDoc);

          // Calculate balances before minting
          initialCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          initialCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);

          // Set transaction type
          const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();

          const tx = await mocHelper.mintBProxAmount(
            userAccount,
            BUCKET_X2,
            nBProx,
            vendorAccount,
            txType
          );
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it(`THEN he receives ${nBProx} Bprox`, async function() {
          const balance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);
          mocHelper.assertBigRBTC(balance, nBProx, 'Bprox balance is incorrect');
        });
        it(`THEN the user rbtc balance has decrease by ${nBtc} Rbtcs by Mint + ${commissionBtc} Rbtcs by commissions + ${vendorAmountRbtc} Rbtcs by vendor markup`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevUserBtcBalance.sub(userBtcBalance).sub(txCost);

          mocHelper.assertBigRBTC(diff, totalCostOnBtc, 'user rbtc balance is incorrect');
        });
        it('THEN the commissions accounts balance increase', async function() {
          const balance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diff = balance.sub(initialCommissionAccountBalance);
          const expected = toContractBN(commissionBtc, 'BTC');
          mocHelper.assertBig(diff, expected, 'the commissions accounts balance is not correct');
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
          mocHelper.assertBigRBTC(diff, vendorAmountMoC, 'vendor account MoC balance is incorrect');
        });
      });
    });
  });
});
