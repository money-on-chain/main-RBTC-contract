const MoCHelperLib = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper');

let mocHelperLib;
let mocHelper;
let toContractBN;
let getContractReadyState;

contract('MoCHelperLib: Inrate', function([owner]) {
  before(async function() {
    mocHelperLib = await MoCHelperLib.new();
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN, getContractReadyState } = mocHelper);
  });

  describe('Integral function', function() {
    let baseParams;
    beforeEach(function() {
      baseParams = getContractReadyState({
        tMin: 0,
        tMax: 0.0002611578760678,
        power: 1
      });
    });
    describe('WHEN value to test is 1', function() {
      it('THEN integral should be 0.0001305789380339', async function() {
        const integralValue = await mocHelperLib.integral(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX')
        );
        // This function should be internal and returns [MAX][MAX] precision
        const actual = integralValue.div(mocHelper.MOC_PRECISION);
        mocHelper.assertBigRate(actual, 0.0001305789380339, 'Integral value is incorrect');
      });
    });
    describe('WHEN value to test is 0', function() {
      it('THEN integral should be 0', async function() {
        const integralValue = await mocHelperLib.integral(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX')
        );
        // This function should be internal and returns [MAX][MAX] precision
        const actual = integralValue.div(mocHelper.MOC_PRECISION);
        mocHelper.assertBigRate(actual, 0, 'Integral value is incorrect');
      });
    });
    describe('WHEN value to test is 0.3', function() {
      it('THEN integral should be 0.3', async function() {
        const integralValue = await mocHelperLib.integral(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.3, 'MAX')
        );
        // This function should be internal and returns [MAX][MAX] precision
        const actual = integralValue.div(mocHelper.MOC_PRECISION);
        mocHelper.assertBigRate(actual, 0.000011752104423051, 'Integral value is incorrect');
      });
    });
  });

  describe('SpotInrate function', function() {
    let baseParams;
    beforeEach(function() {
      baseParams = getContractReadyState({
        tMin: 0,
        tMax: 0.0002611578760678,
        power: 1
      });
    });
    describe('WHEN value to test is 1', function() {
      it('THEN spotInrate should be 0', async function() {
        const inrate = await mocHelperLib.spotInrate(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX')
        );
        mocHelper.assertBigRate(inrate, 0, 'Interest rate to settlement is incorrect');
      });
    });
    describe('WHEN value to test is 0', function() {
      it('THEN spotInrate should be 0.0002611578760678', async function() {
        const inrate = await mocHelperLib.spotInrate(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.0002611578760678,
          'Interest rate to settlement is incorrect'
        );
      });
    });
  });

  describe('Potential function', function() {
    let baseParams;
    beforeEach(function() {
      baseParams = getContractReadyState({
        tMin: 0,
        tMax: 0.0002611578760678,
        power: 1
      });
    });
    describe('WHEN value to test is 1', function() {
      it('THEN potential should be 0.0002611578760678', async function() {
        const inrate = await mocHelperLib.potential(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.0002611578760678,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN value to test is 0', function() {
      it('THEN potential should be 0', async function() {
        const inrate = await mocHelperLib.potential(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX')
        );
        mocHelper.assertBigRate(inrate, 0, 'Interest rate to settlement is incorrect');
      });
    });
    describe('WHEN value to test is 0.3', function() {
      it('THEN potential should be 0.00007834736282034', async function() {
        const inrate = await mocHelperLib.potential(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.3, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.00007834736282034,
          'Interest rate to settlement is incorrect'
        );
      });
    });
  });

  describe('AvgInt function', function() {
    let baseParams;
    beforeEach(function() {
      baseParams = getContractReadyState({
        tMin: 0,
        tMax: 0.0002611578760678,
        power: 1
      });
    });
    describe('WHEN values to test are 0 and 1', function() {
      // This function use values complementary to one
      it('THEN AvgInt should be 0.1', async function() {
        const inrate = await mocHelperLib.avgInt(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX'),
          toContractBN(1, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.0001305789380339,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN values to test are 1 and 0.3', function() {
      it('THEN AvgInt should revert', async function() {
        const inrate = mocHelperLib.avgInt(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX'),
          toContractBN(0.3, 'MAX')
        );
        await expectRevert.unspecified(inrate);
      });
    });
    describe('WHEN value to test are 0.3 and 0.3', function() {
      it('THEN should revert', async function() {
        const inrate = mocHelperLib.avgInt(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.3, 'MAX'),
          toContractBN(0.3, 'MAX')
        );

        await expectRevert.unspecified(inrate);
      });
    });
    describe('WHEN value to test are 0.3 and 1', function() {
      it('THEN AvgInt should be 0', async function() {
        const inrate = await mocHelperLib.avgInt(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.3, 'MAX'),
          toContractBN(1, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.00016975261944407,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN value to test are 0 and 0.7', function() {
      it('THEN AvgInt should be 0', async function() {
        const inrate = await mocHelperLib.avgInt(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX'),
          toContractBN(0.7, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.00009140525662373,
          'Interest rate to settlement is incorrect'
        );
      });
    });
  });

  describe('inrateAvg function', function() {
    let baseParams;
    beforeEach(function() {
      baseParams = getContractReadyState({
        tMin: 0,
        tMax: 0.0002611578760678,
        power: 1
      });
    });
    describe('WHEN value to test are 1 and 1', function() {
      it('THEN inrateAvg should be 0', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX'),
          toContractBN(1, 'MAX')
        );

        mocHelper.assertBigRate(inrate, 0, 'Interest rate to settlement is incorrect');
      });
    });
    describe('WHEN values to test are 0.7 and 0', function() {
      // This function use values complementary to one
      it('THEN inrateAvg should be 0.1', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.7, 'MAX'),
          toContractBN(0, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.00016975261944407,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN initial abundance ratio is 0 and final 0.7', function() {
      it('THEN inrateAvg should be 0.00016975261944407', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX'),
          toContractBN(0.7, 'MAX')
        );

        mocHelper.assertBigRate(
          inrate,
          0.00016975261944407,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN value to test are 0.7 and 0.7', function() {
      it('THEN inrateAvg should be 0.00007834736282034', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0.7, 'MAX'),
          toContractBN(0.7, 'MAX')
        );

        mocHelper.assertBigRate(
          inrate,
          0.00007834736282034,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN value to test are 0 and 1', function() {
      it('THEN inrateAvg should be 0', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(0, 'MAX'),
          toContractBN(1, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.0001305789380339,
          'Interest rate to settlement is incorrect'
        );
      });
    });
    describe('WHEN value to test are 1 and 0', function() {
      it('THEN inrateAvg should be 0', async function() {
        const inrate = await mocHelperLib.inrateAvg(
          toContractBN(baseParams.tMax),
          toContractBN(baseParams.power),
          toContractBN(baseParams.tMin),
          toContractBN(1, 'MAX'),
          toContractBN(0, 'MAX')
        );
        mocHelper.assertBigRate(
          inrate,
          0.0001305789380339,
          'Interest rate to settlement is incorrect'
        );
      });
    });
  });

  describe('inrateAvg moving Power parameter test', function() {
    let baseParams;
    describe('WHEN values to test are 0 and 1', function() {
      const scenarios = [
        {
          power: 1,
          expect: 0.0001305789380339
        },
        {
          power: 4,
          expect: 0.00005223157521356
        },
        {
          power: 8,
          expect: 0.000029017541785311
        }
      ];
      scenarios.forEach(scenario => {
        beforeEach(function() {
          baseParams = getContractReadyState({
            tMin: 0,
            tMax: 0.0002611578760678
          });
        });

        // This function use values complementary to one
        it(`WHEN power is ${scenario.power} THEN AvgInt should be ${scenario.expect}`, async function() {
          const inrate = await mocHelperLib.avgInt(
            toContractBN(baseParams.tMax),
            toContractBN(scenario.power),
            toContractBN(baseParams.tMin),
            toContractBN(0, 'MAX'),
            toContractBN(1, 'MAX')
          );

          mocHelper.assertBigRate(
            inrate,
            scenario.expect,
            'Interest rate to settlement is incorrect'
          );
        });
      });
    });
  });

  describe('inrateAvg moving parameters test', function() {
    describe('WHEN values to test are 0 and 1', function() {
      const scenarios = [
        {
          tMin: 0,
          tMax: 0.0002611578760678,
          power: 1,
          expect: {
            inrate: 0.0001305789380339
          }
        },
        {
          tMin: 0,
          tMax: 0.0002611578760678,
          power: 4,
          expect: {
            inrate: 0.00005223157521356
          }
        },
        {
          tMin: 0,
          tMax: 0.0002611578760678,
          power: 8,
          expect: {
            inrate: 0.000029017541785311
          }
        },
        {
          tMin: 0.0002611578760678,
          tMax: 0.0002611578760678,
          power: 8,
          expect: {
            inrate: '0.000290175417853111' // We can't user javascript number with this precision
          }
        },
        {
          tMin: 0.0001305789380339,
          tMax: 0.0002611578760678,
          power: 8,
          expect: {
            inrate: '0.000159596479819211' // We can't user javascript number with this precision
          }
        }
      ];
      scenarios.forEach(s => {
        it(`WHEN power is ${s.power} THEN AvgInt should be ${s.expect.inrate}`, async function() {
          const scenario = getContractReadyState(s);
          const inrate = await mocHelperLib.avgInt(
            toContractBN(scenario.tMax),
            toContractBN(scenario.power),
            toContractBN(scenario.tMin),
            toContractBN(0, 'MAX'),
            toContractBN(1, 'MAX')
          );

          mocHelper.assertBig(
            inrate,
            scenario.expect.inrate,
            'Interest rate to settlement is incorrect'
          );
        });
      });
    });
  });
});
