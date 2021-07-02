const { BigNumber } = require('bignumber.js');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
let BUCKET_C0;

contract('MoC : MoCExchange', function([owner, userAccount, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_C0, BUCKET_X2 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocInrate = mocHelper.mocInrate;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('GIVEN a user owns 5, BProxs', function() {
    let c0InitialState;
    let x2InitialState;
    let initialRbtcBalance;
    beforeEach(async function() {
      // Set days to settlement to calculate interests
      await this.mocState.setDaysToSettlement(5 * mocHelper.DAY_PRECISION);
      await mocHelper.mintBProAmount(userAccount, 10, vendorAccount);
      await mocHelper.mintDocAmount(userAccount, 50000, vendorAccount);

      await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, 5, vendorAccount);

      initialRbtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
      c0InitialState = await mocHelper.getBucketState(BUCKET_C0);
      x2InitialState = await mocHelper.getBucketState(BUCKET_X2);
    });
    const scenarios = [
      {
        description:
          'User tries to redeem more than his balance. Should redeem only his total balance and receive the complete inrate bag value. BTC Price gos up',
        params: {
          btcPrice: 10800,
          nBProx: 10
        },
        expect: {
          nB: 10,
          nDoCs: 50000,
          nBProx: 0,
          redeemed: {
            nB: '5.37037037037037037'
          },
          interest: {
            nB: '0.0'
          }
        }
      },
      {
        description:
          'User tries to redeem more than his balance. Should redeem only his total balance. BTC Price does not change',
        params: {
          btcPrice: 9800,
          nBProx: 10
        },
        expect: {
          nB: 10,
          nDoCs: 50000,
          nBProx: 0,
          redeemed: {
            nB: '4.897959183673465'
          },
          interest: {
            nB: '0.0'
          }
        }
      },
      {
        description:
          'User redeem less than his balance. Should redeem what he requests. BTC Price does not change',
        params: {
          btcPrice: 10000,
          nBProx: 3
        },
        expect: {
          nB: 6,
          nDoCs: 30000,
          nBProx: 2,
          redeemed: {
            nB: '3'
          },
          interest: {
            nB: '0.0'
          }
        }
      },
      {
        description:
          'User redeem less than his balance. BTC Price falls to 8000, should receive RBTC according to the price',
        params: {
          btcPrice: 8000,
          nBProx: 3
        },
        expect: {
          nB: 6,
          nDoCs: 30000,
          nBProx: 2,
          redeemed: {
            nB: '2.25'
          },
          interest: {
            nB: '0.0'
          }
        }
      },
      {
        description:
          'User redeem less than his balance, BTC Price rises to 12500, should receive RBTC according to the price',
        params: {
          // Leverage 1.666
          btcPrice: 12500,
          nBProx: 3
        },
        expect: {
          // (BProx price = 1.2) * 3 * leverage
          nB: 6,
          // (BProx price = 1.2) * 3 * (leverage-1) * BTCPrice
          nDoCs: 29999.9999999999999625,
          nBProx: 2,
          redeemed: {
            nB: '3.6'
          },
          interest: {
            nB: '0.0'
          }
        }
      }
    ];

    scenarios.forEach(async s => {
      let params;
      let txCost;
      let finalRbtcBalance;
      let c0FinalState;
      let x2FinalState;
      let tx;
      describe(`WHEN BTC Price ${s.params.btcPrice} AND he tries to redeem ${s.params.nBProx} BProx `, function() {
        beforeEach(async function() {
          ({ params } = await mocHelper.getContractReadyState(s));
          await mocHelper.setBitcoinPrice(params.btcPrice);

          tx = await mocHelper.redeemBProx(userAccount, BUCKET_X2, s.params.nBProx, vendorAccount);

          finalRbtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          txCost = await mocHelper.getTxCost(tx);
          c0FinalState = await mocHelper.getBucketState(BUCKET_C0);
          x2FinalState = await mocHelper.getBucketState(BUCKET_X2);
        });
        it('THEN the event is emitted with correct values', async function() {
          const [btcxRedeemEvent] = mocHelper.findEvents(tx, 'RiskProxRedeem');

          mocHelper.assertBigRBTC(
            btcxRedeemEvent.interests,
            s.expect.interest.nB,
            'Interests in event is incorrect',
            { significantDigits: 15 }
          );
          mocHelper.assertBigRBTC(
            btcxRedeemEvent.reserveTotal,
            s.expect.redeemed.nB,
            'Btc total in event is incorrect',
            { significantDigits: 15 }
          );
        });
        it(`THEN his bprox balance decrease in ${s.expect.nBProx}`, async function() {
          const finalBProxBalance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);

          mocHelper.assertBigRBTC(finalBProxBalance, s.expect.nBProx, undefined);
        });
        it(`AND he receives ${s.expect.redeemed.nB} RBTCs for the redeem + ${s.expect.interest.nB} from interests`, async function() {
          const diff = finalRbtcBalance.sub(initialRbtcBalance).add(txCost);
          const expected = new BigNumber(s.expect.redeemed.nB).plus(s.expect.interest.nB);
          mocHelper.assertBigRBTC(diff, expected, 'The amount of BPros received is incorrect', {
            significantDigits: 15
          });
        });
        it(`AND BProx in bucket X2 decrease to ${s.expect.nBProx}`, async function() {
          mocHelper.assertBigRBTC(
            x2FinalState.nBPro,
            s.expect.nBProx,
            'The BProx balance in X2 is incorrect'
          );
        });
        it(`AND X2 RBTC decreases in ${s.expect.nB}`, async function() {
          const diff = x2InitialState.nB.sub(x2FinalState.nB);

          mocHelper.assertBigRBTC(diff, s.expect.nB, 'X2 RBTC amount is incorrect', {
            significantDigits: 15
          });
        });
        it('AND C0 Docs increases', async function() {
          const diff = c0FinalState.nDoc.sub(c0InitialState.nDoc);

          mocHelper.assertBigDollar(diff, s.expect.nDoCs, 'C0 Docs amount is incorrect', {
            significantDigits: 15
          });
        });
        it('AND X2 Docs decreases', async function() {
          const diff = x2InitialState.nDoc.sub(x2FinalState.nDoc);

          mocHelper.assertBigDollar(diff, s.expect.nDoCs, 'X2 Docs amount is incorrect', {
            significantDigits: 15
          });
        });
        it('AND the inrateBag decrease', async function() {
          const diff = c0InitialState.inrateBag.sub(c0FinalState.inrateBag);

          mocHelper.assertBigDollar(diff, s.expect.interest.nB, 'inrateBag does not decrease', {
            significantDigits: 15
          });
        });
      });
    });
  });
});
