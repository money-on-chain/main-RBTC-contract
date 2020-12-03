const testHelperBuilder = require('../mocHelper.js');
const BigNumber = require('bignumber.js');
const { toContract, toBigNumber } = require('../../utils/numberHelper');
const { BN, isBN } = web3.utils;

let mocHelper;
let toContractBN;

// const scenario = {
//   params: {
//     markup: 1000,
//     staking: 500,
//     totalPaidInMoC: 1000,
//     mocAmount: 10000
//   },
//   expect: {
//     staking: 500
//   }
// };

contract('MoC: MoCVendors', function([owner, userAccount, commissionsAccount, unauthorizedAccount, nonExistentVendorAccount, vendorAccount1, vendorAccount2]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.mocVendors = mocHelper.mocVendors;
    this.mockMoCVendorsChanger = mocHelper.mockMoCVendorsChanger;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;

    await mocHelper.revertState();
  });
  beforeEach(async function() {
    // // Commission rates for test are set in functionHelper.js
    // await mocHelper.mockMocInrateChanger.setCommissionRates(
    //   await mocHelper.getCommissionsArrayNonZero()
    // );

    // // set commissions address
    // await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // // update params
    // await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });
  describe.only('GIVEN vendors can integrate their platforms with MoC protocol', function() {

    const scenarios = [
      // Vendor 1
      {
        params: {
          account: vendorAccount1,
          markup: 0.1,
          staking: 0.001, // (btcPrice * (mintAmount * MINT_BPRO_FEES_RBTC) / mocPrice) * markup
          //totalPaidInMoC: 1000,
          mocAmount: 10000,
          mintAmount: 10
        },
        expect: {
          staking: 0.001
        }
      },
      // Vendor 2
      // {
      //   params: {
      //     account: vendorAccount2,
      //     markup: 1000,
      //     staking: 500,
      //     //totalPaidInMoC: 1000,
      //     mocAmount: 10000,
      //     mintAmount: 0
      //   },
      //   expect: {
      //     staking: 500
      //   }
      // }
      // Vendor 3
      // staking = -1?
    ];




    //let vendorsToRegister;

    // before(async function() {
    //   vendorsToRegister = await mocHelper.getVendorsToRegisterArray();
    //   console.log("vendorsToRegister: ", vendorsToRegister);
    // });

    scenarios.forEach(async scenario => {

      let registerVendorTx;
      let mintTx;
      let addStakeTx;
      let removeStakeTx;

      let unregisterVendorTx;
  
      let vendor_in_mapping;
  
      before(async function() {
        //await mocHelper.revertState();
  
        //for (let i = 1; i < vendorsToRegister.length; i++) {
          await mocHelper.mintMoCToken(scenario.params.account, scenario.params.mocAmount, owner);
          await mocHelper.approveMoCToken(
            this.mocVendors.address,
            scenario.params.mocAmount,
            scenario.params.account
          );
        //}
  
        const vendorToRegister = {
          account: scenario.params.account,
          markup: toContract(scenario.params.markup * mocHelper.MOC_PRECISION).toString()
        };

        //console.log("vendorToRegister: ", vendorToRegister);
        //// Vendors for test are set in functionHelper.js
        await this.mockMoCVendorsChanger.setVendorsToRegister([vendorToRegister]);

        registerVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);

        // Commission rates for test are set in functionHelper.js
        await mocHelper.mockMocInrateChanger.setCommissionRates(
          await mocHelper.getCommissionsArrayNonZero()
        );

        // set commissions address
        await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
        // update params
        await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

        const commissionRate = await mocHelper.mocInrate.commissionRatesByTxType(new BN(1));
        console.log("commissionRate: ", commissionRate.toString());

        const convertedamount = await mocHelper.mocConverter.btcToMoCWithPrice('10011000000000000000', '10000000000000000000000', '10000000000000000000000');
        console.log("convertedamount: ", convertedamount.toString());

        // Make a transaction so that the vendor has something to remove from staking
        mintTx = await mocHelper.mintBProAmount(
          userAccount,
          scenario.params.mintAmount,
          scenario.params.account
        );


        //await this.governor.contract.methods.executeChange(loQueVayaDeParams).call()

        //console.log("mintTx: ", mintTx);

        const [testEvent] = await mocHelper.findEvents(
          mintTx,
          'Test'
        );

        console.log("testEvent: ", testEvent);

        const [riskProMintEvent] = await mocHelper.findEvents(
          mintTx,
          'RiskProMint'
        );

        console.log("riskProMintEvent: ", riskProMintEvent);

      });
      it('WHEN a vendor is registered THEN VendorRegistered event is emitted', async function() {
        const [vendorRegisteredEvent] = await mocHelper.findEvents(
          registerVendorTx,
          'VendorRegistered'
        );
  
        console.log("vendorRegisteredEvent: ", vendorRegisteredEvent);
  
        assert(vendorRegisteredEvent, 'Event was not emitted');
        assert(vendorRegisteredEvent.account === scenario.params.account, 'Vendor account is incorrect');
      });
      it('WHEN a vendor adds staking THEN VendorStakeAdded event is emitted', async function() {
        addStakeTx = await this.mocVendors.addStake(
          toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
          { from: scenario.params.account }
        );
  
        const [vendorStakeAddedEvent] = await mocHelper.findEvents(addStakeTx, 'VendorStakeAdded');
  
        assert(vendorStakeAddedEvent, 'Event was not emitted');
        assert(vendorStakeAddedEvent.account === scenario.params.account, 'Vendor account is incorrect');
        mocHelper.assertBigRBTC(
          vendorStakeAddedEvent.staking,
          scenario.expect.staking,
          'Should increase by staking'
        );
      });
      it('WHEN a vendor removes staking THEN VendorStakeRemoved event is emitted', async function() {
  
        vendor_in_mapping = await this.mocVendors.vendors(scenario.params.account);
        console.log(vendor_in_mapping);
  
        removeStakeTx = await this.mocVendors.removeStake(
          toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
          { from: scenario.params.account }
        );
  
        const [vendorStakeRemovedEvent] = await mocHelper.findEvents(
          removeStakeTx,
          'VendorStakeRemoved'
        );
  
        console.log("vendorStakeRemovedEvent: ", vendorStakeRemovedEvent);
  
        assert(vendorStakeRemovedEvent, 'Event was not emitted');
        assert(vendorStakeRemovedEvent.account === scenario.params.account, 'Vendor account is incorrect');
        mocHelper.assertBigRBTC(
          vendorStakeRemovedEvent.staking,
          scenario.expect.staking,
          'Should decrease by staking'
        );
      });

    });




    // before(async function() {
    //   // Vendors for test are set in functionHelper.js
    //   await this.mockMoCVendorsChanger.setVendorsToUnregister(
    //     await mocHelper.getVendorsToUnregisterArray()
    //   );
    //   unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
    // });
    // it('WHEN a vendor is unregistered THEN VendorUnregistered event is emitted', async function() {
    //   const [vendorUnregisteredEvent] = await mocHelper.findEvents(
    //     unregisterVendorTx,
    //     'VendorUnregistered'
    //   );

    //   assert(vendorUnregisteredEvent, 'Event was not emitted');
    //   assert(vendorUnregisteredEvent.account === vendorAccount, 'Vendor account is incorrect');
    // });
    // // Unauthorized account
    // describe('GIVEN an unauthorized account tries to make changes', function() {

    //   before(async function() {
    //     unregisterVendorTx = await this.mocVendors.unregisterVendor(vendorAccount, { from: unauthorizedAccount });
    //   });
    //   it('WHEN an unauthorized account tries to unregister a vendor THEN an error should be raised', async function() {
    //     const [vendorUnregisteredEvent] = await mocHelper.findEvents(
    //       unregisterVendorTx,
    //       'VendorUnregistered'
    //     );

    //     // change to catch error

    //     assert(vendorUnregisteredEvent, 'Event was not emitted');
    //     assert(vendorUnregisteredEvent.account === vendorAccount, 'Vendor account is incorrect');
    //   });
    // });
  });
});
