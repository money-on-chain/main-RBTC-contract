const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let commissionSplitter;
let splitterPrecision;
let toContractBN;

const executeOperations = (user, operations) => {
  const promises = operations.map(async op => mocHelper.mintBProAmount(user, op.reserve));

  return Promise.all(promises);
};

const operationsTotal = operations => operations.reduce((last, op) => op.reserve + last, 0);

contract('CommissionSplitter', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    const accounts = [owner, userAccount];
    mocHelper = await testHelperBuilder({ owner, accounts });
    ({ toContractBN, commissionSplitter } = mocHelper);
    await mocHelper.saveState();
  });

  describe('GIVEN commissions are being sent to a CommissionSplitter contract AND MOC Proportion is 0', function() {
    const scenarios = [
      {
        mintOperations: [
          {
            reserve: 1000
          }
        ],
        proportion: 0,
        commissionAmount: 2,
        mocAmount: 0
      },
      {
        mintOperations: [
          {
            reserve: 1111
          },
          {
            reserve: 2222
          }
        ],
        proportion: 1,
        commissionAmount: 0,
        mocAmount: 6.666
      },
      {
        mintOperations: [
          {
            reserve: 300
          },
          {
            reserve: 300
          },
          {
            reserve: 900
          }
        ],
        proportion: 0.5,
        commissionAmount: 1.5,
        mocAmount: 1.5
      }
    ];

    scenarios.forEach(s => {
      describe(`WHEN proportion is set to ${s.proportion}`, function() {
        before(async function() {
          await mocHelper.revertState();
          // deploying Commission splitter
          splitterPrecision = await commissionSplitter.PRECISION();
          // set commissions rate
          await mocHelper.mockMocInrateChanger.setCommissionRate(toContractBN(0.002, 'RAT'));
          // set commissions address
          await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionSplitter.address);
          // update params
          await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
          // Set MoC Proportion from scenario
          await mocHelper.setMocCommissionProportion(
            toContractBN(splitterPrecision * s.proportion)
          );
          // Set Final commissionAddress Proportion from scenario
          await mocHelper.setFinalCommissionAddress(commissionsAccount);
        });
        describe(`WHEN a user uses ${operationsTotal(
          s.mintOperations
        )} Reserve tokens to mint RiskPros paying commissions`, function() {
          before(async function() {
            // Empty commission splitter just to have a more robust test
            await commissionSplitter.split();

            await executeOperations(userAccount, s.mintOperations);
          });
          it(`THEN CommissionSplitter Reserve Token balance should be ${s.commissionAmount +
            s.mocAmount}`, async function() {
            const splitterBalance = await mocHelper.getReserveBalance(commissionSplitter.address);

            mocHelper.assertBigReserve(
              splitterBalance,
              s.commissionAmount + s.mocAmount,
              'Commission splitters reserveToken balance is incorrect'
            );
          });

          describe('AND WHEN the Splitter contract split function is called', function() {
            let mocInitialBalance;
            let comAccountInitialBalance;
            let splitTx;
            before(async function() {
              comAccountInitialBalance = await mocHelper.getReserveBalance(commissionsAccount);
              mocInitialBalance = await mocHelper.getReserveBalance(mocHelper.moc.address);
              splitTx = await commissionSplitter.split();
            });
            it('THEN Split event is emitted', async function() {
              const [splitEvent] = await mocHelper.findEvents(splitTx, 'SplitExecuted');

              assert(splitEvent, 'Event was not emitted');
              mocHelper.assertBigReserve(
                splitEvent.commissionAmount,
                s.commissionAmount,
                'Commissions amount in event is incorrect'
              );
              mocHelper.assertBigReserve(
                splitEvent.mocAmount,
                s.mocAmount,
                'Moc reserve amount in event is incorrect'
              );
            });
            it(`THEN the commission address receives ${s.commissionAmount} reserveTokens`, async function() {
              const comAcountBalance = await mocHelper.getReserveBalance(commissionsAccount);
              const comDiff = comAcountBalance.sub(comAccountInitialBalance);

              mocHelper.assertBigReserve(
                comDiff,
                s.commissionAmount,
                'Commissions account balance is incorrect'
              );
            });
            it(`AND moc receives ${s.mocAmount} reserveTokens`, async function() {
              const mocAcountBalance = await mocHelper.getReserveBalance(mocHelper.moc.address);
              const mocDiff = mocAcountBalance.sub(mocInitialBalance);

              mocHelper.assertBigReserve(mocDiff, s.mocAmount, 'MoC account balance is incorrect');
            });
          });
        });
      });
    });
  });
});
