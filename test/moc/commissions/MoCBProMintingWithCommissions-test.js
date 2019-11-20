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
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // set commissions rate
    await mocHelper.mockMocInrateChanger.setCommissionRate(0.002 * mocHelper.MOC_PRECISION);
    // set commissions address
    await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe('BPro minting with commissions', function() {
    const scenarios = [
      {
        params: {
          bproToMint: 1000
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          // (bproToMint * commissionRate = 0.002)
          commissionAmountRbtc: 2,
          totalCostOnBtc: 1002
        }
      }
    ];
    scenarios.forEach(async scenario => {
      describe(`GIVEN ${scenario.params.bproToMint} BitPro are minted`, function() {
        let prevUserBtcBalance;
        let prevUserBproBalance;
        let prevCommissionsAccountBtcBalance;
        let prevMocBtcBalance;
        let usedGas;
        beforeEach(async function() {
          prevUserBproBalance = await mocHelper.getBProBalance(userAccount);
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevMocBtcBalance = toContractBN(await web3.eth.getBalance(this.moc.address));
          const mintTx = await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint);
          usedGas = toContractBN(await mocHelper.getTxCost(mintTx));
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
