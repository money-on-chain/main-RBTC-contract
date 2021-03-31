const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_C0;

contract('MoC: MoCExchange', function([owner, userAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_C0 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('BPro minting', function() {
    describe('GIVEN sends 100 RBTC to mint BPro', function() {
      [(0, 100)].forEach(nBPros => {
        describe(`AND there are ${nBPros} nBPros`, function() {
          let userPrevBalance;
          let txCost;
          let c0bproPrevBalance;
          beforeEach(async function() {
            if (nBPros) {
              await mocHelper.mintBProAmount(owner, nBPros, vendorAccount);
            }

            userPrevBalance = toContractBN(await web3.eth.getBalance(userAccount));
            c0bproPrevBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
            const tx = await mocHelper.mintBPro(userAccount, 100, vendorAccount);
            txCost = await mocHelper.getTxCost(tx);
          });
          it('THEN he receives 100 BPro on his account', async function() {
            const balance = await mocHelper.getBProBalance(userAccount);
            mocHelper.assertBigRBTC(balance, 100, 'userAccount BPro balance was not 10000');
          });
          it('AND GLOBAL balance increases by 100 RBTC', async function() {
            const mocEthBalance = await web3.eth.getBalance(this.moc.address);
            mocHelper.assertBigRBTC(
              mocEthBalance,
              100 + nBPros,
              'Should only increase the total amount of the sale'
            );
          });
          it('AND C0 Bucket balance increases by 100 RBTC', async function() {
            const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
            mocHelper.assertBigRBTC(
              c0BTCBalance,
              100 + nBPros,
              'C0 BTC amount should rise 10000 wei'
            );
          });
          it('AND C0 Bucket BPro balance increases by 100 BPro', async function() {
            const c0BProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
            const diff = c0BProBalance.sub(c0bproPrevBalance);
            mocHelper.assertBigRBTC(diff, 100, 'C0 BTC amount should rise 10000 wei');
          });
          it('AND User Balance decreases by 100 + fee', async function() {
            const userBalance = await web3.eth.getBalance(userAccount);
            const diff = toContractBN(userPrevBalance)
              .sub(toContractBN(userBalance))
              .sub(toContractBN(txCost));
            mocHelper.assertBigRBTC(
              diff,
              100,
              'Should decrease by the cost of the Token and the gas used'
            );
          });
        });
      });
    });

    describe('GIVEN a user owns 10 BPros', function() {
      let userPreBalance;
      let initialBProBalance;
      let c0PrevBProBalance;
      let c0PrevBTCBalance;
      let maxBPro;
      const from = userAccount;
      beforeEach(async function() {
        await mocHelper.mintBPro(from, 11, vendorAccount);
        c0PrevBProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
        c0PrevBTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
        initialBProBalance = await mocHelper.getBProBalance(userAccount);
        userPreBalance = toContractBN(await web3.eth.getBalance(userAccount));
      });
      describe('AND there are 50000 DOCs AND BTC Price falls to 8000', function() {
        beforeEach(async function() {
          await mocHelper.mintDocAmount(owner, 50000, vendorAccount);
          await mocHelper.setBitcoinPrice(8000 * mocHelper.MOC_PRECISION);
        });
        describe('WHEN he tries to redeem 3 BPros', function() {
          it('THEN reverts for having the Coverage below Cobj', async function() {
            const coverage = await this.mocState.globalCoverage();
            const cobj = 3 * mocHelper.MOC_PRECISION;
            assert(coverage < cobj, 'Coverage is not below Cobj');
            const bproRedemption = mocHelper.redeemBPro(from, 3, vendorAccount);
            await expectRevert.unspecified(bproRedemption);
          });
        });
      });
      describe('AND BTC Price rises to 16000', function() {
        beforeEach(async function() {
          await mocHelper.setBitcoinPrice(16000 * mocHelper.MOC_PRECISION);
          maxBPro = await this.mocState.absoluteMaxBPro();
        });
        describe('WHEN he tries to redeem 11 BPros', function() {
          it('THEN he receives only the max redeem amount', async function() {
            await mocHelper.redeemBPro(from, 11, vendorAccount);

            const bproBalance = await mocHelper.getBProBalance(userAccount);
            const balanceDiff = initialBProBalance.sub(bproBalance);

            mocHelper.assertBig(balanceDiff, maxBPro, 'The redemption bpro amount was incorrect');
          });
        });
      });
      describe('WHEN he tries to redeem 20 BPros', function() {
        it('THEN he redeems all his BPros', async function() {
          await mocHelper.redeemBPro(from, 20, vendorAccount);

          const bproBalance = await mocHelper.getBProBalance(userAccount);
          mocHelper.assertBig(bproBalance, 0, 'The redemption bpro amount was incorrect');
        });
      });
      describe('WHEN he tries to redeem 6 BPros', function() {
        let txCost;
        beforeEach(async function() {
          const tx = await mocHelper.redeemBPro(from, 6, vendorAccount);
          txCost = await mocHelper.getTxCost(tx);
        });
        it('THEN he receives the corresponding amount of BTCs AND his BPro balance is 4', async function() {
          const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const balanceDiff = userPreBalance.sub(userBalance).sub(txCost);
          mocHelper.assertBigRBTC(balanceDiff, -6, 'Should increase by the equivalent BPros');
          const bproBalance = await mocHelper.getBProBalance(userAccount);
          mocHelper.assertBigRBTC(bproBalance, 5, 'Should be 11 - 6');
        });
        it('AND C0 Bucket BTC balance decreases by 6 BTCs', async function() {
          const c0BTCBalance = await this.mocState.getBucketNBTC(BUCKET_C0);
          const diff = c0BTCBalance.sub(c0PrevBTCBalance);
          mocHelper.assertBigRBTC(diff, -6, 'C0 BTC amount should rise 10000 wei');
        });
        it('AND C0 Bucket BPro balance decreases by 6 BPro', async function() {
          const c0BProBalance = await this.mocState.getBucketNBPro(BUCKET_C0);
          const diff = c0BProBalance.sub(c0PrevBProBalance);
          mocHelper.assertBigRBTC(diff, -6, 'C0 BTC amount should rise 6 wei');
        });
      });
    });
  });

  describe('BPro mixed minting', function() {
    let userPrevBalance;
    describe('GIVEN there are 10 BPros, 50000 DOCs AND the BTC price falls to 6400', function() {
      beforeEach(async function() {
        await mocHelper.setSmoothingFactor(10 ** 18);
        await mocHelper.mintBProAmount(owner, 10, vendorAccount);
        await mocHelper.mintDocAmount(owner, 50000, vendorAccount);

        userPrevBalance = await web3.eth.getBalance(userAccount);
        await mocHelper.setBitcoinPrice(6400 * mocHelper.MOC_PRECISION);
      });

      it('THEN there are bpros with discount available', async function() {
        const bprosWithDiscount = await this.mocState.maxBProWithDiscount();
        assert(bprosWithDiscount.gt(toContractBN(0)), undefined);
      });
      describe('WHEN a user sent 10 BTC to mint BPros', function() {
        const sentAmount = 10;
        let txCost;
        beforeEach(async function() {
          const tx = await mocHelper.mintBPro(userAccount, sentAmount, vendorAccount);
          txCost = await mocHelper.getTxCost(tx);
        });
        it('THEN he receives the correct 13.913 of BPros', async function() {
          const balance = await mocHelper.getBProBalance(userAccount);
          mocHelper.assertBig(
            balance,
            '13913043478260869569',
            'userAccount BPro balance was not correct'
          );
        });
        it('THEN he spent all the RBTC he sent', async function() {
          const currentBalance = await web3.eth.getBalance(userAccount);
          const diff = toContractBN(userPrevBalance)
            .sub(toContractBN(currentBalance))
            .sub(toContractBN(txCost));
          mocHelper.assertBig(
            diff,
            toContractBN(sentAmount).mul(mocHelper.RESERVE_PRECISION),
            `userAccount RBTC did not decreased in ${sentAmount} but in ${diff.toString()}`
          );
        });
        it('THEN there are no more BPros with discount available', async function() {
          const bprosAvailable = await this.mocState.maxBProWithDiscount();
          mocHelper.assertBig(bprosAvailable, 0, 'There are bpros with discount available');
        });
      });
    });
  });

  describe('BPro minting with discount', function() {
    describe('GIVEN there are 10 BPros AND the BTC price is 10000', function() {
      let userPrevBalance;
      let txCost;
      beforeEach(async function() {
        await mocHelper.setSmoothingFactor(10 ** 18);
        await mocHelper.mintBProAmount(owner, 10, vendorAccount);
        userPrevBalance = toContractBN(await web3.eth.getBalance(userAccount));
      });

      describe('AND the UTPDU is set to 2', function() {
        describe('AND the discount is set to 10%', function() {
          describe('AND the Amount of Docs is 50000', function() {
            beforeEach(async function() {
              await mocHelper.mintDocAmount(owner, 50000, vendorAccount);
            });

            describe('WHEN BTC Price is 5400', function() {
              let maxWithDiscount;
              beforeEach(async function() {
                await mocHelper.setBitcoinPrice(5400 * mocHelper.MOC_PRECISION);
                maxWithDiscount = toContractBN(await this.mocState.maxBProWithDiscount());
              });
              describe('AND a user tries to mint the max amount of BPro with Discount', function() {
                beforeEach(async function() {
                  await mocHelper.mintBProAmount(
                    userAccount,
                    maxWithDiscount.div(mocHelper.RESERVE_PRECISION),
                    vendorAccount
                  );
                });
                it('AND coverage should be close to utpdu', async function() {
                  const coverage = await this.mocState.globalCoverage();
                  const utpdu = await this.mocState.utpdu();

                  mocHelper.assertBig(coverage, utpdu, 'Coverage is not close to utpdu', {
                    significantDigits: 3 // FIXME 2: before 15
                  });
                });
              });

              describe('AND a user sends BTC to mint 0.5 BPro with Discount', function() {
                let totalWithDiscount;
                beforeEach(async function() {
                  totalWithDiscount = await mocHelper.rbtcNeededToMintBpro(0.5);
                  const applyPrecision = false;
                  const tx = await mocHelper.mintBPro(
                    userAccount,
                    totalWithDiscount,
                    vendorAccount,
                    applyPrecision
                  );
                  txCost = await mocHelper.getTxCost(tx);
                });
                it('THEN he receives 0.5 BPros on his account', async function() {
                  const balance = await mocHelper.getBProBalance(userAccount);
                  mocHelper.assertBig(
                    balance,
                    toContractBN(0.5, 'BTC'),
                    'userAccount BPro balance was close to 0.5',
                    {
                      significantDigits: 14
                    }
                  );
                });
                it('THEN the amount available for discount should decrease', async function() {
                  const newMaxAmountWithDiscount = await this.mocState.maxBProWithDiscount();
                  const diff = newMaxAmountWithDiscount.sub(maxWithDiscount);
                  assert(diff.lt(toContractBN(0)), 'discount BPro does not decrease');
                });
                it('THEN User Balance decreases by the total discount price + fee', async function() {
                  const userBalance = toContractBN(await web3.eth.getBalance(userAccount));
                  const diff = userPrevBalance.sub(userBalance);
                  mocHelper.assertBig(
                    diff,
                    totalWithDiscount.add(txCost),
                    'Should decrease by the cost of the Token and the gas used'
                  );
                });
                describe('AND the BTC Price rises to 11000', function() {
                  beforeEach(async function() {
                    await mocHelper.setBitcoinPrice(11000 * mocHelper.MOC_PRECISION);
                  });
                  describe('AND the user tries to mint 10 BPro with Discount', function() {
                    it('THEN max bpro with discount should be 0', async function() {
                      const maxBPro = await this.mocState.maxBProWithDiscount();
                      mocHelper.assertBig(maxBPro, 0, 'Max bpro available is not 0');
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });

  describe('BPro tec price', function() {
    describe('GIVEN the user have 18 BPro and 80000 DOCs and Bitcoin price falls to 2000 and liquidation is not enabled', function() {
      const expectedBtcPrice = 2000;
      const expectedBitcoinMovingAverage = 10000;
      const expectedGlobalCoverage = '0.65';
      const expectedBProDiscountRate = 70;
      const expectedBProTecPrice = 1;
      const expectedMaxBProWithDiscount = '54027013506753376688344172086043021510';

      beforeEach(async function() {
        await mocHelper.mintBProAmount(userAccount, 18, vendorAccount);
        await mocHelper.mintDocAmount(userAccount, 80000, vendorAccount);
        // Move price to change BProx price and make it different
        // from BPro price
        const newBtcPrice = toContractBN(expectedBtcPrice * mocHelper.MOC_PRECISION);
        await mocHelper.setBitcoinPrice(newBtcPrice);
      });
      it(`THEN the Bitcoin Price in USD should be ${expectedBtcPrice}`, async function() {
        const btcPrice = await this.mocState.getBitcoinPrice();

        mocHelper.assertBigRBTC(btcPrice, expectedBtcPrice, 'Bitcoin Price in USD is incorrect');
      });
      it(`THEN the Bitcoin Moving Average in USD should be ${expectedBitcoinMovingAverage}`, async function() {
        const bma = await this.mocState.getBitcoinMovingAverage();

        mocHelper.assertBigDollar(
          bma,
          expectedBitcoinMovingAverage,
          'Bitcoin Moving Average in USD is incorrect'
        );
      });
      it(`THEN the global coverage should be ${expectedGlobalCoverage}`, async function() {
        const coverage = await this.mocState.globalCoverage();

        mocHelper.assertBigRBTC(coverage, expectedGlobalCoverage, 'Global coverage is incorrect');
      });
      it(`THEN the BPro spot discount rate should be ${expectedBProDiscountRate}`, async function() {
        const bproSpotDiscount = await this.mocState.bproSpotDiscountRate();

        assert(
          bproSpotDiscount.toNumber() === expectedBProDiscountRate,
          'BPro spot discount rate is incorrect'
        );
      });
      it(`THEN the BPro tec price in RBTC should be ${expectedBProTecPrice} wei`, async function() {
        const bproTecPrice = await this.mocState.bproTecPrice();

        assert(bproTecPrice.toNumber() === expectedBProTecPrice, 'BPro tec price is incorrect');
      });
      it(`THEN Max BPro With Discount should be ${expectedMaxBProWithDiscount}`, async function() {
        const bprosWithDiscount = await this.mocState.maxBProWithDiscount();

        assert(
          bprosWithDiscount.toString() === expectedMaxBProWithDiscount,
          'Max BPro With Discount is incorrect'
        );
      });
    });
  });
});
