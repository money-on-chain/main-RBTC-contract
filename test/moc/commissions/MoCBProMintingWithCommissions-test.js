const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

const { BN } = web3.utils;

contract('MoC: MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    // this.mocToken = mocHelper.mocToken;

    // console.log("MoCToken owner: ", await this.mocToken.owner());
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Commission rates are set in contractsBuilder.js

    // set commissions address
    await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('BPro minting with commissions', function() {
    const scenarios = [
      { 
        params: {
          bproToMint: 1000,
          mocAmount: 0
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 1,  // (bproToMint * MINT_BPRO_FEES_RBTC = 0.001)
          totalCostOnBtc: 1001,
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      {
        params: {
          bproToMint: 1000,
          mocAmount: 1000
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 0,
          totalCostOnBtc: 1000,
          commissionAmountMoC: 7, // (bproToMint * MINT_BPRO_FEES_MOC = 0.007)
          mocAmount: 993
        }
      }
    ];
    scenarios.forEach(async scenario => {
      console.log("owner: ", owner);
      console.log("userAccount: ", userAccount);
      console.log("scenario.params.mocAmount: ", scenario.params.mocAmount);


      describe.only(`GIVEN ${scenario.params.bproToMint} BitPro are minted and ${scenario.params.mocAmount} MoC are available in user account`, function() {
        let prevUserBtcBalance;
        let prevUserBproBalance;
        let prevCommissionsAccountBtcBalance;
        let prevMocBtcBalance;
        let usedGas;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;

        beforeEach(async function() {
          // console.log("bpro bal");
          // prevUserBproBalance = await mocHelper.getBProBalance(userAccount);
          // prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          // prevCommissionsAccountBtcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          // prevMocBtcBalance = toContractBN(await web3.eth.getBalance(this.moc.address));
          // console.log("mint");
          // console.log("owner in func", owner);
          // await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
          // console.log("end mint");
          // console.log("resto");
          // prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          // prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          //const mintTx = await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint);
          //usedGas = toContractBN(await mocHelper.getTxCost(mintTx));
        });
        it(`THEN the user has ${scenario.expect.bproToMint} more BitPros`, async function() {
          const UserBproBalance = await mocHelper.getBProBalance(userAccount);
          const diff = UserBproBalance.sub(prevUserBproBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMint,
            'user bitPro balance is incorrect'
          );
        });
        it(`THEN the user rbtc balance has decrease by ${scenario.expect.bproToMintOnRbtc} Rbtcs by Mint + ${scenario.expect.commissionAmountRbtc} Rbtcs by commissions`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.totalCostOnBtc,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN global balance increases by the correct amount of BTCs', async function() {
          const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
          const diff = new BN(mocBtcBalance).sub(new BN(prevMocBtcBalance));

          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMintOnRbtc,
            'Should increase sale total amount'
          );
        });
        it(`THEN the commissions account rbtc balance has increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diff = commissionsAccountBtcBalance.sub(prevCommissionsAccountBtcBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountRbtc,
            'commissions account balance is incorrect'
          );
        });

        it(`THEN the user MoC balance has decreased by ${scenario.expect.commissionAmountMoC} MoCs by commissions`, async function() {
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diff = prevUserMoCBalance.sub(userMoCBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.mocAmount,
            'user MoC balance is incorrect'
          );
        });
        it(`THEN the commissions account MoC balance has increased by ${scenario.expect.commissionAmountMoC} MoCs`, async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountRbtc,
            'commissions account MoC balance is incorrect'
          );
        });
      });
    });
    describe('GIVEN since the user sends not enough amount to pay comission', function() {
      it('WHEN a user tries to mint BPros with 10 RBTCs and does not send to pay commission', async function() {
        const mintBpro = mocHelper.mintBPro(userAccount, 10);
        await expectRevert.unspecified(mintBpro);
      });
    });
  });
});
