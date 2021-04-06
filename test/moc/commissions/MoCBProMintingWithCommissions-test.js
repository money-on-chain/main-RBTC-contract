const { assert } = require('chai');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
const { BN } = web3.utils;

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

  describe('BPro minting with commissions', function() {
    const scenarios = [
      // RBTC fees
      {
        params: {
          bproToMint: 1000,
          mocAmount: 0,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 1, // (bproToMint * MINT_BPRO_FEES_RBTC = 0.001)
          totalCostOnBtc: 1011,
          commissionAmountMoC: 0,
          vendorAmountRbtc: 10, // (bproToMint * markup = 0.01)
          vendorAmountMoC: 0
        }
      },
      // MoC fees
      {
        params: {
          bproToMint: 1000,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 0,
          totalCostOnBtc: 1000,
          commissionAmountMoC: 7, // (bproToMint * MINT_BPRO_FEES_MOC = 0.007)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 10 // (bproToMint * markup = 0.01)
        }
      },
      // MoC fees NO VENDOR
      {
        params: {
          bproToMint: 1000,
          mocAmount: 1000,
          vendorStaking: 100,
          vendorAccount: zeroAddress
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 0,
          totalCostOnBtc: 1000,
          commissionAmountMoC: 7, // (bproToMint * MINT_BPRO_FEES_MOC = 0.007)
          vendorAmountRbtc: 0,
          vendorAmountMoC: 0
        }
      }
    ];
    scenarios.forEach(async scenario => {
      describe(`GIVEN ${scenario.params.bproToMint} BitPro are minted and ${scenario.params.mocAmount} MoC are available in user account`, function() {
        let prevUserBtcBalance;
        let prevUserBproBalance;
        let prevCommissionsAccountBtcBalance;
        let prevMocBtcBalance;
        let usedGas;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountBtcBalance;
        let prevVendorAccountMoCBalance;

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
          // Set transaction type according to scenario
          const txType =
            scenario.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          // Calculate balances before minting
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserBproBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevMocBtcBalance = toContractBN(await web3.eth.getBalance(this.moc.address));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(scenario.params.vendorAccount)
          );
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(
            scenario.params.vendorAccount
          );

          const mintTx = await mocHelper.mintBProAmount(
            userAccount,
            scenario.params.bproToMint,
            scenario.params.vendorAccount,
            txType
          );
          usedGas = toContractBN(await mocHelper.getTxCost(mintTx));
        });
        it(`THEN the user has ${scenario.expect.bproToMint} more BitPros`, async function() {
          const UserBproBalance = await mocHelper.getBProBalance(userAccount);
          const diff = UserBproBalance.sub(prevUserBproBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMint,
            'user bitPro balance is incorrect'
          );
        });
        it(`THEN the user rbtc balance has decrease by ${scenario.expect.bproToMintOnRbtc} Rbtcs by Mint + ${scenario.expect.commissionAmountRbtc} Rbtcs by commissions + ${scenario.expect.vendorAmountRbtc} Rbtcs by vendor markup`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.totalCostOnBtc,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN global balance increases by the correct amount of BTCs', async function() {
          const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
          const diff = new BN(mocBtcBalance).sub(new BN(prevMocBtcBalance));
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMintOnRbtc,
            'Should increase sale total amount'
          );
        });
        it(`THEN the commissions account rbtc balance has increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diff = commissionsAccountBtcBalance.sub(prevCommissionsAccountBtcBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountRbtc,
            'commissions account balance is incorrect'
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
      describe('GIVEN since the user sends not enough amount to pay fees in RBTC', function() {
        it('WHEN a user tries to mint BPros with 10 RBTCs and does not send to pay fees, THEN expect revert', async function() {
          const mintBpro = mocHelper.mintBPro(userAccount, 10, vendorAccount);
          await expectRevert(mintBpro, 'amount is not enough');
        });
      });
      describe('GIVEN since there is no allowance to pay fees in MoC', function() {
        it('WHEN a user tries to mint BPros with no MoC allowance, THEN expect revert', async function() {
          await mocHelper.mintMoCToken(userAccount, 1000, owner);
          // DO NOT approve MoC token on purpose
          const mintBpro = mocHelper.mintBPro(userAccount, 10, vendorAccount);
          await expectRevert(mintBpro, 'amount is not enough');
        });
      });
      describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
        it('WHEN a user tries to mint BPros with MoC allowance, THEN fees are paid in RBTC', async function() {
          // DO NOT mint MoC token for user on purpose
          await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
          const expectedMoCFees = 0; // commission + vendor fee
          const mintAmount = 100;
          const expectedRbtcCommission = 0.1; // mintAmount * MINT_BPRO_FEES_RBTC()
          const expectedRbtcVendorFee = 1; // mintAmount * markup

          // Calculate balances before minting
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
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
        it('WHEN a user tries to mint BPros, THEN expect exception', async function() {
          const password = '!@superpassword';
          const failingAddress = await web3.eth.personal.newAccount(password);
          await web3.eth.personal.unlockAccount(failingAddress, password, 600);

          await web3.eth.sendTransaction({
            from: owner,
            to: failingAddress,
            value: '10000000000000'
          });
          try {
            await mocHelper.mintBPro(failingAddress, 10, vendorAccount);
            assert.fail('Minting BPro should have failed');
          } catch (err) {
            assert(
              err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
              'Sender does have enough funds'
            );
          }
        });
      });
      describe('GIVEN since the address of the MoCToken is 0x0', function() {
        it('WHEN a user tries to mint BPros, THEN fees are paid in RBTC', async function() {
          const mocTokenAddress = this.mocToken.address;

          // Set MoCToken address to 0
          await this.mockMocStateChanger.setMoCToken(zeroAddress);
          await this.governor.executeChange(mocHelper.mockMocStateChanger.address);

          const expectedMoCFees = 0; // commission + vendor fee
          const mintAmount = 100;
          const expectedRbtcCommission = 0.1; // mintAmount * MINT_BPRO_FEES_RBTC()
          const expectedRbtcVendorFee = 1;

          // Calculate balances before minting
          const prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const prevVendorAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(vendorAccount)
          );
          const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

          // Mint
          await mocHelper.mintBProAmount(
            otherAddress,
            mintAmount,
            vendorAccount,
            await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
          );

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
        let prevUserBproBalance;
        let prevCommissionsAccountBtcBalance;
        let prevVendorAccountBtcBalance;
        let usedGas;
        let prevUserMoCBalance;
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountMoCBalance;

        const mocPrice = 5000;
        const bproToMint = 1000;
        const bproToMintOnRbtc = 1000;
        const commissionAmountRbtc = 0;
        const vendorAmountRbtc = 0;
        const totalCostOnBtc = 1000;
        const commissionAmountMoC = 14; // btcPrice * (bproToMint * MINT_BPRO_FEES_MOC) / mocPrice
        const vendorAmountMoC = 20; // btcPrice * (bproToMint * markup) / mocPrice
        const mocAmount = 1000;

        beforeEach(async function() {
          // Set MoC price
          await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, mocAmount, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmount, userAccount);
          // Set transaction type
          const txType = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          // Calculate balances before minting
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserBproBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);

          const mintTx = await mocHelper.mintBProAmount(
            userAccount,
            bproToMint,
            vendorAccount,
            txType
          );
          usedGas = toContractBN(await mocHelper.getTxCost(mintTx));
        });
        describe('WHEN user tries to mint BPros and fees are paid in MoC', function() {
          it(`THEN the user has ${bproToMint} more BitPros`, async function() {
            const UserBproBalance = await mocHelper.getBProBalance(userAccount);
            const diff = UserBproBalance.sub(prevUserBproBalance);
            mocHelper.assertBigRBTC(diff, bproToMint, 'user bitPro balance is incorrect');
          });
          it(`THEN the user rbtc balance has decrease by ${bproToMintOnRbtc} Rbtcs by Mint + ${commissionAmountRbtc} Rbtcs by commissions + ${vendorAmountRbtc} Rbtcs by vendor markup`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const diff = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);
            mocHelper.assertBigRBTC(diff, totalCostOnBtc, 'user rbtc balance is incorrect');
          });
          it(`THEN the commissions account rbtc balance has increase by ${commissionAmountRbtc} Rbtcs`, async function() {
            const commissionsAccountBtcBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            const diff = commissionsAccountBtcBalance.sub(prevCommissionsAccountBtcBalance);
            mocHelper.assertBigRBTC(
              diff,
              commissionAmountRbtc,
              'commissions account balance is incorrect'
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
