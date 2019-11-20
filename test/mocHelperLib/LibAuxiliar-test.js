const MoCHelperLib = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper');

let mocHelperLib;
let mocHelper;
let contractReadyState;
let toContractBN;

contract('MoCHelperLib: Auxiliar functions', function([owner]) {
  before(async function() {
    mocHelperLib = await MoCHelperLib.new();
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
  });

  describe('Leverage calculation', function() {
    const states = [
      {
        nB: 1,
        leverage: 2,
        expect: {
          nB: 1
        }
      },
      {
        nB: 0.2,
        leverage: 1.2,
        expect: {
          nB: 0.04
        }
      }
    ];
    states.forEach(state => {
      describe(`GIVEN nB is ${state.nB} and leverage is ${state.leverage}`, function() {
        beforeEach(function() {
          contractReadyState = mocHelper.getContractReadyState(state);
        });
        it(`THEN the amount of BTC to move from C0 to X2 is ${state.expect.nB}`, async function() {
          const { nB, leverage, expect } = contractReadyState;
          const transferAmount = await mocHelperLib.bucketTransferAmount(
            toContractBN(nB),
            toContractBN(leverage)
          );
          mocHelper.assertBig(transferAmount, expect.nB, 'Transfer amount is not correct');
        });
      });
    });
    describe('GIVEN leverage is 1', function() {
      beforeEach(function() {
        contractReadyState = mocHelper.getContractReadyState({ nB: 1, leverage: 1 });
      });
      it('THEN the transaction should revert', async function() {
        const { nB, leverage } = contractReadyState;
        const tx = mocHelperLib.bucketTransferAmount(toContractBN(nB), toContractBN(leverage));
        await expectRevert.unspecified(tx);
      });
    });
    describe('GIVEN leverage is infinite', function() {
      it('THEN the amount of BTC to move from C0 to X2 is 0', async function() {
        const { nB } = mocHelper.getContractReadyState({ nB: 1 });
        const transferAmount = await mocHelperLib.bucketTransferAmountInfiniteLeverage(
          toContractBN(nB),
          toContractBN(0)
        );
        mocHelper.assertBig(transferAmount, 0, 'Transfer amount is not 0');
      });
    });
    describe('GIVEN leverage almost infinite', function() {
      it('THEN the amount of BTC to move from C0 to X2 is 0', async function() {
        const { nB } = mocHelper.getContractReadyState({ nB: 1 });
        const transferAmount = await mocHelperLib.bucketTransferAmountInfiniteLeverage(
          toContractBN(nB),
          toContractBN(nB)
        );
        mocHelper.assertBig(transferAmount, 0, 'Transfer amount is not 0');
      });
    });
  });
});
