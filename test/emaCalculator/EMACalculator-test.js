const testHelperBuilder = require('../mocHelper');

let mocHelper;
let toContractBN;
const factorPrecision = 10 ** 18;

contract('MoC: MoCState', function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.mocState = mocHelper.mocState;
  });

  describe('EMA calculation period', function() {
    before(async function() {
      await mocHelper.revertState();
    });
    describe('GIVEN the EMA calculation period is 50 blocks and BTC price is set', function() {
      let initialEMA;
      before(async function() {
        await this.mocState.getLastEmaCalculation();
        await mocHelper.mockMocStateChanger.setEmaCalculationBlockSpan(toContractBN(50));
        await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
        await mocHelper.setBitcoinPrice(toContractBN(5000 * mocHelper.MOC_PRECISION));
        initialEMA = await this.mocState.getBitcoinMovingAverage();
      });
      describe('WHEN BTC price is set before 50 blocks', function() {
        before(async function() {
          await mocHelper.setBitcoinPrice(toContractBN(1000 * mocHelper.MOC_PRECISION));
        });
        it('THEN EMA calculation is not necessary', async function() {
          const shouldCalculate = await this.mocState.shouldCalculateEma();
          assert(!shouldCalculate, 'EMA calculation is not needed');
        });
        describe('AND calculate EMA is called', function() {
          before(async function() {
            await this.mocState.calculateBitcoinMovingAverage();
          });
          it('THEN EMA stays the same', async function() {
            const finalEMA = await this.mocState.getBitcoinMovingAverage();
            mocHelper.assertBig(finalEMA, initialEMA, 'EMA Changed');
          });
        });
      });
      describe('WHEN BTC price is set after 40 blocks and EMA calculation is called', function() {
        let tx;
        before(async function() {
          await mocHelper.waitNBlocks(40);
          await mocHelper.setBitcoinPrice(toContractBN(1000 * mocHelper.MOC_PRECISION));
          tx = await this.mocState.calculateBitcoinMovingAverage();
        });
        it('THEN EMA event is emitted', function() {
          const bmaEvents = mocHelper.findEvents(tx, 'MovingAverageCalculation');
          assert(bmaEvents.length === 1, 'EMA calculation event was not emitted');
        });
        it('AND EMA change', async function() {
          const finalEMA = await this.mocState.getBitcoinMovingAverage();
          finalEMA.should.be.bignumber.not.equal(initialEMA, 'EMA did not Change');
        });
      });
    });
  });

  describe('EMA 120 calculation', function() {
    before(async function() {
      await mocHelper.revertState();
    });
    describe('GIVEN the bma calculation period is 1 block and the period 120', function() {
      before(async function() {
        const sm = 2 / (120 + 1);
        await mocHelper.mockMocStateChanger.setEmaCalculationBlockSpan(1);
        await mocHelper.mockMocStateChanger.setSmoothingFactor(toContractBN(1 * factorPrecision));
        await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);

        await mocHelper.setBitcoinPrice(toContractBN(123.25983 * mocHelper.MOC_PRECISION));
        await mocHelper.mocState.calculateBitcoinMovingAverage();
        await mocHelper.mockMocStateChanger.setSmoothingFactor(toContractBN(sm * factorPrecision));
        await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
      });

      const states = [
        { btcPrice: 125.58083, movingAverage: '123.298193636363626531' },
        { btcPrice: 100.81083, movingAverage: '122.926501675431996146' },
        { btcPrice: 116.967, movingAverage: '122.827997515507500334' },
        { btcPrice: 121.17883, movingAverage: '122.800738548309029252' }
      ];

      states.forEach(async state => {
        describe(`WHEN the user set a price of ${state.btcPrice}`, function() {
          before(async function() {
            await mocHelper.setBitcoinPrice(toContractBN(state.btcPrice * mocHelper.MOC_PRECISION));
            await this.mocState.calculateBitcoinMovingAverage();
          });
          it(`THEN the new EMA is ${state.movingAverage}`, async function() {
            const ema = await this.mocState.getBitcoinMovingAverage();
            mocHelper.assertBigDollar(ema, state.movingAverage, 'EMA is incorrect');
          });
        });
      });
    });
  });

  describe('Extreme EMA calculation', function() {
    const states = [
      {
        btcPrice: 12000,
        smoothingFactor: 0.6,
        ema: 11200
      },
      {
        btcPrice: 13000,
        smoothingFactor: 1,
        ema: 13000
      },
      {
        btcPrice: 12000,
        smoothingFactor: 0,
        ema: 10000
      }
    ];

    states.forEach(state => {
      describe('GIVEN the initial price is 10000 and the bma calculation period is 1 block', function() {
        describe(`AND the weighting decrease coefficient value is ${state.smoothingFactor}`, function() {
          describe(`WHEN the user set a price of ${state.btcPrice}`, function() {
            beforeEach(async function() {
              await mocHelper.revertState();
              await mocHelper.mockMocStateChanger.setEmaCalculationBlockSpan(1);
              await mocHelper.mockMocStateChanger.setSmoothingFactor(
                toContractBN(state.smoothingFactor * factorPrecision)
              );
              await mocHelper.governor.executeChange(mocHelper.mockMocStateChanger.address);
              await mocHelper.setBitcoinPrice(
                toContractBN(state.btcPrice * mocHelper.MOC_PRECISION)
              );
              await mocHelper.mocState.calculateBitcoinMovingAverage();
            });
            it(`THEN the new price is ${state.btcPrice} cents`, async function() {
              const price = await mocHelper.getBitcoinPrice();
              mocHelper.assertBigDollar(toContractBN(price), state.btcPrice, 'Price is incorrect');
            });
            it(`THEN the new EMA is ${state.ema}`, async function() {
              const ema = await this.mocState.getBitcoinMovingAverage();
              mocHelper.assertBigDollar(ema, state.ema, 'EMA is incorrect');
            });
          });
        });
      });
    });
  });
});
