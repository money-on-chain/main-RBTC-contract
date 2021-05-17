const testHelperBuilder = require('../mocHelper.js');

const CommissionSplitterChangerDeploy = artifacts.require('CommissionSplitterChangerDeploy.sol');

let mocHelper;
let commissionSplitter;
let splitterPrecision;
let toContractBN;
let mocToken;

const executeOperations = (user, operations, vendorAccount) => {
  const promises = operations.map(async op =>
    mocHelper.mintBProAmount(
      user,
      op.reserve,
      vendorAccount,
      await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
    )
  );

  return Promise.all(promises);
};

const operationsTotal = operations => operations.reduce((last, op) => op.reserve + last, 0);

contract('CommissionSplitter', function([
  owner,
  userAccount,
  commissionsAccount,
  vendorAccount,
  mocCommissionsAccount
]) {
  before(async function() {
    const accounts = [owner, userAccount, mocCommissionsAccount];
    mocHelper = await testHelperBuilder({ owner, accounts });
    ({ toContractBN, commissionSplitter, mocToken } = mocHelper);
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
        commissionAmount: 1,
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
        mocAmount: 3.333
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
        commissionAmount: 0.75,
        mocAmount: 0.75
      }
    ];

    scenarios.forEach(s => {
      describe(`WHEN proportion is set to ${s.proportion}`, function() {
        before(async function() {
          await mocHelper.revertState();
          // deploying Commission splitter
          splitterPrecision = await commissionSplitter.PRECISION();

          // Register vendor for test
          await mocHelper.registerVendor(vendorAccount, 0, owner);

          // Commission rates for test are set in functionHelper.js
          await mocHelper.mockMocInrateChanger.setCommissionRates(
            await mocHelper.getCommissionsArrayNonZero()
          );

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

            await executeOperations(userAccount, s.mintOperations, vendorAccount);
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

  describe('WHEN split is made with MocTokens', function() {
    before(async function() {
      await mocHelper.revertState();

      const commissionSplitterChangerDeploy = await CommissionSplitterChangerDeploy.new(
        commissionSplitter.address,
        mocToken.address,
        mocCommissionsAccount,
        {
          from: owner
        }
      );

      // update params
      await mocHelper.governor.executeChange(commissionSplitterChangerDeploy.address);

      // Set Final commissionAddress Proportion from scenario
      await mocHelper.setFinalCommissionAddress(commissionsAccount);
    });

    it('THEN should receive 100% of the MocTokens on the mocTokenCommissionAddress', async function() {
      const mocTokenAmount = '510000003';
      await mocHelper.mintMoCToken(commissionSplitter.address, mocTokenAmount, owner);

      let commissionSpliterMocTokenBalance = await mocHelper.getMoCBalance(
        commissionSplitter.address
      );
      mocHelper.assertBigReserve(
        commissionSpliterMocTokenBalance,
        mocTokenAmount,
        'Commission Splitter initial MoC Token balance is incorrect'
      );
      let mocCommissionsAccountBalance = await mocHelper.getMoCBalance(mocCommissionsAccount);
      mocHelper.assertBigReserve(
        mocCommissionsAccountBalance,
        '0',
        'Initial MoC Token Commission balance is incorrect'
      );

      // Send the funds to the comission address
      await commissionSplitter.split();

      commissionSpliterMocTokenBalance = await mocHelper.getMoCBalance(commissionSplitter.address);
      mocHelper.assertBigReserve(
        commissionSpliterMocTokenBalance,
        '0',
        'Commission Splitter end MoC Token balance is incorrect'
      );

      mocCommissionsAccountBalance = await mocHelper.getMoCBalance(mocCommissionsAccount);
      mocHelper.assertBigReserve(
        mocCommissionsAccountBalance,
        mocTokenAmount,
        'End MoC Token Commission account balance is incorrect'
      );
    });
  });
});
