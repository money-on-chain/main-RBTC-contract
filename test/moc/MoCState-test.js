const testHelperBuilder = require('../mocHelper.js');

let mocHelper;

const BUCKET_C0 = web3.utils.asciiToHex('C0', 32);
contract('MoC', function([owner, vendorAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.mocState = mocHelper.mocState;
    this.moc = mocHelper.moc;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('State variables', function() {
    let contractReadyState;

    const baseState = {
      nBPro: 0,
      nDoCs: 0,
      initialnB: 0,
      btcPrice: { from: 10000, to: 10000 },
      nDocsBtcAmount: 0,
      bproBtcAmount: 0
    };

    const states = [
      {
        ...baseState,
        nDoCs: 10000,
        initialnB: 5,
        btcPrice: { from: 10000, to: 5000 },
        nDocsBtcAmount: 1,
        expect: {
          globals: { globalLockedBitcoin: 2, globalCoverage: 3, globalMaxDoc: 0 },
          C0: { leverage: 1.5, coverage: 3 }
        }
      },
      {
        ...baseState,
        nDoCs: 12000,
        initialnB: 2.4,
        btcPrice: { from: 10000, to: 1000 },
        nDocsBtcAmount: 1.2,
        expect: {
          globals: { globalLockedBitcoin: 12, globalCoverage: 0.3, globalMaxDoc: 0 },
          C0: { leverage: '∞', lockedBitcoin: 12, coverage: 0.3 }
        }
      },
      // FIXME 2: Breaks after mocHelper fix
      /* {
        ...baseState,
        btcPrice: { from: 10000, to: 4000 },
        expect: {
          globals: { globalLockedBitcoin: 0, globalCoverage: '∞' },
          C0: { lockedBitcoin: 0, leverage: 1, coverage: '∞' },
          X2: { coverage: 0, leverage: '∞' }
        }
      }, */
      {
        ...baseState,
        nDoCs: 10000,
        initialnB: 6,
        btcPrice: { from: 10000, to: 5000 },
        nDocsBtcAmount: 1,
        expect: { globals: { globalMaxDoc: 2500 } }
      },
      {
        ...baseState,
        nBPro: 10,
        bproBtcAmount: 10,
        expect: {
          globals: { globalMaxBPro: 10, bproTecPrice: 1 },
          C0: { maxBPro: 10 }
        }
      },
      {
        ...baseState,
        nBPro: 10,
        // This makes BMA and BTC price to be different
        btcPrice: { from: 10000, to: 16000 },
        bproBtcAmount: 10,
        expect: {
          globals: { globalMaxBPro: 10, bproTecPrice: 1 },
          C0: { maxBPro: 10 }
        }
      },
      {
        ...baseState,
        nBPro: 10,
        nDoCs: 25000,
        initialnB: 10,
        nDocsBtcAmount: 2.5,
        bproBtcAmount: 10,
        expect: {
          globals: { globalMaxBPro: 7.5, bproTecPrice: 2 },
          C0: { maxBPro: 7.5 }
        }
      },
      {
        ...baseState,
        nBPro: 10,
        nDoCs: 25000,
        initialnB: 5,
        nDocsBtcAmount: 2.5,
        bproBtcAmount: 10,
        expect: {
          globals: { globalMaxBPro: 6.666666666666667, bproTecPrice: 1.5 },
          C0: {
            maxBPro: 6.666666666666667,
            coverage: 7,
            leverage: 1.1666666666666668
          }
        }
      },
      {
        ...baseState,
        nDoCs: 12000,
        initialnB: 2.4,
        btcPrice: { from: 10000, to: 1000 },
        nDocsBtcAmount: 1.2,
        expect: {
          globals: { globalCoverage: 0.3, bproTecPrice: '0.000000000000000001' },
          C0: { lockedBitcoin: 12, coverage: 0.3 }
        }
      }
    ];

    states.forEach(state => {
      describe(`GIVEN there are ${state.nDoCs} Docs`, function() {
        const totalBalance = state.initialnB + state.nDocsBtcAmount + state.bproBtcAmount;
        describe(`AND total balance is ${Math.round(totalBalance)} RBTC`, function() {
          const { from, to } = state.btcPrice;
          describe(`WHEN BTC Price moves from ${from} to ${to} USD`, function() {
            beforeEach(async function() {
              contractReadyState = mocHelper.getContractReadyState(state);
              await mocHelper.setBitcoinPrice(contractReadyState.btcPrice.from);
              // Original nB
              await this.moc.sendTransaction({
                value: contractReadyState.initialnB
              });

              // For simplifying BMA calculation.
              // It will be always the middle between the two values.
              await mocHelper.setSmoothingFactor(0.5 * 10 ** 18);

              if (state.nDoCs) {
                await mocHelper.mintDoc(owner, state.nDocsBtcAmount, vendorAccount);
              }

              if (state.nBPro) {
                await mocHelper.mintBPro(owner, state.bproBtcAmount, vendorAccount);
              }

              await mocHelper.setBitcoinPrice(contractReadyState.btcPrice.to);
            });

            Object.keys(state.expect).forEach(async function(scope) {
              Object.keys(state.expect[scope]).forEach(async function(key) {
                const friendlyExpected =
                  state.expect[scope][key] === '∞' ? '∞' : Math.round(state.expect[scope][key]);
                it(`THEN ${key} should be ${friendlyExpected}`, async function() {
                  const fn = this.mocState[key];
                  const newScope = scope === 'C0' ? BUCKET_C0 : scope;
                  const actual = await (scope === 'globals' ? fn() : fn(newScope));
                  mocHelper.assertBig(actual, contractReadyState.expect[scope][key], undefined, {
                    significantDigits: 15
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
