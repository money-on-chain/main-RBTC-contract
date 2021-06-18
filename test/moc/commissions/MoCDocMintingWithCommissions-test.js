const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
const { BN } = web3.utils;
// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";
const zeroAddress = '0x0000000000000000000000000000000000000000';

contract('MoC', function([owner, userAccount, commissionsAccount, vendorAccount, otherAddress]) {
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

  describe('Doc minting paying Commissions', function() {
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

    // RBTC fees
    describe('(RBTC fees) GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        // Add vendor stake
        await mocHelper.mintMoCToken(vendorAccount, 100, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
        await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });

        await mocHelper.mintBProAmount(
          userAccount,
          1,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
      });
      describe('WHEN a user tries to mint 10000 Docs using RBTC fees', function() {
        let prevBtcBalance;
        let prevCommissionsAccountBtcBalance;
        let prevVendorAccountBtcBalance;
        let txCost;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));

          const tx = await mocHelper.mintDocAmount(
            userAccount,
            10000,
            vendorAccount,
            await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
          );

          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('AND only spent 0.5 BTC + 0.0015 RBTC commission + 0.005 RBTC markup', async function() {
          // commission = 5000 * 0.003; markup = 5000 * 0.01
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));

          mocHelper.assertBig(
            diff,
            '506500000000000000',
            'Balance does not decrease by 0.5 RBTC + 0.0015 RBTC commission + 0.005 RBTC markup'
          );
        });
        it('AND User only spent on fees for 0.0015 RBTC commission + 0.005 RBTC markup', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance
            .sub(toContractBN(btcBalance))
            .sub(new BN(txCost))
            .sub(toContractBN(500000000000000000));

          mocHelper.assertBig(
            diff,
            '6500000000000000',
            'Should decrease by fees cost, 6500000000000000 BTC'
          );
        });
        it('AND commissions account increase balance by 0.0015 RBTC', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diff = btcBalance.sub(toContractBN(prevCommissionsAccountBtcBalance));
          mocHelper.assertBig(diff, '1500000000000000', 'Balance does not increase by 0.0015 RBTC');
        });
        it('AND vendors account increase balance by 0.005 RBTC', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
          const diff = btcBalance.sub(toContractBN(prevVendorAccountBtcBalance));
          mocHelper.assertBig(diff, '5000000000000000', 'Balance does not increase by 0.005 RBTC');
        });
      });
    });

    describe('(RBTC fees) GIVEN BTC price is 10000', function() {
      let payAmount;
      let payComissionAmount;
      let payMarkupAmount;
      const btcPrice = 10000;
      [0, 10000].forEach(async nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [
            { docAmount: 1300, commissionAmount: 3.9, markupAmount: 13 }, // commission = 1300 * 0.003, markup = 1300 * 0.01
            { docAmount: 1200, commissionAmount: 3.6, markupAmount: 12 } // commission = 1200 * 0.003 = 30, markup = 1200 * 0.01
          ].forEach(async ({ docAmount, commissionAmount, markupAmount }) => {
            describe(`WHEN he tries to mint ${docAmount} RBTC`, function() {
              const prev = {};
              let txCost;
              beforeEach(async function() {
                // Load Btc on the contract to increase coverage
                await this.moc.sendTransaction({
                  value: 6 * mocHelper.RESERVE_PRECISION
                });

                // Add vendor stake
                await mocHelper.mintMoCToken(vendorAccount, 100, owner);
                await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
                await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
                  from: vendorAccount
                });

                if (nDocs) {
                  await mocHelper.mintDocAmount(
                    owner,
                    nDocs,
                    vendorAccount,
                    await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  );
                }
                [
                  prev.userBalance,
                  prev.commissionsAccountBalance,
                  prev.mocBalance,
                  prev.vendorAccountBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(commissionsAccount),
                  web3.eth.getBalance(this.moc.address),
                  web3.eth.getBalance(vendorAccount)
                ]);

                const tx = await mocHelper.mintDocAmount(
                  userAccount,
                  docAmount,
                  vendorAccount,
                  await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                );
                const _payAmount = (docAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = (commissionAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payComissionAmount = toContractBN(_payComissionAmount);
                const _payMarkupAmount = (markupAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payMarkupAmount = toContractBN(_payMarkupAmount);

                txCost = await mocHelper.getTxCost(tx);
              });

              // Docs received should be the dollar value of the total BTC sent
              it(`THEN he receives ${docAmount} Docs on his account`, async function() {
                const balance = await mocHelper.getDoCBalance(userAccount);

                mocHelper.assertBigDollar(
                  balance,
                  docAmount,
                  `${docAmount} was not in the first account`
                );
              });

              it('THEN global balance increases by the correct amount of BTCs', async function() {
                const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
                const diff = new BN(mocBtcBalance).sub(new BN(prev.mocBalance));

                mocHelper.assertBig(diff, payAmount, 'Should increase sale total amount');
              });

              it('AND User Balance decreases by the correct amount of BTCs, commission and markup', async function() {
                const userBalance = await web3.eth.getBalance(userAccount);
                const diff = new BN(prev.userBalance).sub(new BN(userBalance)).sub(new BN(txCost));
                const totalSpent = payAmount.add(payComissionAmount).add(payMarkupAmount);

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} BTC`
                );
              });
              it('AND Commissions Account Balance increase by the correct amount of commissions', async function() {
                const commissionsAccountBalance = await web3.eth.getBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountBalance)
                );
                mocHelper.assertBig(
                  diff,
                  payComissionAmount,
                  `Should increase by Tokens commission, ${payComissionAmount} BTC`
                );
              });
              it('AND Vendor Account Balance increase by the correct amount of markup', async function() {
                const vendorAccountBalance = await web3.eth.getBalance(vendorAccount);
                const diff = new BN(vendorAccountBalance).sub(new BN(prev.vendorAccountBalance));
                mocHelper.assertBig(
                  diff,
                  payMarkupAmount,
                  `Should increase by Tokens commission, ${payMarkupAmount} BTC`
                );
              });
            });
          });
        });
      });
    });

    // MoC fees
    describe('(MoC fees) GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        await mocHelper.mintMoCToken(userAccount, 100, owner);
        await mocHelper.approveMoCToken(mocHelper.moc.address, 100, userAccount);

        // Add vendor stake
        await mocHelper.mintMoCToken(vendorAccount, 100, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
        await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });

        await mocHelper.mintBProAmount(
          userAccount,
          1,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_MOC()
        );
      });
      describe('WHEN a user tries to mint 10000 Docs using MoC commission', function() {
        let prevBtcBalance;
        let txCost;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountMoCBalance;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);

          const tx = await mocHelper.mintDocAmount(
            userAccount,
            10000,
            vendorAccount,
            await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
          );
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('AND only spent 0.5 BTC + 0.0045 MoC commission + 0.005 MoC markup', async function() {
          // commission = 5000 * 0.009, markup = 5000 * 0.01
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));
          // const expectedMoCCommission = '4500000000000000';
          // const expectedMoCMarkup = '5000000000000000';
          // const diffAmountMoC = new BN(prevUserMoCBalance).sub(
          //   new BN(expectedMoCCommission)).sub(new BN(expectedMoCMarkup));

          mocHelper.assertBig(diff, '500000000000000000', 'Balance does not decrease by 0.5 RBTC');

          // mocHelper.assertBig(
          //   diffAmountMoC,
          //   '99988500000000000000',
          //   'Balance in MoC does not decrease by 0.0045 MoC'
          // );
        });
        it('AND User only spent on comissions and markup for 0.0045 MoC + 0.005 MoC', async function() {
          const btcBalance = await web3.eth.getBalance(userAccount);
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diff = prevBtcBalance
            .sub(toContractBN(btcBalance))
            .sub(txCost)
            .sub(toContractBN('500000000000000000'));
          const expectedMoCFees = new BN('4500000000000000').add(new BN('5000000000000000'));
          const diffFeesMoC = new BN(prevUserMoCBalance).sub(new BN(userMoCBalance));

          mocHelper.assertBig(
            diff,
            0,
            'RBTC balance should not decrease by comission cost, which is paid in MoC'
          );

          mocHelper.assertBig(
            expectedMoCFees,
            diffFeesMoC,
            'Balance in MoC does not decrease by 0.045 + 0.005 MoC'
          );
        });
        it('AND commissions account increase balance by 0.0045 MoC', async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const expectedMoCCommission = '4500000000000000';
          const diff = new BN(commissionsAccountMoCBalance).sub(
            new BN(prevCommissionsAccountMoCBalance)
          );

          mocHelper.assertBig(
            diff.toString(),
            expectedMoCCommission,
            'Balance in MoC does not increase by 0.0045 MoC Tokens'
          );
        });
        it('AND vendor account increase balance by 0.005 MoC', async function() {
          const vendorAccountMoCBalance = await mocHelper.getMoCBalance(vendorAccount);
          const expectedMoCMarkup = '5000000000000000';
          const diff = new BN(vendorAccountMoCBalance).sub(new BN(prevVendorAccountMoCBalance));

          mocHelper.assertBig(
            diff.toString(),
            expectedMoCMarkup,
            'Balance in MoC does not increase by 0.0045 MoC Tokens'
          );
        });
      });
      describe('WHEN a user tries to mint 10000 Docs using MoC commission with No Vendor', function() {
        let prevBtcBalance;
        let txCost;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let prevVendorAccountMoCBalance;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          prevVendorAccountMoCBalance = await mocHelper.getMoCBalance(zeroAddress);

          const tx = await mocHelper.mintDocAmount(
            userAccount,
            10000,
            zeroAddress,
            await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
          );
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('AND only spent 0.5 BTC + 0.0045 MoC commission + 0 MoC markup', async function() {
          // commission = 5000 * 0.009, markup = 0
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));

          mocHelper.assertBig(diff, '500000000000000000', 'Balance does not decrease by 0.5 RBTC');
        });
        it('AND User only spent on comissions and markup for 0.0045 MoC + 0 MoC', async function() {
          const btcBalance = await web3.eth.getBalance(userAccount);
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diff = prevBtcBalance
            .sub(toContractBN(btcBalance))
            .sub(txCost)
            .sub(toContractBN('500000000000000000'));
          const expectedMoCFees = new BN('4500000000000000');
          const diffFeesMoC = new BN(prevUserMoCBalance).sub(new BN(userMoCBalance));

          mocHelper.assertBig(
            diff,
            0,
            'RBTC balance should not decrease by comission cost, which is paid in MoC'
          );

          mocHelper.assertBig(
            expectedMoCFees,
            diffFeesMoC,
            'Balance in MoC does not decrease by 0.045 + 0.005 MoC'
          );
        });
        it('AND commissions account increase balance by 0.0045 MoC', async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const expectedMoCCommission = '4500000000000000';
          const diff = new BN(commissionsAccountMoCBalance).sub(
            new BN(prevCommissionsAccountMoCBalance)
          );

          mocHelper.assertBig(
            diff.toString(),
            expectedMoCCommission,
            'Balance in MoC does not increase by 0.0045 MoC Tokens'
          );
        });
        it('AND vendor account increase balance by 0 MoC', async function() {
          const vendorAccountMoCBalance = await mocHelper.getMoCBalance(zeroAddress);
          const expectedMoCMarkup = '0';
          const diff = new BN(vendorAccountMoCBalance).sub(new BN(prevVendorAccountMoCBalance));

          mocHelper.assertBig(
            diff.toString(),
            expectedMoCMarkup,
            'Balance in MoC does not increase by 0 MoC Tokens'
          );
        });
      });
    });
    describe('GIVEN since the user sends not enough amount to pay comission', function() {
      it('WHEN a user tries to mint DOCs with 1 RBTCs and does not send to pay fees, THEN expect revert', async function() {
        await mocHelper.mintBProAmount(
          userAccount,
          10,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
        const mintDoc = mocHelper.mintDoc(
          userAccount,
          1,
          vendorAccount,
          await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
        );
        await expectRevert(mintDoc, 'amount is not enough');
      });
    });
    describe('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to mint DoC with no MoC allowance, THEN expect revert', async function() {
        await mocHelper.mintMoCToken(userAccount, 1000, owner);
        // DO NOT approve MoC token on purpose
        await mocHelper.mintBProAmount(
          userAccount,
          10,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
        const mintDoc = mocHelper.mintDoc(
          userAccount,
          1,
          vendorAccount,
          await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
        );
        await expectRevert(mintDoc, 'amount is not enough');
      });
    });
    describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
      it('WHEN a user tries to mint DoC with MoC allowance, THEN fees are paid in RBTC', async function() {
        // DO NOT mint MoC token on purpose
        await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);
        const expectedMoCFees = 0; // commission + vendor fee
        const mintBproAmount = 1;
        const mintDocAmount = 10;
        const expectedRbtcCommission = 0.000003; // mintDocAmount / btcPrice * MINT_DOC_FEES_RBTC()
        const expectedRbtcVendorFee = 0.00001; // mintDocAmount / btcPrice * markup

        // Add vendor stake
        await mocHelper.mintMoCToken(vendorAccount, 100, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
        await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });

        await mocHelper.mintBProAmount(
          userAccount,
          mintBproAmount,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );

        // Calculate balances before minting
        const prevCommissionAccountBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );
        const prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
        const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

        // Mint
        await mocHelper.mintDocAmount(
          otherAddress,
          mintDocAmount,
          vendorAccount,
          await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
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
      it('WHEN a user tries to mint DoC, THEN expect exception', async function() {
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
          const txType = await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
          const mint = await mocHelper.mintDoc(failingAddress, 10, vendorAccount, txType);
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
      it('WHEN a user tries to mint DoC, THEN fees are paid in RBTC', async function() {
        const mocTokenAddress = this.mocToken.address;

        // Add vendor stake
        await mocHelper.mintMoCToken(vendorAccount, 100, owner);
        await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
        await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
          from: vendorAccount
        });

        // Set MoCToken address to 0
        await this.mockMocStateChanger.setMoCToken(zeroAddress);
        await this.governor.executeChange(mocHelper.mockMocStateChanger.address);

        const expectedMoCFees = 0; // commission + vendor fee
        const mintBproAmount = 1;
        const mintDocAmount = 10;
        const expectedRbtcCommission = 0.000003; // mintDocAmount / btcPrice * MINT_DOC_FEES_RBTC()
        const expectedRbtcVendorFee = 0.00001; // mintDocAmount / btcPrice * markup

        await mocHelper.mintBProAmount(
          userAccount,
          mintBproAmount,
          vendorAccount,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );

        // Calculate balances before minting
        const prevCommissionAccountBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );
        const prevVendorAccountBtcBalance = toContractBN(await web3.eth.getBalance(vendorAccount));
        const prevUserMoCBalance = await mocHelper.getMoCBalance(otherAddress);

        // Mint
        await mocHelper.mintDocAmount(
          otherAddress,
          mintDocAmount,
          vendorAccount,
          await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
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

    describe('(MoC fees) GIVEN BTC price is 10000', function() {
      let payAmount;
      let payComissionAmount;
      let payMarkupAmount;
      const btcPrice = 10000;
      const mocPrice = 10000;
      [0, 10000].forEach(nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [
            { docAmount: 1300, commissionAmount: 11.7, markupAmount: 13 }, // commission = 1300 * 0.009, markup = 1300 * 0.01
            { docAmount: 1200, commissionAmount: 10.8, markupAmount: 12 } // commission = 1200 * 0.009, markup = 1200 * 0.01
          ].forEach(({ docAmount, commissionAmount, markupAmount }) => {
            describe(`WHEN he tries to mint ${docAmount} RBTC`, function() {
              const prev = {};
              let txCost;
              beforeEach(async function() {
                // Load Btc on the contract to increase coverage
                await this.moc.sendTransaction({
                  value: 6 * mocHelper.RESERVE_PRECISION
                });
                // Load MoC on the user account
                await mocHelper.mintMoCToken(userAccount, 100, owner);
                await mocHelper.approveMoCToken(mocHelper.moc.address, 100, userAccount);

                // Add vendor stake
                await mocHelper.mintMoCToken(vendorAccount, 100, owner);
                await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
                await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
                  from: vendorAccount
                });

                if (nDocs) {
                  // owner mints
                  await mocHelper.mintDocAmount(
                    owner,
                    nDocs,
                    vendorAccount,
                    await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  );
                }
                [
                  prev.userBalance,
                  prev.commissionsAccountBalance,
                  prev.mocBalance,
                  prev.userMoCBalance,
                  prev.commissionsAccountMoCBalance,
                  prev.vendorAccountBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(commissionsAccount),
                  web3.eth.getBalance(this.moc.address),
                  mocHelper.getMoCBalance(userAccount),
                  mocHelper.getMoCBalance(commissionsAccount),
                  mocHelper.getMoCBalance(vendorAccount)
                ]);

                // userAccount mints
                const tx = await mocHelper.mintDocAmount(
                  userAccount,
                  docAmount,
                  vendorAccount,
                  await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
                );
                const _payAmount = (docAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = (commissionAmount * mocHelper.MOC_PRECISION) / mocPrice;
                payComissionAmount = toContractBN(_payComissionAmount);
                const _payMarkupAmount = (markupAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payMarkupAmount = toContractBN(_payMarkupAmount);

                txCost = await mocHelper.getTxCost(tx);
              });

              // Docs received should be the dollar value of the total BTC sent
              it(`THEN he receives ${docAmount} Docs on his account`, async function() {
                const balance = await mocHelper.getDoCBalance(userAccount);

                mocHelper.assertBigDollar(
                  balance,
                  docAmount,
                  `${docAmount} was not in the first account`
                );
              });

              it('THEN global balance increases by the correct amount of BTCs', async function() {
                const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
                const diff = new BN(mocBtcBalance).sub(new BN(prev.mocBalance));

                mocHelper.assertBig(diff, payAmount, 'Should increase sale total amount');
              });

              it('AND User Balance decreases by the correct amount of BTCs', async function() {
                const userBalance = await web3.eth.getBalance(userAccount);
                const diff = new BN(prev.userBalance).sub(new BN(userBalance)).sub(new BN(txCost));
                const totalSpent = payAmount;

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} BTC`
                );
              });

              it('AND Commissions Account Balance does not change because fees are paid in MoC', async function() {
                const commissionsAccountBalance = await web3.eth.getBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountBalance)
                );
                mocHelper.assertBig(diff, 0, 'Should not change');
              });

              it('AND User MoC Balance decreases by the correct amount of MoCs', async function() {
                const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
                const diff = new BN(prev.userMoCBalance).sub(new BN(userMoCBalance));
                const totalSpent = payComissionAmount.add(payMarkupAmount);

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} MoC`
                );
              });

              it('AND Commissions Account MoC Balance increase by the correct amount of commissions', async function() {
                const commissionsAccountBalance = await mocHelper.getMoCBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountMoCBalance)
                );
                mocHelper.assertBig(
                  diff,
                  payComissionAmount,
                  `Should increase by Tokens commission, ${payComissionAmount} MoC`
                );
              });

              it('AND Vendor Account Balance increase by the correct amount of markup', async function() {
                const vendorAccountBalance = await mocHelper.getMoCBalance(vendorAccount);
                const diff = new BN(vendorAccountBalance).sub(new BN(prev.vendorAccountBalance));
                mocHelper.assertBig(
                  diff,
                  payMarkupAmount,
                  `Should increase by Tokens commission, ${payMarkupAmount} BTC`
                );
              });
            });
          });
        });
      });
    });

    describe('(MoC fees) GIVEN BTC price is 10000 and MoC price drops to 5000', function() {
      let payAmount;
      let payComissionAmount;
      let payMarkupAmount;
      const btcPrice = 10000;
      const mocPrice = 5000;

      [0, 10000].forEach(nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [
            { docAmount: 1300, commissionAmount: 11.7, markupAmount: 13 }, // commission = 1300 * 0.009, markup = 1300 * 0.01
            { docAmount: 1200, commissionAmount: 10.8, markupAmount: 12 } // commission = 1200 * 0.009, markup = 1200 * 0.01
          ].forEach(({ docAmount, commissionAmount, markupAmount }) => {
            describe(`WHEN he tries to mint ${docAmount} RBTC`, function() {
              const prev = {};
              let txCost;
              beforeEach(async function() {
                // Load Btc on the contract to increase coverage
                await this.moc.sendTransaction({
                  value: 6 * mocHelper.RESERVE_PRECISION
                });

                // Set MoC price
                await mocHelper.setMoCPrice(mocPrice * mocHelper.MOC_PRECISION);

                // Load MoC on the user account
                await mocHelper.mintMoCToken(userAccount, 100, owner);
                await mocHelper.approveMoCToken(mocHelper.moc.address, 100, userAccount);

                // Add vendor stake
                await mocHelper.mintMoCToken(vendorAccount, 100, owner);
                await mocHelper.approveMoCToken(this.mocVendors.address, 100, vendorAccount);
                await this.mocVendors.addStake(toContractBN(100 * mocHelper.MOC_PRECISION), {
                  from: vendorAccount
                });

                if (nDocs) {
                  // owner mints
                  await mocHelper.mintDocAmount(
                    owner,
                    nDocs,
                    vendorAccount,
                    await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  );
                }
                [
                  prev.userBalance,
                  prev.commissionsAccountBalance,
                  prev.mocBalance,
                  prev.userMoCBalance,
                  prev.commissionsAccountMoCBalance,
                  prev.vendorAccountBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(commissionsAccount),
                  web3.eth.getBalance(this.moc.address),
                  mocHelper.getMoCBalance(userAccount),
                  mocHelper.getMoCBalance(commissionsAccount),
                  mocHelper.getMoCBalance(vendorAccount)
                ]);

                // userAccount mints
                const tx = await mocHelper.mintDocAmount(
                  userAccount,
                  docAmount,
                  vendorAccount,
                  await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
                );
                const _payAmount = (docAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = (commissionAmount * mocHelper.MOC_PRECISION) / mocPrice;
                payComissionAmount = toContractBN(_payComissionAmount);
                const _payMarkupAmount = (markupAmount * mocHelper.MOC_PRECISION) / mocPrice;
                payMarkupAmount = toContractBN(_payMarkupAmount);

                txCost = await mocHelper.getTxCost(tx);
              });

              // Docs received should be the dollar value of the total BTC sent
              it(`THEN he receives ${docAmount} Docs on his account`, async function() {
                const balance = await mocHelper.getDoCBalance(userAccount);

                mocHelper.assertBigDollar(
                  balance,
                  docAmount,
                  `${docAmount} was not in the first account`
                );
              });

              it('THEN global balance increases by the correct amount of BTCs', async function() {
                const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
                const diff = new BN(mocBtcBalance).sub(new BN(prev.mocBalance));

                mocHelper.assertBig(diff, payAmount, 'Should increase sale total amount');
              });

              it('AND User Balance decreases by the correct amount of BTCs', async function() {
                const userBalance = await web3.eth.getBalance(userAccount);
                const diff = new BN(prev.userBalance).sub(new BN(userBalance)).sub(new BN(txCost));
                const totalSpent = payAmount;

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} BTC`
                );
              });

              it('AND Commissions Account Balance does not change because fees are paid in MoC', async function() {
                const commissionsAccountBalance = await web3.eth.getBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountBalance)
                );

                mocHelper.assertBig(diff, 0, 'Should not change');
              });

              it('AND User MoC Balance decreases by the correct amount of MoCs', async function() {
                const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
                const diff = new BN(prev.userMoCBalance).sub(new BN(userMoCBalance));
                const totalSpent = payComissionAmount.add(payMarkupAmount);

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} MoC`
                );
              });

              it('AND Commissions Account MoC Balance increase by the correct amount of commissions', async function() {
                const commissionsAccountBalance = await mocHelper.getMoCBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountMoCBalance)
                );

                mocHelper.assertBig(
                  diff,
                  payComissionAmount,
                  `Should increase by Tokens commission, ${payComissionAmount} MoC`
                );
              });

              it('AND Vendor Account Balance increase by the correct amount of markup', async function() {
                const vendorAccountBalance = await mocHelper.getMoCBalance(vendorAccount);
                const diff = new BN(vendorAccountBalance).sub(new BN(prev.vendorAccountBalance));
                mocHelper.assertBig(
                  diff,
                  payMarkupAmount,
                  `Should increase by Tokens commission, ${payMarkupAmount} BTC`
                );
              });
            });
          });
        });
      });
    });
  });
});
