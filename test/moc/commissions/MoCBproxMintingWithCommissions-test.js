const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;

contract('MoC : MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_X2 } = mocHelper);
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

  describe('BProx minting with commissions', function() {
    const scenarios = [
      {
        params: {
          nBProx: 5
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5.01',
          commission: {
            nBtc: '0.01'
          }
        }
      },
      {
        params: {
          nBProx: 10
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8.016',
          commission: {
            nBtc: '0.016'
          }
        }
      }
    ];

    describe('GIVEN the user have 18 BPro and 8000 DOCs and no interest is charged', function() {
      beforeEach(async function() {
        await this.mocState.setDaysToSettlement(toContractBN(0, 'DAY'));
        await mocHelper.mintBProAmount(userAccount, 18);
        await mocHelper.mintDocAmount(userAccount, 80000);
      });

      scenarios.forEach(async s => {
        describe(`WHEN a user sends BTC to mint ${s.params.nBProx} Bprox`, function() {
          let initialCommissionAccountBalance;
          let prevUserBtcBalance;
          let txCost;
          beforeEach(async function() {
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(owner));
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );

            const tx = await mocHelper.mintBProxAmount(owner, BUCKET_X2, s.params.nBProx);
            txCost = toContractBN(await mocHelper.getTxCost(tx));
          });
          it(`THEN he receives ${s.expect.nBProx} Bprox`, async function() {
            const balance = await mocHelper.getBProxBalance(BUCKET_X2, owner);
            mocHelper.assertBigRBTC(balance, s.expect.nBProx, 'Bprox balance is incorrect');
          });
          it(`THEN the user rbtc balance has decrease by ${s.expect.nBtc} Rbtcs by Mint + ${s.expect.commission.nBtc} Rbtcs by commissions`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(owner));
            const diff = prevUserBtcBalance.sub(userBtcBalance).sub(txCost);
            mocHelper.assertBigRBTC(
              diff,
              s.expect.totalCostOnBtc,
              'user rbtc balance is incorrect'
            );
          });
          it('AND the commissions accounts balance increase', async function() {
            const balance = toContractBN(await web3.eth.getBalance(commissionsAccount));
            const diff = balance.sub(initialCommissionAccountBalance);
            const expected = toContractBN(s.expect.commission.nBtc, 'BTC');
            mocHelper.assertBig(diff, expected, 'the commissions accounts balance is not correct');
          });
        });
      });
    });
  });
});
