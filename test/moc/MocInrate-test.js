// const MoCInrate = artifacts.require('./contracts/MoCInrate.sol');
// const MoCLibConnection = artifacts.require('./contracts/MoCLibConnection.sol');
// const MoCHelperLibMock = artifacts.require('./contracts/mocks/MoCHelperLibMock.sol');
const MoCCommissionRates = artifacts.require('./contracts/MoCCommissionRates.sol');
const MoCCommissionRatesByTxType = artifacts.require('./contracts/MoCCommissionRatesByTxType.sol');
const MocInrateChangerCommFees = artifacts.require('./contracts/MocInrateChangerCommFees.sol');

const testHelperBuilder = require('../mocHelper.js');
let mocHelper;

const scenario = {
    rbtcAmount: 20,
    commissionRate: 0.2,
    commissionAmount: 4,
};

// const randomHex = web3.utils.randomHex;

contract('MoCInrate', function([owner]) {
  before(async function() {
    //this.mocInrate = await MoCCommissionRates.new();

    this.mocCommissionRates = await MoCCommissionRates.new();
    this.commissionRates = [
      { txType: (await this.mocCommissionRates.MINT_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('1') },
      { txType: (await this.mocCommissionRates.REDEEM_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('2')},
      { txType: (await this.mocCommissionRates.MINT_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('3') },
      { txType: (await this.mocCommissionRates.REDEEM_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('4') },
      { txType: (await this.mocCommissionRates.MINT_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('5') },
      { txType: (await this.mocCommissionRates.REDEEM_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('6') },
      { txType: (await this.mocCommissionRates.MINT_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('7') },
      { txType: (await this.mocCommissionRates.REDEEM_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('8') },
      { txType: (await this.mocCommissionRates.MINT_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('9') },
      { txType: (await this.mocCommissionRates.REDEEM_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('10')},
      { txType: (await this.mocCommissionRates.MINT_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('11') },
      { txType: (await this.mocCommissionRates.REDEEM_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('12') },
    ];
    this.mocCommissionRatesByTxType = await MoCCommissionRatesByTxType.new(this.commissionRates);

    // New test
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.mocInrate = mocHelper.mocInrate;
    this.commisionRatesArray = [
      { txType: (await this.mocInrate.MINT_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('1') },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(), fee: web3.utils.toWei('2')},
      { txType: (await this.mocInrate.MINT_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('3') },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_RBTC()).toString(), fee: web3.utils.toWei('4') },
      { txType: (await this.mocInrate.MINT_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('5') },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(), fee: web3.utils.toWei('6') },
      { txType: (await this.mocInrate.MINT_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('7') },
      { txType: (await this.mocInrate.REDEEM_BPRO_FEES_MOC()).toString(), fee: web3.utils.toWei('8') },
      { txType: (await this.mocInrate.MINT_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('9') },
      { txType: (await this.mocInrate.REDEEM_DOC_FEES_MOC()).toString(), fee: web3.utils.toWei('10')},
      { txType: (await this.mocInrate.MINT_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('11') },
      { txType: (await this.mocInrate.REDEEM_BTCX_FEES_MOC()).toString(), fee: web3.utils.toWei('12') },
    ];
    this.governor = mocHelper.governor;
    this.mocInrateChangerCommFees = await MocInrateChangerCommFees.new(
      this.mocInrate.address,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      this.commisionRatesArray,
      { from: owner }
    );

    console.log("Governor address: " + this.governor.address);
    await this.mocInrateChangerCommFees.transferOwnership(this.governor.address);
    /*
    this.mocHelperLibMock = await MoCHelperLibMock.new();
    await MoCLibConnection.link(MoCHelperLibMock, this.mocHelperLibMock.address);
    this.mocLibConnection = await MoCLibConnection.new();
    this.mocInrate = await MoCInrate.new();
    await this.mocInrate.initialize(
        this.mocLibConnection.address,
        randomHex(20),
        0,
        0,
        0,
        0,
        0,
        owner,
        owner,
        web3.utils.toWei(scenario.commissionRate.toString()),
        0,
        0,
        0
      );
      */
  });

  /*
  describe.only(`GIVEN an RBTC amount for mint/redeem operations of ${scenario.rbtcAmount}`, function() {
    it(`THEN calculate total value from which apply the Commission rate of ${scenario.commissionRate}`, async function() {
      console.log("Commision rate: " + await this.mocInrate.getCommissionRate());
      await this.mocInrate.setCommissionRate(web3.utils.toWei((scenario.commissionRate + 2).toString()));
      console.log("Commision rate: " + await this.mocInrate.getCommissionRate());
      const newCommissionAmount = await this.mocInrate.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()));
      console.log("New commission amount: " + newCommissionAmount + "; to ether: " + web3.utils.fromWei(newCommissionAmount));
      mocHelper.assertBig(
        newCommissionAmount,
        web3.utils.toWei(scenario.commissionAmount.toString()),
        `Commission amount should be ${web3.utils.toWei(scenario.commissionAmount.toString())}`
      );
    });
  });
  */

  /*
  describe.only(`GIVEN an RBTC amount for mint/redeem operations of ${scenario.rbtcAmount}`, function() {
    it(`THEN calculate total value from which apply the Commission rate of ${scenario.commissionRate}`, async function() {
      console.log("Commision rate: " + await this.mocInrate.getCommissionRate());
      await  this.mockMocInrateChanger.setCommissionRate(web3.utils.toWei((scenario.commissionRate + 2).toString()));
      await this.governor.executeChange(this.mockMocInrateChanger.address);
      console.log("Commision rate: " + await this.mocInrate.getCommissionRate());
      const newCommissionAmount = await this.mocInrate.calcCommissionValue(web3.utils.toWei(scenario.rbtcAmount.toString()));
      console.log("New commission amount: " + newCommissionAmount + "; to ether: " + web3.utils.fromWei(newCommissionAmount));
      mocHelper.assertBig(
        newCommissionAmount,
        web3.utils.toWei(scenario.commissionAmount.toString()),
        `Commission amount should be ${web3.utils.toWei(scenario.commissionAmount.toString())}`
      );
    });
  });
  */

  // describe.only(`COMMISSION RATES BY TRANSACTION`, function() {
  //   it(`Set and read value`, async function() {
  //     //await this.governor.executeChange(this.mockMocInrateChanger.address);
  //     await this.mocInrate.initializeCommissionRates();
  //     for(var i = 1; i <= 12; i++) {
  //       // var commissionValue = (i * 10 / 100) * 10 ** 18;
  //       // await  this.mockMocInrateChanger.setCommissionRateByTxType(i, commissionValue.toString());
  //       const newCommisionRateByType = await this.mocInrate.getCommissionRateByTxType(i);
  //       console.log(`Commission rate ${i}: ${newCommisionRateByType}`);
  //     }
  //     const newCommisionRateByTypeConst = await this.mocInrate.getCommissionRateByTxType(await this.mocInrate.MINT_BTCX_FEES_RBTC());
  //     console.log(`Commission rate constant MINT_BTCX_FEES_RBTC: ${newCommisionRateByTypeConst}`);
  //     // mocHelper.assertBig(
  //     //   newCommissionAmount,
  //     //   web3.utils.toWei(scenario.commissionAmount.toString()),
  //     //   `Commission amount should be ${web3.utils.toWei(scenario.commissionAmount.toString())}`
  //     // );
  //   });
  // });

  // describe.only(`COMMISSION RATES BY TRANSACTION WITH NEW CONTRACT`, function() {
  //   it(`Set and read value`, async function() {
  //     for(var i = 1; i <= 12; i++) {
  //       const newCommisionRateByType = await this.mocCommissionRatesByTxType.getCommissionRateByTxType(i);
  //       console.log(`Commission rate ${i}: ${newCommisionRateByType}`);
  //     }
  //     const newCommisionRateByTypeConst = await this.mocCommissionRatesByTxType.getCommissionRateByTxType(await this.mocCommissionRates.MINT_BTCX_FEES_RBTC());
  //     console.log(`Commission rate constant MINT_BTCX_FEES_RBTC: ${newCommisionRateByTypeConst}`);
  //   });
  // });

  describe.only(`COMMISSION RATES BY TRANSACTION`, function() {
    it(`Set and read value`, async function() {
      console.log("Owner: " + owner);
      await this.governor.executeChange(this.mocInrateChangerCommFees.address);
      console.log("Owner: " + owner);
      // Get a test value
      const newCommisionRateByTypeConst = await this.mocInrate.commissionRatesByTxType(await this.mocInrate.MINT_BTCX_FEES_RBTC());
      console.log(`Commission rate constant MINT_BTCX_FEES_RBTC: ${newCommisionRateByTypeConst}`);
      // Get all the values
      for (var rate of this.commisionRatesArray){
        const newCommisionRateByType = await this.mocInrate.commissionRatesByTxType(rate.txType);
        console.log(`Commission rate ${rate.txType}: ${newCommisionRateByType}`);
      } 
    });
  });
});
