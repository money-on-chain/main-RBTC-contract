const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

contract('MoC: MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Commission rates for test are set in functionHelper.js
    await mocHelper.mockMocInrateChanger.setCommissionRates(
      await mocHelper.getCommissionsArrayNonZero()
    );

    // set commissions address
    await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('Calculate commissions with prices', function() {
    const scenarios = [
      {
        params: {
          btcPrice: 10000,
          mocPrice: 10000,
          mocAmount: 1000,
          btcAmount: 1000
        },
        expect: {
          commissionAmountRbtc: 0, // rate: 0.001
          commissionAmountMoC: 7 // rate: 0.007
        }
      },
      {
        params: {
          btcPrice: 10000,
          mocPrice: 10000,
          mocAmount: 0,
          btcAmount: 1000
        },
        expect: {
          commissionAmountRbtc: 1, // rate: 0.001
          commissionAmountMoC: 0 // rate: 0.007
        }
      },
      {
        params: {
          btcPrice: 10000,
          mocPrice: 5000,
          mocAmount: 1000,
          btcAmount: 1000
        },
        expect: {
          commissionAmountRbtc: 0, // rate: 0.001
          commissionAmountMoC: 14 // rate: 0.007
        }
      },
      {
        params: {
          btcPrice: 5000,
          mocPrice: 10000,
          mocAmount: 1000,
          btcAmount: 1000
        },
        expect: {
          commissionAmountRbtc: 0, // rate: 0.001
          commissionAmountMoC: 3.5 // rate: 0.007
        }
      },
      {
        params: {
          btcPrice: 5000,
          mocPrice: 10000,
          mocAmount: 0,
          btcAmount: 1000
        },
        expect: {
          commissionAmountRbtc: 1, // rate: 0.001
          commissionAmountMoC: 0 // rate: 0.007
        }
      }
    ];

    scenarios.forEach(async scenario => {
      describe(`GIVEN BTC price is ${scenario.params.btcPrice}, MoC price is ${scenario.params.mocPrice} and MoC allowance is ${scenario.params.mocAmount}`, function() {
        let btcCommission;
        let mocCommission;

        beforeEach(async function() {
          // Set BTC price
          await mocHelper.setBitcoinPrice(scenario.params.btcPrice * mocHelper.MOC_PRECISION);

          // Set MoC price
          await mocHelper.setMoCPrice(scenario.params.mocPrice * mocHelper.MOC_PRECISION);

          await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
          await mocHelper.approveMoCToken(
            mocHelper.moc.address,
            scenario.params.mocAmount,
            userAccount
          );
          // Set transaction types
          const txTypeFeesRBTC = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
          const txTypeFeesMOC = await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();

          ({
            btcCommission,
            mocCommission
          } = await mocHelper.mocExchange.calculateCommissionsWithPrices(
            userAccount,
            toContractBN(scenario.params.btcAmount * mocHelper.MOC_PRECISION),
            txTypeFeesMOC,
            txTypeFeesRBTC
          ));
        });
        it(`THEN the commission amount in RBTC of ${scenario.expect.commissionAmountRbtc} is correct`, async function() {
          mocHelper.assertBigRBTC(
            btcCommission,
            scenario.expect.commissionAmountRbtc,
            'Commission amount in RBTC is incorrect'
          );
        });
        it(`THEN the commission amount in MoC of ${scenario.expect.commissionAmountMoC} is correct`, async function() {
          mocHelper.assertBigRBTC(
            mocCommission,
            scenario.expect.commissionAmountMoC,
            'Commission amount in MoC is incorrect'
          );
        });
      });
    });
  });
});
