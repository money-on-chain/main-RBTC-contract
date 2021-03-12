const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

contract.skip('MoC', function([owner, userAccount, otherAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocConnector = mocHelper.mocConnector;
    ({ BUCKET_X2 } = mocHelper);
  });

  describe('Free Doc redeem without interests', function() {
    before(async function() {
      await mocHelper.revertState();

      // Register vendor for test
      await mocHelper.registerVendor(vendorAccount, 0, owner);

      // This makes doc redemption interests zero
      await this.mocState.setDaysToSettlement(0);
    });
    describe('Redeem free docs locking some of them', function() {
      const scenarios = [
        {
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            bproxToMint: 0.05,
            docsToRedeem: 100,
            docsToDrop: 0,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 100,
            inRateBeforeRedeem: 0.02,
            X2BucketCoverageBeforeRedeem: 2,
            X2BucketLeverageBeforeRedeem: 2,
            X2BucketCoverageAfterRedeem: 2,
            X2BucketLeverageAfterRedeem: 2,
            freeDocsAfterBproxMint: 500,
            freeDocsAfterRedeem: 400,
            docBalanceAfterRedeem: 900
          }
        },
        {
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            bproxToMint: 0.05,
            docsToRedeem: 500,
            docsToDrop: 0,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 500,
            X2BucketCoverageBeforeRedeem: 2,
            X2BucketLeverageBeforeRedeem: 2,
            X2BucketCoverageAfterRedeem: 2,
            X2BucketLeverageAfterRedeem: 2,
            freeDocsAfterBproxMint: 500,
            freeDocsAfterRedeem: 0,
            docBalanceAfterRedeem: 500
          }
        },
        {
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            X2BucketCoverageBeforeRedeem: 2,
            X2BucketLeverageBeforeRedeem: 2,
            X2BucketCoverageAfterRedeem: 2,
            X2BucketLeverageAfterRedeem: 2,
            bproxToMint: 0.05,
            docsToRedeem: 200,
            docsToDrop: 900,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 100,
            X2BucketCoverageBeforeRedeem: 2,
            X2BucketLeverageBeforeRedeem: 2,
            X2BucketCoverageAfterRedeem: 2,
            X2BucketLeverageAfterRedeem: 2,
            freeDocsAfterBproxMint: 500,
            freeDocsAfterRedeem: 400,
            docBalanceAfterRedeem: 0
          }
        }
      ];

      scenarios.forEach(async scenario => {
        describe(`GIVEN ${scenario.params.bproToMint} BitPro is minted and btc price is ${scenario.params.initialBtcPrice} usd`, function() {
          beforeEach(async function() {
            await mocHelper.revertState();
            await mocHelper.mintBProAmount(owner, scenario.params.bproToMint, vendorAccount);
          });
          describe(`WHEN ${scenario.params.docsToMint} doc are minted`, function() {
            beforeEach(async function() {
              await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint, vendorAccount);
            });
            it(`THEN the user has ${scenario.params.docsToMint} docs`, async function() {
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(
                docBalance,
                scenario.params.docsToMint,
                'wrong amount of doc received'
              );
            });
            it(`THEN ${scenario.expect.initialFreeDocs} doc are free docs`, async function() {
              const freeDoc = await this.mocState.freeDoc();
              mocHelper.assertBigDollar(
                freeDoc,
                scenario.expect.initialFreeDocs,
                'wrong amount of free doc'
              );
            });
          });
          describe(`WHEN ${scenario.params.bproxToMint} BProx are minted`, function() {
            beforeEach(async function() {
              await mocHelper.mintBProxAmount(
                owner,
                BUCKET_X2,
                scenario.params.bproxToMint,
                vendorAccount
              );
            });
            it(`THEN the user has ${scenario.params.bproxToMint} bprox `, async function() {
              const bproxBalance = await mocHelper.getBProxBalance(BUCKET_X2, owner);

              mocHelper.assertBigRBTC(
                bproxBalance,
                scenario.params.bproxToMint,
                'wrong amount of bprox received'
              );
            });
            it(`THEN ${scenario.expect.freeDocsAfterBproxMint} doc are free docs`, async function() {
              const freeDoc = await this.mocState.freeDoc();
              mocHelper.assertBigDollar(
                freeDoc,
                scenario.expect.freeDocsAfterBproxMint,
                'wrong amount of free doc after minting bprox'
              );
            });
            it(`THEN X2 bucket coverage is ${scenario.expect.X2BucketCoverageBeforeRedeem}`, async function() {
              const coverage = await this.mocState.coverage(BUCKET_X2);
              mocHelper.assertBigCb(
                coverage,
                scenario.expect.X2BucketCoverageBeforeRedeem,
                'wrong X2 coverage after minting bprox'
              );
            });
            it(`THEN X2 bucket leverage is ${scenario.expect.X2BucketLeverageBeforeRedeem}`, async function() {
              const leverage = await this.mocState.leverage(BUCKET_X2);
              mocHelper.assertBigCb(
                leverage,
                scenario.expect.X2BucketLeverageBeforeRedeem,
                'wrong X2 leverage after minting bprox'
              );
            });
          });
          describe(`AND the user drops ${scenario.params.docsToDrop} doc`, function() {
            let userBtcBalance;
            let redeemTx;
            let usedGas;
            beforeEach(async function() {
              await mocHelper.doc.transfer(
                otherAccount,
                toContractBN(scenario.params.docsToDrop * mocHelper.MOC_PRECISION),
                {
                  from: userAccount
                }
              );
            });
            it(`THEN the user has ${scenario.params.docsToMint -
              scenario.params.docsToDrop} doc`, async function() {
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(
                docBalance,
                scenario.params.docsToMint - scenario.params.docsToDrop,
                'user has wrong amount of docs'
              );
            });
            describe(`AND ${scenario.params.docsToRedeem} docs are redeemed`, function() {
              beforeEach(async function() {
                userBtcBalance = await web3.eth.getBalance(userAccount);
                redeemTx = await mocHelper.redeemFreeDoc({
                  userAccount,
                  docAmount: scenario.params.docsToRedeem,
                  vendorAccount
                });
                usedGas = toContractBN(await mocHelper.getTxCost(redeemTx));
              });
              it(`THEN the redeemers BTC balance is increased by redeeming only ${scenario.expect.docsToRedeem} docs`, async function() {
                const currentBalance = toContractBN(await web3.eth.getBalance(userAccount));
                mocHelper.assertBig(
                  userBtcBalance,
                  currentBalance
                    .sub(
                      mocHelper.RESERVE_PRECISION.mul(
                        toContractBN(scenario.expect.docsToRedeem)
                      ).div(toContractBN(scenario.params.initialBtcPrice))
                    )
                    .add(usedGas),
                  'incorrect amount of BTC sent to user'
                );
              });
              it('THEN redeemers DoC balance is decreased', async function() {
                const docBalance = await mocHelper.getDoCBalance(userAccount);
                mocHelper.assertBigDollar(
                  docBalance,
                  scenario.expect.docBalanceAfterRedeem,
                  'wrong amount of doc burnt after redeem'
                );
              });
              it(`THEN ${scenario.expect.docsToRedeem} DoCs are burnt`, async function() {
                const transferEvent = mocHelper.findEvents(redeemTx, 'Transfer')[0];
                mocHelper.assertBigDollar(
                  transferEvent.value,
                  scenario.expect.docsToRedeem,
                  'Incorrect amount of DoCs burnt'
                );
                assert(
                  transferEvent.to === '0x0000000000000000000000000000000000000000',
                  'DoCs werent burnt'
                );
                assert(
                  transferEvent.from === userAccount,
                  'DoCs were burnt from the wrong address'
                );
              });
              it('THEN a FreeStableTokenRedeem event is logged', async function() {
                const freeDocRedeemEvent = mocHelper.findEvents(
                  redeemTx,
                  'FreeStableTokenRedeem'
                )[0];
                mocHelper.assertBigDollar(
                  freeDocRedeemEvent.amount,
                  scenario.expect.docsToRedeem,
                  'wrong amount of docs redeemed'
                );
                mocHelper.assertBigRBTC(
                  freeDocRedeemEvent.reserveTotal,
                  scenario.expect.docsToRedeem / scenario.params.initialBtcPrice,
                  'wrong amount of btc sent to redeemer'
                );
                mocHelper.assertBigRBTC(
                  freeDocRedeemEvent.reservePrice,
                  scenario.params.initialBtcPrice,
                  'wrong btc price set on event'
                );
              });
              it('THEN a regular StableTokenRedeem event is not logged', function() {
                const docRedeemEvents = mocHelper.findEvents(redeemTx, 'StableTokenRedeem');
                assert(
                  docRedeemEvents.length === 0,
                  'a doc redeem event was generated on a free doc redeem'
                );
              });
              it(`THEN free docs are decreased to ${scenario.expect.freeDocsAfterRedeem}`, async function() {
                const freeDoc = await this.mocState.freeDoc();
                mocHelper.assertBigDollar(
                  freeDoc,
                  scenario.expect.freeDocsAfterRedeem,
                  'wrong amount of free doc'
                );
              });
              it(`THEN X2 bucket coverage is ${scenario.expect.X2BucketCoverageBeforeRedeem}`, async function() {
                const coverage = await this.mocState.coverage(BUCKET_X2);
                mocHelper.assertBigCb(
                  coverage,
                  scenario.expect.X2BucketCoverageBeforeRedeem,
                  'wrong X2 coverage after minting bprox'
                );
              });
              it(`THEN X2 bucket leverage is ${scenario.expect.X2BucketLeverageBeforeRedeem}`, async function() {
                const leverage = await this.mocState.leverage(BUCKET_X2);
                mocHelper.assertBigCb(
                  leverage,
                  scenario.expect.X2BucketLeverageBeforeRedeem,
                  'wrong X2 leverage after minting bprox'
                );
              });
            });
          });
        });
      });
    });
    describe('Redeem free docs without locking any', function() {
      before(async function() {
        await mocHelper.revertState();
      });
      const scenarios = [
        {
          description: 'Redeeming: happy path',
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            docsToRedeem: 100,
            docsToDrop: 0,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 100,
            freeDocsAfterRedeem: 900,
            docBalanceAfterRedeem: 900
          }
        },
        {
          description: 'Redeeming limited by free doc amount AND users balance',
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            docsToRedeem: 2000,
            docsToDrop: 0,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 1000,
            freeDocsAfterRedeem: 0,
            docBalanceAfterRedeem: 0
          }
        },
        {
          description: 'Redeeming limited by users balance',
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            docsToRedeem: 500,
            docsToDrop: 900,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 100,
            freeDocsAfterRedeem: 900,
            docBalanceAfterRedeem: 0
          }
        },
        {
          description: 'Redeeming up to both users balance and free doc amount',
          params: {
            docsToMint: 1000,
            bproToMint: 1,
            docsToRedeem: 1000,
            docsToDrop: 0,
            initialBtcPrice: 10000
          },
          expect: {
            initialFreeDocs: 1000,
            docsToRedeem: 1000,
            freeDocsAfterRedeem: 0,
            docBalanceAfterRedeem: 0
          }
        }
      ];

      scenarios.forEach(async scenario => {
        describe(scenario.description, function() {
          let userBtcBalance;
          let redeemTx;
          let usedGas;
          describe(`GIVEN ${scenario.params.bproToMint} bitpro is minted and btc price is ${scenario.params.initialBtcPrice} usd`, function() {
            before(async function() {
              await mocHelper.revertState();
              await mocHelper.mintBProAmount(owner, scenario.params.bproToMint, vendorAccount);
              await mocHelper.mintDocAmount(userAccount, scenario.params.docsToMint, vendorAccount);
            });
            it(`THEN there are ${scenario.params.docsToMint} doc are minted`, async function() {
              const docBalance = await mocHelper.getDoCBalance(userAccount);
              mocHelper.assertBigDollar(
                docBalance,
                scenario.params.docsToMint,
                'wrong amount of doc received'
              );
            });
            it(`THEN ${scenario.expect.initialFreeDocs} doc are free docs`, async function() {
              const freeDoc = await this.mocState.freeDoc();
              mocHelper.assertBigDollar(
                freeDoc,
                scenario.expect.initialFreeDocs,
                'wrong amount of free doc'
              );
            });
            describe(`AND a user drops ${scenario.params.docsToDrop}`, function() {
              beforeEach(async function() {
                if (scenario.params.docsToDrop) {
                  await mocHelper.doc.transfer(
                    otherAccount,
                    toContractBN(scenario.params.docsToDrop * mocHelper.MOC_PRECISION),
                    {
                      from: userAccount
                    }
                  );
                }
              });
              it(`THEN the user has ${scenario.params.docsToMint -
                scenario.params.docsToDrop} BPro`, async function() {
                const docBalance = await mocHelper.getDoCBalance(userAccount);
                mocHelper.assertBigDollar(
                  docBalance,
                  scenario.params.docsToMint - scenario.params.docsToDrop,
                  'user has wrong amount of docs'
                );
              });
              describe(`AND ${scenario.params.docsToRedeem} docs are redeemed`, function() {
                beforeEach(async function() {
                  userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
                  redeemTx = await mocHelper.redeemFreeDoc({
                    userAccount,
                    docAmount: scenario.params.docsToRedeem,
                    vendorAccount
                  });
                  usedGas = await mocHelper.getTxCost(redeemTx);
                });
                it(`THEN the redeemers BTC balance is increased by redeeming only ${scenario.expect.docsToRedeem} docs`, async function() {
                  const currentBalance = toContractBN(await web3.eth.getBalance(userAccount));
                  mocHelper.assertBig(
                    userBtcBalance,
                    currentBalance
                      .sub(
                        mocHelper.RESERVE_PRECISION.mul(
                          toContractBN(scenario.expect.docsToRedeem)
                        ).div(toContractBN(scenario.params.initialBtcPrice))
                      )
                      .add(usedGas),
                    'incorrect amount of BTC sent to user',
                    { significantDigits: -14 }
                  );
                });
                it('THEN redeemers DoC balance is decreased', async function() {
                  const docBalance = await mocHelper.getDoCBalance(userAccount);
                  mocHelper.assertBigDollar(
                    docBalance,
                    scenario.expect.docBalanceAfterRedeem,
                    'wrong amount of doc burnt after redeem'
                  );
                });
                it(`THEN ${scenario.expect.docsToRedeem} DoCs are burnt`, async function() {
                  const transferEvent = mocHelper.findEvents(redeemTx, 'Transfer')[0];
                  mocHelper.assertBigDollar(
                    transferEvent.value,
                    scenario.expect.docsToRedeem,
                    'Incorrect amount of DoCs burnt'
                  );
                  assert(
                    transferEvent.to === '0x0000000000000000000000000000000000000000',
                    'DoCs werent burnt'
                  );
                  assert(
                    transferEvent.from === userAccount,
                    'DoCs were burnt from the wrong address'
                  );
                });
                it('THEN a FreeStableTokenRedeem event is logged', async function() {
                  const freeDocRedeemEvent = mocHelper.findEvents(
                    redeemTx,
                    'FreeStableTokenRedeem'
                  )[0];
                  mocHelper.assertBigDollar(
                    freeDocRedeemEvent.amount,
                    scenario.expect.docsToRedeem,
                    'wrong amount of docs redeemed'
                  );
                  mocHelper.assertBigRBTC(
                    freeDocRedeemEvent.reserveTotal,
                    scenario.expect.docsToRedeem / scenario.params.initialBtcPrice,
                    'wrong amount of btc sent to redeemer'
                  );
                  mocHelper.assertBigRBTC(
                    freeDocRedeemEvent.reservePrice,
                    scenario.params.initialBtcPrice,
                    'wrong btc price set on event'
                  );
                });
                it('THEN a regular StableTokenRedeem event is not logged', function() {
                  const docRedeemEvents = mocHelper.findEvents(redeemTx, 'StableTokenRedeem');
                  assert(
                    docRedeemEvents.length === 0,
                    'a doc redeem event was generated on a free doc redeem'
                  );
                });
                it(`THEN free docs are decreased by ${scenario.expect.docsToRedeem}`, async function() {
                  const freeDoc = await this.mocState.freeDoc();
                  mocHelper.assertBigDollar(
                    freeDoc,
                    scenario.expect.freeDocsAfterRedeem,
                    'wrong amount of free doc'
                  );
                });
              });
            });
          });
        });
      });
    });
  });
});
