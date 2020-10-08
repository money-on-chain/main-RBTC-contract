const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
const { BN } = web3.utils;

contract('MoC', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
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

    describe('GIVEN the max DOC available is 5000', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(userAccount, 1, await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC());
      });
      describe('WHEN a user tries to mint 10000 Docs', function() {
        let prevBtcBalance;
        let prevCommissionsAccountBtcBalance;
        let txCost;
        beforeEach(async function() {
          prevBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const tx = await mocHelper.mintDocAmount(userAccount, 10000, await mocHelper.mocInrate.MINT_DOC_FEES_RBTC());

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
        await mocHelper.mintBProAmount(userAccount, 10, await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC());
        const mintDoc = mocHelper.mintDoc(userAccount, 1, await mocHelper.mocInrate.MINT_DOC_FEES_RBTC());
        await expectRevert.unspecified(mintDoc);
      });
    });

    describe('GIVEN BTC price is 10000', function() {
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
                  await mocHelper.mintDocAmount(owner, nDocs, await mocHelper.mocInrate.MINT_DOC_FEES_RBTC());
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

                const tx = await mocHelper.mintDocAmount(userAccount, docAmount, await mocHelper.mocInrate.MINT_DOC_FEES_RBTC());
                const _payAmount = docAmount * mocHelper.MOC_PRECISION / btcPrice;
                payAmount = toContractBN(_payAmount);
                const _payComissionAmount = commissionAmount * mocHelper.MOC_PRECISION / btcPrice;
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
  });
});
