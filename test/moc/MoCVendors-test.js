const { assert } = require('chai');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');
//const BigNumber = require('bignumber.js');
const { toContract, toBigNumber } = require('../../utils/numberHelper');
//const { BN, isBN } = web3.utils;

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

contract('MoC: MoCVendors', function([
  owner,
  userAccount,
  commissionsAccount,
  unauthorizedAccount,
  nonExistentVendorAccount,
  vendorAccount1,
  vendorAccount2,
  vendorAccount3,
  vendorAccount4
]) {
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
          staking: 1, // (btcPrice * (mintAmount * markup) / mocPrice)
          //totalPaidInMoC: 1000,
          mocAmount: 10000,
          mintAmount: 10,
          removeStakeMessage: 'WHEN a vendor removes staking of $STAKING$ THEN VendorStakeRemoved event is emitted'
        },
        expect: {
          totalPaidInMoC: 1,
          paidMoC: 0,
          paidRBTC: 1,
          staking: 1,
        }
      },
      // Vendor 2
      {
        params: {
          account: vendorAccount2,
          markup: 0.5,
          staking: 5,
          //totalPaidInMoC: 1000,
          mocAmount: 10000,
          mintAmount: 0,
          removeStakeMessage: 'WHEN a vendor cannot remove staking THEN revert is expected'
        },
        expect: {
          totalPaidInMoC: 0,
          paidMoC: 0,
          paidRBTC: 0,
          staking: 5
        }
      },
      // Vendor 3
      // {
      //   params: {
      //     account: vendorAccount3,
      //     markup: 0.1,
      //     staking: 0.001, // (btcPrice * (mintAmount * MINT_BPRO_FEES_RBTC) / mocPrice) * markup
      //     //totalPaidInMoC: 1000,
      //     mocAmount: 0,
      //     mintAmount: 10,
      //     removeStakeMessage: 'WHEN a vendor cannot remove staking THEN revert is expected'
      //   },
      //   expect: {
      //     totalPaidInMoC: 0,
      //     paidMoC: 0,
      //     paidRBTC: 0,
      //     staking: 0,
      //   }
      // },
      // Vendor 4
      // staking = -1?

    ];




    //let vendorsToRegister;

    // before(async function() {
    //   vendorsToRegister = await mocHelper.getVendorsToRegisterArray();
    //   console.log("vendorsToRegister: ", vendorsToRegister);
    // });

    scenarios.forEach(async scenario => {

      let registerVendorTx;
      //let mintTx;
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

        // const commissionRate = await mocHelper.mocInrate.commissionRatesByTxType(new BN(1));
        // console.log("commissionRate: ", commissionRate.toString());

        // const convertedamount = await mocHelper.mocConverter.btcToMoCWithPrice('10011000000000000000', '10000000000000000000000', '10000000000000000000000');
        // console.log("convertedamount: ", convertedamount.toString());

        // // Make a transaction so that the vendor has something to remove from staking
        // mintTx = await mocHelper.mintBProAmount(
        //   userAccount,
        //   scenario.params.mintAmount,
        //   scenario.params.account
        // );


        //await this.governor.contract.methods.executeChange(loQueVayaDeParams).call()



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
      it(`WHEN a vendor adds staking of ${scenario.params.staking} THEN VendorStakeAdded event is emitted`, async function() {
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
      it(`WHEN a user mints ${scenario.params.mintAmount} BPRO THEN the vendor receives his corresponding fee`, async function() {
        //if (scenario.params.mintAmount !== '0') {
          // Make a transaction so that the vendor has something to remove from staking
          //const mintTx = await mocHelper.mintBProAmount(
          await mocHelper.mintBProAmount(
            userAccount,
            scenario.params.mintAmount,
            scenario.params.account
          );

          // console.log("mintTx: ", mintTx);
          // const [testEvent] = await mocHelper.findEvents(
          //   mintTx,
          //   'Test'
          // );
          // console.log("testEvent: ", testEvent);
          // const [riskProMintEvent] = await mocHelper.findEvents(
          //   mintTx,
          //   'RiskProMint'
          // );
          // console.log("riskProMintEvent: ", riskProMintEvent);

          const totalPaidInMoC = await this.mocVendors.getTotalPaidInMoC(scenario.params.account);
          const paidMoC = await this.mocVendors.getPaidMoC(scenario.params.account);
          const paidRBTC = await this.mocVendors.getPaidRBTC(scenario.params.account);

          //console.log("totalPaidInMoC: ", totalPaidInMoC.toString());
          //console.log("paidMoC: ", paidMoC.toString());
          //console.log("paidRBTC: ", paidRBTC.toString());

          mocHelper.assertBigRBTC(
            totalPaidInMoC,
            scenario.expect.totalPaidInMoC,
            'totalPaidInMoC is incorrect'
          );

          mocHelper.assertBigRBTC(
            paidMoC,
            scenario.expect.paidMoC,
            'paidMoC is incorrect'
          );

          mocHelper.assertBigRBTC(
            paidRBTC,
            scenario.expect.paidRBTC,
            'paidRBTC is incorrect'
          );
        //}
      });
      
      it(scenario.params.removeStakeMessage.replace('$STAKING$', scenario.params.staking), async function() {
      //it(`WHEN a vendor can remove staking and removes staking of ${scenario.params.staking} THEN VendorStakeRemoved event is emitted; otherwise revert is expected`, async function() {

        try {
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

        } catch (err) {
          assert(
            err.reason === 'Vendor total paid is not enough',
            `Vendor ${scenario.params.account} should not be able to remove staking`
          );
        }

        // console.log("type: ", typeof scenario.params.mintAmount);
  
        // if (scenario.params.mintAmount !== 0) { // Vendor can remove staking
    

        // } else {  // expect error
        //   await expectRevert(removeStakeTx, 'Vendor total paid is not enough');
        // }
      });
      //describe('GIVEN there are not enough MoCs in system', function() {
        it('GIVEN there are not enough MoCs in system, WHEN a vendor tries to remove staking THEN expect revert', async function() {

          await mocHelper.approveMoCToken(
            this.mocVendors.address,
            0,
            scenario.params.account
          );
          
          vendor_in_mapping = await this.mocVendors.vendors(scenario.params.account);
          console.log(vendor_in_mapping);
          
          const removeStakeTx = await this.mocVendors.removeStake(
            toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
            { from: scenario.params.account }
          );
    
          await expectRevert(removeStakeTx, 'Not enough MoCs in system');
        });
      //});
      it('WHEN a vendor is unregistered THEN VendorUnregistered event is emitted', async function() {
        await this.mockMoCVendorsChanger.setVendorsToUnregister(
          [scenario.params.account]
        );
        unregisterVendorTx = await this.governor.executeChange(this.mockMoCVendorsChanger.address);
  
        const [vendorUnregisteredEvent] = await mocHelper.findEvents(
          unregisterVendorTx,
          'VendorUnregistered'
        );
  
        assert(vendorUnregisteredEvent, 'Event was not emitted');
        assert(vendorUnregisteredEvent.account === scenario.params.account, 'Vendor account is incorrect');
      });
      describe('GIVEN an inactive vendor tries to make changes', function() {
        it('WHEN an inactive vendor tries to add staking THEN an error should be raised', async function() {

          vendor_in_mapping = await this.mocVendors.vendors(scenario.params.account);
          console.log(vendor_in_mapping);
          

          addStakeTx = await this.mocVendors.addStake(
            toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
            { from: scenario.params.account }
          );
    
          await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
        });
        it('WHEN an inactive vendor tries to remove staking THEN an error should be raised', async function() {

          vendor_in_mapping = await this.mocVendors.vendors(scenario.params.account);
          console.log(vendor_in_mapping);
        
          
          removeStakeTx = await this.mocVendors.removeStake(
            toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
            { from: scenario.params.account }
          );
    
          await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
        });
      });
    });
  });
  describe.only('GIVEN an unauthorized account tries to make changes', function() {
    it('WHEN an unauthorized account tries to unregister a vendor THEN an error should be raised', async function() {
      const vendorToRegister = {
        account: vendorAccount3,
        markup: toContract(100 * mocHelper.MOC_PRECISION).toString()
      };

      let register_unath;

      try {
        register_unath = await this.mocVendors.registerVendor([vendorToRegister], { from: unauthorizedAccount });
      } catch (err) {
        console.log("err unauth: ", err);
        assert(
          err.message.search('not_authorized_changer') >= 0,
          `${unauthorizedAccount} should not be authorized to register a vendor`
        );
      }
    });
    it('WHEN an unauthorized account tries to unregister a vendor THEN an error should be raised', async function() {

      let unregister_unath;

      try {
        unregister_unath = await this.mocVendors.unregisterVendor([vendorAccount3], { from: unauthorizedAccount });
      } catch (err) {
        assert(
          err.reason === 'not_authorized_changer',
          `${unauthorizedAccount} should not be authorized to unregister a vendor`
        );
      }

      console.log("unregister_unath: ", unregister_unath);

    });
  });






  // describe.only('GIVEN an inactive vendor tries to make changes', function() {
  //   before(async function() {
  //     const vendorToRegister = {
  //       account: vendorAccount3,
  //       markup: toContract(0.1 * mocHelper.MOC_PRECISION).toString()
  //     };

  //     await this.mockMoCVendorsChanger.setVendorsToRegister([vendorToRegister]);
  //     await this.governor.executeChange(this.mockMoCVendorsChanger.address);

  //     let vendor_in_mapping;
  //     vendor_in_mapping = await this.mocVendors.vendors(vendorAccount3);
  //     console.log(vendor_in_mapping);

  //     await this.mockMoCVendorsChanger.setVendorsToUnregister([vendorAccount3]);
  //     await this.governor.executeChange(this.mockMoCVendorsChanger.address);

  //     vendor_in_mapping = await this.mocVendors.vendors(vendorAccount3);
  //     console.log(vendor_in_mapping);
  //   });
  //   it('WHEN an inactive vendor tries to add staking THEN an error should be raised', async function() {
  //     const addStakeTx = await this.mocVendors.addStake(
  //       toContractBN(100 * mocHelper.MOC_PRECISION),
  //       { from: vendorAccount3 }
  //     );

  //     await expectRevert(addStakeTx, 'Vendor is inexistent or inactive');
  //   });
  //   it('WHEN an inactive vendor tries to remove staking THEN an error should be raised', async function() {
  //     const removeStakeTx = await this.mocVendors.removeStake(
  //       toContractBN(scenario.params.staking * mocHelper.MOC_PRECISION),
  //       { from: scenario.params.account }
  //     );

  //     await expectRevert(removeStakeTx, 'Vendor is inexistent or inactive');
  //   });
  // });



  

});
