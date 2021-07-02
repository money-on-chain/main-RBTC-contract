const MoCHelperLib = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const testHelperBuilder = require('../mocHelper.js');

let mocHelperLib;
let mocHelper;
let toContractBN;

contract('MoCHelperLib: BProDiscount', function([owner]) {
  before(async function() {
    mocHelperLib = await MoCHelperLib.new();
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
  });
  describe('BProSpotDiscountRate', function() {
    const states = [
      {
        discount: 0.1,
        liq: 1.1,
        utpdu: 1.6,
        coverage: 1.4,
        expect: {
          discount: 0.04
        }
      },
      {
        discount: 0.2,
        liq: 1,
        utpdu: 2,
        coverage: 1.5,
        expect: {
          discount: 0.1
        }
      },
      {
        discount: 0.2,
        liq: 1,
        utpdu: 2,
        coverage: 1.6,
        expect: {
          discount: 0.08
        }
      },
      {
        discount: 0.2,
        liq: 1,
        utpdu: 2,
        coverage: 1.8,
        expect: {
          discount: 0.04
        }
      },
      {
        discount: 0.2,
        liq: 1,
        utpdu: 2,
        coverage: 1,
        expect: {
          discount: 0.2
        }
      }
    ];
    states.forEach(state => {
      describe(`GIVEN the liquidationDiscountRate is ${state.discount}, liq is ${state.liq},
      utpdu is ${state.utpdu} and cov is ${state.coverage}`, function() {
        it(`THEN spot discount rate should be ${state.expect.discount}`, async function() {
          const { discount, liq, utpdu, coverage, expect } = mocHelper.getContractReadyState(state);
          const spotDiscount = await mocHelperLib.bproSpotDiscountRate(
            toContractBN(discount),
            toContractBN(liq),
            toContractBN(utpdu),
            toContractBN(coverage)
          );

          mocHelper.assertBig(spotDiscount, expect.discount);
        });
      });
    });
  });
  describe('Max BPro with discount available', function() {
    const states = [
      {
        params: {
          nB: 1,
          nDoCs: 10000,
          utpdu: 2,
          peg: 1,
          btcPrice: 10000,
          bproUsdPrice: 8000,
          discount: 0.2
        },
        expect: {
          nBPro: 1.5625
        }
      },
      {
        // Not possible scenario in practice. This occurs with coverage below 1
        params: {
          nB: 1,
          nDoCs: 1000,
          utpdu: 2,
          peg: 1,
          btcPrice: 10000,
          bproUsdPrice: 8000,
          discount: 0.2
        },
        expect: {
          nBPro: 0
        }
      },
      {
        // Should not be possible in practice. This occurs with Cov over utpdu
        params: {
          nB: 1,
          nDoCs: 1000,
          utpdu: 2,
          peg: 1,
          btcPrice: 10000,
          bproUsdPrice: 8000,
          discount: 0
        },
        expect: {
          nBPro: 0
        }
      }
    ];
    states.forEach(state => {
      let { params, expect } = state;
      describe(`GIVEN the parameters are nB:${params.nB},nDoc: ${params.nDoCs},utpdu: ${params.utpdu},discount: ${params.discount},peg: ${params.peg},btcPrice: ${params.btcPrice}`, function() {
        it(`THEN max BProWithDiscount should be ${expect.nBPro}`, async function() {
          ({ params, expect } = mocHelper.getContractReadyState(state));

          const maxBProWithDiscount = await mocHelperLib.maxBProWithDiscount(
            toContractBN(params.nB),
            toContractBN(params.nDoCs),
            toContractBN(params.utpdu),
            toContractBN(params.peg),
            toContractBN(params.btcPrice),
            toContractBN(params.bproUsdPrice),
            toContractBN(params.discount)
          );

          mocHelper.assertBig(maxBProWithDiscount, expect.nBPro);
        });
      });
    });
  });
});
