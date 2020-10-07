const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

const { BN } = web3.utils;

// const util = require('util'); 

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = `sender·doesn't·have·enough·funds·to·send·tx`;

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

    // Commission rates are set in contractsBuilder.js

    // set commissions address
    await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('BPro rediming with commissions', function() {
    const scenarios = [
      // RBTC commission
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 0
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 99.8, // (bproToRedeem) - (bproToRedeem * commissionRate)
          commissionAmountRbtc: 0.2, // (bproToMint * REDEEM_BPRO_FEES_RBTC = 0.002)
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 0
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0.1,  // (bproToMint * REDEEM_BPRO_FEES_RBTC = 0.002)
          bproToRedeemOnRBTC: 49.9, // (bproToRedeem) - (bproToRedeem * commissionRate)
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      // MoC commission
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 1000
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 100,
          commissionAmountRbtc: 0,
          commissionAmountMoC: 0.8, // (mocAmount * REDEEM_BPRO_FEES_MOC = 0.008)
          mocAmount: 998.5  // mocAmount - (mocAmount * MINT_BPRO_FEES_MOC) = 1000 - 0.007 = 999.3
                            // => 999.3 - (mocAmount * REDEEM_BPRO_FEES_MOC)
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 1000
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0,
          bproToRedeemOnRBTC: 50,
          commissionAmountMoC: 0.4, // (bproToMint * REDEEM_BPRO_FEES_MOC = 0.008)
          mocAmount: 998.9  // mocAmount - (mocAmount * MINT_BPRO_FEES_MOC) = 1000 - 0.007 = 999.3
                            // => 999.3 - (mocAmount * REDEEM_BPRO_FEES_MOC)
        }
      }
    ];

    scenarios.forEach(async (scenario, i) => {
      describe(`WHEN he tries to redeem ${scenario.params.bproToRedeem} BPros`, function() {
        let initialBProBalance;
        let prevCommissionAccountBalance;
        let prevUserBtcBalance;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let tx;
        let txCost;

        beforeEach(async function() {
          //await mocHelper.revertState();

          // Commission rates are set in contractsBuilder.js

          // set commissions address
          //await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
          // update params
          //await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

          await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
          await mocHelper.approveMoCToken(
            mocHelper.moc.address,
            scenario.params.mocAmount,
            userAccount
          );
          // Mint according to scenario
          const txTypeMint =
            scenario.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          await mocHelper.mintBProAmount(
            userAccount,
            scenario.params.bproToMint,
            txTypeMint
          );
          // Calculate balances before redeeming
          initialBProBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionAccountBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          tx = await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);
          txCost = toContractBN(await mocHelper.getTxCost(tx));



          // console.log("SCENARIO " + i);

          // console.log(util.inspect(scenario, false, null, true));

          // console.log("initialBProBalance: ", initialBProBalance.toString());
          // console.log("prevCommissionAccountBalance: ", prevCommissionAccountBalance.toString());
          // console.log("prevUserBtcBalance: ", prevUserBtcBalance.toString());
          // console.log("prevUserMoCBalance: ", prevUserMoCBalance.toString());
          // console.log("prevCommissionsAccountMoCBalance: ", prevCommissionsAccountMoCBalance.toString());
        });

        it(`THEN the user has ${scenario.expect.bproToRedeemOnRBTC} more rbtc`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = userBtcBalance.sub(prevUserBtcBalance).add(txCost);

          // console.log("userBtcBalance: ", userBtcBalance.toString());
          // console.log("diff: ", diff.toString());
          // console.log("txCost: ", txCost.toString());

          // console.log("TESTING SCENARIO " + i);

          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToRedeemOnRBTC,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN he receives only the max redeem amount', async function() {
          //await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);

          const bproBalance = await mocHelper.getBProBalance(userAccount);
          const balanceDiff = initialBProBalance.sub(bproBalance);

          // console.log("TESTING SCENARIO " + i);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.bproRedeemed,
            'The redemption bpro amount was incorrect'
          );
        });
        it(`THEN commission account balance increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          //await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);

          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const balanceDiff = btcBalance.sub(prevCommissionAccountBalance);

          // console.log("TESTING SCENARIO " + i);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.commissionAmountRbtc,
            'The commission account balance is incorrect'
          );
        });
        it(`THEN the user MoC balance has decreased by ${scenario.expect.commissionAmountMoC} MoCs by commissions`, async function() {
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diffAmount = new BN(prevUserMoCBalance).sub(
            new BN(web3.utils.toWei(scenario.expect.commissionAmountMoC.toString()))
          );
          const diffCommission = prevUserMoCBalance.sub(userMoCBalance);

          // console.log("userMoCBalance: ", userMoCBalance.toString());
          // console.log("diffAmount: ", diffAmount.toString());
          // console.log("diffCommission: ", diffCommission.toString());
          // console.log("TESTING SCENARIO " + i);

          mocHelper.assertBigRBTC(
            diffAmount,
            scenario.expect.mocAmount,
            'user MoC balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffCommission,
            scenario.expect.commissionAmountMoC,
            'MoC commission is incorrect'
          );
        });
        it(`THEN the commissions account MoC balance has increased by ${scenario.expect.commissionAmountMoC} MoCs`, async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);

          // console.log("TESTING SCENARIO " + i);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountMoC,
            'commissions account MoC balance is incorrect'
          );
        });
      });
    });
    describe.only('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to redeem BPros with no MoC allowance, THEN commission is paid in RBTC', async function() {
        const mocAmountToMint = 1000;
        const mocAmountToApprove = 0;
        const rbtcExpectedBalance = 0;
        await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
        await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
        const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
        const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
        const tx = await mocHelper.redeemBPro(userAccount, 10);
        const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
        const diffMoC = prevUserMoCBalance.sub(userMoCBalance);
        const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
        const usedGas = toContractBN(await mocHelper.getTxCost(tx));
        const diffRbtc = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);

        // console.log("prevUserBtcBalance: ", prevUserBtcBalance.toString());
        // console.log("userBtcBalance: ", userBtcBalance.toString());
        // console.log("usedGas: ", usedGas.toString());

        //await expectRevert.unspecified(tx);
        // calcular que lo haya pagado con rbtc porque no tiene moc (que no haya gastado los 1000 moc minteados porque no tiene allowance)
        // Check that the used paid in RBTC because MoC allowance is 0
        mocHelper.assertBigRBTC(
          diffMoC,
          mocAmountToApprove,
          'user MoC balance is incorrect'
        );

        mocHelper.assertBigRBTC(
          diffRbtc,
          rbtcExpectedBalance,
          'user RBTC balance is incorrect'
        );
      });
    });
    // hacer uno que tenga allowance pero que no tenga moc

    // tiene que fallar porque no tiene bpro para redimir
    describe.only('GIVEN since the user does not have MoC nor BPro balance, but there is MoC allowance', function() {
      it('WHEN a user tries to redeem BPros, THEN expect exception', async function() {
        const password = '!@superpassword';
        const failingAddress = await web3.eth.personal.newAccount(password);
        await web3.eth.personal.unlockAccount(failingAddress, password, 600);
        // User does not have BPro to redeem

        try {
          // await web3.eth.sendTransaction({
          //   from: owner,
          //   to: failingAddress,
          //   value: '10000000000000'
          // });
          await mocHelper.mintMoCToken(failingAddress, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
          const tx = await mocHelper.redeemBPro(failingAddress, 10);
          assert(
            tx === null,
            'This should not happen'
          );
        } catch (err) {
          //console.log(err);
          assert(
            err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
            'Sender does not have enough funds'
          );
        }
      });
    });
  });
});
