const MoCHelperLib = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const testHelperBuilder = require('../mocHelper.js');

let mocHelperLib;
let mocHelper;
let toContractBN;

contract('MoCHelperLib: MaxBProxCalculation', function([owner]) {
  before(async function() {
    mocHelperLib = await MoCHelperLib.new();
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
  });

  describe('MaxBProxCalculation', function() {
    const states = [
      {
        nDoCs: 10000,
        peg: 1,
        btcPrice: 10000,
        leverage: 1,
        expect: {
          maxBPro: 0
        }
      },
      {
        nDoCs: 0,
        peg: 1,
        btcPrice: 10000,
        leverage: 1,
        expect: {
          maxBPro: 0
        }
      },
      {
        nDoCs: 100000,
        peg: 1,
        btcPrice: 10000,
        leverage: 2,
        expect: {
          maxBPro: 10
        }
      },
      {
        nDoCs: 100000,
        peg: 1,
        btcPrice: 10000,
        leverage: '∞',
        delta: 0,
        expect: {
          maxBPro: 0
        }
      },
      {
        nDoCs: 100000,
        peg: 1,
        btcPrice: 10000,
        leverage: '∞',
        delta: 1000000, // Moves INFINIT down
        expect: {
          maxBPro: 0
        }
      }
    ];
    states.forEach(state => {
      describe(`GIVEN nDoc is ${state.nDoCs}, peg is ${state.peg},
      btcPrice is ${state.btcPrice} and leverage is ${state.leverage}`, function() {
        it(`THEN maxBProx should be ${state.expect.maxBPro}`, async function() {
          const { nDoCs, peg, btcPrice, leverage, expect } = mocHelper.getContractReadyState(state);
          const nDoCsBN = toContractBN(nDoCs);
          const pegBN = toContractBN(peg);
          const btcPriceBN = toContractBN(btcPrice);
          const leverageBN = toContractBN(leverage);
          const maxBProxPromise =
            state.leverage === '∞'
              ? mocHelperLib.maxBProxBtcValueInfiniteLeverage(
                  nDoCsBN,
                  pegBN,
                  btcPriceBN,
                  state.delta
                )
              : mocHelperLib.maxBProxBtcValue(nDoCsBN, pegBN, btcPriceBN, leverageBN);
          mocHelper.assertBig(await maxBProxPromise, expect.maxBPro);
        });
      });
    });
  });
});
