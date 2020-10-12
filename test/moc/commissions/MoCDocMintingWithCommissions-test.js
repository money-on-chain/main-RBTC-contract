const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
const { BN } = web3.utils;
// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";

contract('MoC', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    this.mocToken = mocHelper.mocToken;
    this.mocConnector = mocHelper.mocConnector;
  });

  describe.only('Doc minting paying Commissions', function() {
    beforeEach(async function() {
      await mocHelper.revertState();

      // Commission rates are set in contractsBuilder.js

      // set commissions address
      await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
      // update params
      await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
    });

    // RBTC commission
    describe('(RBTC commission) GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(
          userAccount,
          1,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
      });
      describe('WHEN a user tries to mint 10000 Docs using RBTC commission', function() {
        let prevBtcBalance;
        let prevCommissionsAccountBtcBalance;
        let txCost;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const tx = await mocHelper.mintDocAmount(
            userAccount,
            10000,
            await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
          );

          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('AND only spent 0.5 BTC + 0.0015 RBTC commission', async function() {
          // commission = 5000 * 0.003
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));

          mocHelper.assertBig(
            diff,
            '501500000000000000',
            'Balance does not decrease by 0.5 RBTC + 0.0015 RBTC commission'
          );
        });
        it('AND User only spent on comissions for 0.0015 RBTC', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance
            .sub(toContractBN(btcBalance))
            .sub(new BN(txCost))
            .sub(toContractBN(500000000000000000));

          mocHelper.assertBig(
            diff,
            '1500000000000000',
            'Should decrease by comission cost, 1500000000000000 BTC'
          );
        });
        it('AND commissions account increase balance by 0.0015 RBTC', async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const diff = btcBalance.sub(toContractBN(prevCommissionsAccountBtcBalance));
          mocHelper.assertBig(diff, '1500000000000000', 'Balance does not increase by 0.0015 RBTC');
        });
      });
    });

    describe('GIVEN since the user sends not enough amount to pay comission', function() {
      it('WHEN a user tries to mint DOCs with 1 RBTCs and does not send to pay commission', async function() {
        await mocHelper.mintBProAmount(
          userAccount,
          10,
          await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
        );
        const mintDoc = mocHelper.mintDoc(
          userAccount,
          1,
          await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
        );
        await expectRevert.unspecified(mintDoc);
      });
    });

    describe('(RBTC commission) GIVEN BTC price is 10000', function() {
      let payAmount;
      let payComissionAmount;
      const btcPrice = 10000;
      [0, 10000].forEach(nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [
            { docAmount: 1300, commissionAmount: 3.9 }, // commission = 1300 * 0.003
            { docAmount: 1200, commissionAmount: 3.6 } // commission = 1200 * 0.003 = 30
          ].forEach(({ docAmount, commissionAmount }) => {
            describe(`WHEN he tries to mint ${docAmount} RBTC`, function() {
              const prev = {};
              let txCost;
              beforeEach(async function() {
                // Load Btc on the contract to increase coverage
                await this.moc.sendTransaction({
                  value: 6 * mocHelper.RESERVE_PRECISION
                });

                if (nDocs) {
                  await mocHelper.mintDocAmount(
                    owner,
                    nDocs,
                    await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  );
                }
                [
                  prev.userBalance,
                  prev.commissionsAccountBalance,
                  prev.mocBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(commissionsAccount),
                  web3.eth.getBalance(this.moc.address)
                ]);

                const tx = await mocHelper.mintDocAmount(
                  userAccount,
                  docAmount,
                  await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                );
                const _payAmount = (docAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = (commissionAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payComissionAmount = toContractBN(_payComissionAmount);

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

              it('AND User Balance decreases by the correct amount of  BTCs and commission', async function() {
                const userBalance = await web3.eth.getBalance(userAccount);
                const diff = new BN(prev.userBalance).sub(new BN(userBalance)).sub(new BN(txCost));
                const totalSpent = payAmount.add(payComissionAmount);

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
            });
          });
        });
      });
    });

    // MoC commission
    describe('(MoC commission) GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        await mocHelper.mintMoCToken(userAccount, 100, owner);
        await mocHelper.approveMoCToken(mocHelper.moc.address, 100, userAccount);
        await mocHelper.mintBProAmount(
          userAccount,
          1,
          await mocHelper.mocInrate.MINT_BPRO_FEES_MOC()
        );
      });
      describe('WHEN a user tries to mint 10000 Docs using MoC commission', function() {
        let prevBtcBalance;
        let txCost;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);

          const tx = await mocHelper.mintDocAmount(
            userAccount,
            10000,
            await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
          );
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });
        it('AND only spent 0.5 BTC + 0.0045 MoC commission', async function() {
          // commission = 5000 * 0.009
          const btcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevBtcBalance.sub(toContractBN(btcBalance)).sub(new BN(txCost));
          const expectedMoCCommission = '4500000000000000';
          const diffAmountMoC = new BN(prevUserMoCBalance).sub(new BN(expectedMoCCommission));

          mocHelper.assertBig(diff, '500000000000000000', 'Balance does not decrease by 0.5 RBTC');

          mocHelper.assertBig(
            diffAmountMoC,
            '99988500000000000000',
            'Balance in MoC does not decrease by 0.0045 MoC'
          );
        });
        it('AND User only spent on comissions for 0.0045 MoC', async function() {
          const btcBalance = await web3.eth.getBalance(userAccount);
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diff = prevBtcBalance
            .sub(toContractBN(btcBalance))
            .sub(txCost)
            .sub(toContractBN('500000000000000000'));
          const expectedMoCCommission = '4500000000000000';
          const diffCommissionMoC = new BN(prevUserMoCBalance).sub(new BN(userMoCBalance));

          mocHelper.assertBig(
            diff,
            0,
            'RBTC balance should not decrease by comission cost, which is paid in MoC'
          );

          mocHelper.assertBig(
            diffCommissionMoC,
            expectedMoCCommission,
            'Balance in MoC does not decrease by 0.045 MoC'
          );
        });
        it('AND commissions account increase balance by 0.0045 MoC', async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const expectedMoCCommission = '4500000000000000';
          const diff = new BN(commissionsAccountMoCBalance).sub(
            new BN(prevCommissionsAccountMoCBalance)
          );

          console.log("prevCommissionsAccountMoCBalance: ", prevCommissionsAccountMoCBalance.toString());
          console.log("commissionsAccountMoCBalance: ", commissionsAccountMoCBalance.toString());
          console.log("diff: ", diff.toString());

          mocHelper.assertBig(
            diff.toString(),
            expectedMoCCommission,
            'Balance in MoC does not increase by 0.0045 RBTC'
          );
        });
      });
    });

    describe('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to mint DoC with no MoC allowance, THEN ??? expect revert', async function() {
        await mocHelper.mintMoCToken(userAccount, 1000, owner);
        // DO NOT approve MoC token on purpose
        const txType = await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
        const mint = mocHelper.mintDoc(userAccount, 10, txType);
        //await expectRevert.unspecified(mint);
      });
    });
    describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
      it('WHEN a user tries to mint DoC with MoC allowance, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        // DO NOT mint MoC token on purpose
        await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);

        const prevUserMoCBalanceOtherAddress = new BN(0); // No MoC balance
        const expectedMoCAmount = 0;
        const expectedMoCCommission = 0;
        const mintAmount = 100;
        const expectedRbtcCommission = 0.3; // mintAmount * MINT_DOC_FEES_RBTC()
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = 100.3; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
        // Mint
        const mint = await mocHelper.mintDocAmount(otherAddress, mintAmount, txType);
        const usedGas = toContractBN(await mocHelper.getTxCost(mint));

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

        console.log("prevUserBtcBalanceOtherAddress: ", prevUserBtcBalanceOtherAddress.toString());
        console.log("userBtcBalanceOtherAccount: ", userBtcBalanceOtherAccount.toString());
        console.log("diffRbtcAmount: ", diffRbtcAmount.toString());

        mocHelper.assertBigRBTC(diffMoCAmount, expectedMoCAmount, 'user MoC balance is incorrect');
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
          const mint = await mocHelper.mintDoc(failingAddress, 10, txType);
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
      it('WHEN a user tries to mint DoC, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        const mocTokenAddress = this.mocToken.address;
        // Set MoCToken address to 0
        const zeroAddress = '0x0000000000000000000000000000000000000000';
        await this.mocConnector.setMoCToken(zeroAddress);

        const prevUserMoCBalanceOtherAddress = new BN(0); // No MoC balance
        const expectedMoCAmount = 0;
        const expectedMoCCommission = 0;
        const mintAmount = 100;
        const expectedRbtcCommission = 0.3; // mintAmount * MINT_DOC_FEES_RBTC()
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = 100.3; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_DOC_FEES_RBTC();
        // Mint
        const mint = await mocHelper.mintDocAmount(otherAddress, mintAmount, txType);
        const usedGas = toContractBN(await mocHelper.getTxCost(mint));

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
        await this.mocConnector.setMoCToken(mocTokenAddress);

        mocHelper.assertBigRBTC(diffMoCAmount, expectedMoCAmount, 'user MoC balance is incorrect');
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

    describe('(MoC commission) GIVEN BTC price is 10000', function() {
      let payAmount;
      let payComissionAmount;
      const btcPrice = 10000;
      [0, 10000].forEach(nDocs => {
        describe(`AND There are ${nDocs} Docs and 6 BTC`, function() {
          [
            { docAmount: 1300, commissionAmount: 11.7 }, // commission = 1300 * 0.009
            { docAmount: 1200, commissionAmount: 10.8 } // commission = 1200 * 0.009
          ].forEach(({ docAmount, commissionAmount }) => {
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

                if (nDocs) {
                  await mocHelper.mintDocAmount(
                    owner,
                    nDocs,
                    await mocHelper.mocInrate.MINT_DOC_FEES_MOC()
                  );
                }
                [
                  prev.userBalance,
                  prev.commissionsAccountBalance,
                  prev.mocBalance,
                  prev.userMoCBalance,
                  prev.commissionsAccountMoCBalance
                ] = await Promise.all([
                  web3.eth.getBalance(userAccount),
                  web3.eth.getBalance(commissionsAccount),
                  web3.eth.getBalance(this.moc.address),
                  await mocHelper.getMoCBalance(userAccount),
                  await mocHelper.getMoCBalance(commissionsAccount)
                ]);

                const tx = await mocHelper.mintDocAmount(
                  userAccount,
                  docAmount,
                  await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                );
                const _payAmount = (docAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = (commissionAmount * mocHelper.MOC_PRECISION) / btcPrice;
                payComissionAmount = toContractBN(_payComissionAmount);

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

              it('AND Commissions Account Balance does not change because commissions are paid in MoC', async function() {
                const commissionsAccountBalance = await web3.eth.getBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsAccountBalance)
                );
                mocHelper.assertBig(diff, 0, 'Should not change');
              });

              it('AND User MoC Balance decreases by the correct amount of MoCs', async function() {
                const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
                const diff = new BN(prev.userMoCBalance)
                  .sub(new BN(userMoCBalance))
                  .sub(new BN(txCost));
                const totalSpent = payComissionAmount;

                mocHelper.assertBig(
                  diff,
                  totalSpent,
                  `Should decrease by Tokens cost, ${totalSpent} BTC`
                );
              });

              it('AND Commissions Account MoC Balance increase by the correct amount of commissions', async function() {
                const commissionsAccountBalance = await mocHelper.getMoCBalance(commissionsAccount);
                const diff = new BN(commissionsAccountBalance).sub(
                  new BN(prev.commissionsMoCAccountBalance)
                );
                mocHelper.assertBig(
                  diff,
                  payComissionAmount,
                  `Should increase by Tokens commission, ${payComissionAmount} MoC`
                );
              });
            });
          });
        });
      });
    });
  });
});
