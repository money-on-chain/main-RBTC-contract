const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

contract('MoC: MoCExchange', function([
  owner,
  userAccount,
  commissionsAccount,
  vendorAccount1,
  vendorAccount2
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendors for test
    await mocHelper.registerVendor(vendorAccount1, 0.01, owner);
    await mocHelper.registerVendor(vendorAccount2, 0.002, owner);

    // Commission rates for test are set in functionHelper.js
    await this.mockMocInrateChanger.setCommissionRates(
      await mocHelper.getCommissionsArrayNonZero()
    );

    // set commissions address
    await this.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await this.governor.executeChange(mocHelper.mockMocInrateChanger.address);
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
          commissionAmountMoC: 7, // rate: 0.007
          markupAmountRbtc: 0,
          markupAmountMoC: 10
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
          commissionAmountMoC: 0, // rate: 0.007
          markupAmountRbtc: 10,
          markupAmountMoC: 0
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
          commissionAmountMoC: 14, // rate: 0.007
          markupAmountRbtc: 0,
          markupAmountMoC: 20
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
          commissionAmountMoC: 3.5, // rate: 0.007
          markupAmountRbtc: 0,
          markupAmountMoC: 5
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
          commissionAmountMoC: 0, // rate: 0.007
          markupAmountRbtc: 10,
          markupAmountMoC: 0
        }
      }
    ];

    scenarios.forEach(async scenario => {
      describe(`GIVEN BTC price is ${scenario.params.btcPrice}, MoC price is ${scenario.params.mocPrice} and MoC allowance is ${scenario.params.mocAmount}`, function() {
        let btcCommission;
        let mocCommission;
        let btcMarkup;
        let mocMarkup;

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

          const params = {
            account: userAccount,
            amount: toContractBN(scenario.params.btcAmount * mocHelper.MOC_PRECISION).toString(),
            txTypeFeesMOC: txTypeFeesMOC.toString(),
            txTypeFeesRBTC: txTypeFeesRBTC.toString(),
            vendorAccount: vendorAccount1
          };

          ({
            btcCommission,
            mocCommission,
            btcMarkup,
            mocMarkup
          } = await mocHelper.mocExchange.calculateCommissionsWithPrices(params, { from: owner }));
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
        it(`THEN the markup amount in RBTC of ${scenario.expect.markupAmountRbtc} is correct`, async function() {
          mocHelper.assertBigRBTC(
            btcMarkup,
            scenario.expect.markupAmountRbtc,
            'Markup amount in RBTC is incorrect'
          );
        });
        it(`THEN the markup amount in MoC of ${scenario.expect.markupAmountMoC} is correct`, async function() {
          mocHelper.assertBigRBTC(
            mocMarkup,
            scenario.expect.markupAmountMoC,
            'Markup amount in MoC is incorrect'
          );
        });
      });
    });
  });
});
