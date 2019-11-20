const MoCHelperLib = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const testHelperBuilder = require('../mocHelper');

let mocHelperLib;
let mocHelper;
let toContractBN;

contract('MoCHelperLib:  Coverage-Leverage', function([owner]) {
  before(async function() {
    mocHelperLib = await MoCHelperLib.new();
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
  });

  describe('Leverage calculation', function() {
    const states = [
      {
        nB: 0,
        lB: 0,
        expect: {
          leverage: 1
        }
      },
      {
        nB: 1,
        lB: 0,
        expect: {
          leverage: 1
        }
      },
      {
        nB: 5,
        lB: 2,
        expect: {
          leverage: 1.6666666666666668
        }
      },
      {
        nB: 1,
        lB: 5,
        expect: {
          leverage: '∞'
        }
      },
      {
        nB: 1,
        lB: 1,
        expect: {
          leverage: '∞'
        }
      },
      {
        nB: 0,
        lB: 1,
        expect: {
          leverage: '∞'
        }
      },
      {
        // Extreme values still holds lev = 1
        nB: 21 * 10 ** 6, // 21M: Max Bitcoins ever to be mined
        lB: 1 / 10 ** 18, // 1 wei Locket
        expect: {
          leverage: 1
        }
      }
    ];
    states.forEach(state => {
      describe(`GIVEN nB is ${state.nB} and lB is ${state.lB}`, function() {
        let contractReadyState;
        before(function() {
          contractReadyState = mocHelper.getContractReadyState(state);
        });
        it(`THEN leverage calculation using nB and lB should be ${state.expect.leverage}`, async function() {
          const { nB, lB, expect } = contractReadyState;
          const leverage = await mocHelperLib.leverage(toContractBN(nB), toContractBN(lB));
          mocHelper.assertBig(
            leverage,
            expect.leverage,
            `Expected leverage(${leverage.toString()}) to be ${expect.leverage}`,
            { significantDigits: 15 }
          );
        });
        it(`THEN leverage calculation using coverage should be ${state.expect.leverage}`, async function() {
          const { nB, lB, expect } = contractReadyState;
          const coverage = await mocHelperLib.coverage(toContractBN(nB), toContractBN(lB));
          const leverage = await mocHelperLib.leverageFromCoverage(toContractBN(coverage));
          mocHelper.assertBig(
            leverage,
            expect.leverage,
            `Expected leverage(${leverage.toString()}) to be ${expect.leverage}`,
            { significantDigits: 13 }
          );
        });
      });
    });
  });
});
