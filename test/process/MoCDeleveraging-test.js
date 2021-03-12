/* eslint-disable no-unused-expressions */
const { expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_X2;
let accounts;
contract('MoC: Delever X', function([owner, vendorAccount, ...allAccounts]) {
  accounts = allAccounts.slice(0, 10);
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    ({ BUCKET_X2 } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocSettlement = mocHelper.mocSettlement;
    this.revertingContract = mocHelper.revertingContract;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('DoS attack mitigation', function() {
    const rbtcBalances = [];

    describe('GIVEN two honest users and one attacker mint BProx', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(owner, 3, vendorAccount);
        await mocHelper.mintDocAmount(owner, 15000, vendorAccount);

        await mocHelper.mintBProxAmount(accounts[1], BUCKET_X2, 0.5, vendorAccount);
        await mocHelper.mintBProxAmount(accounts[2], BUCKET_X2, 0.5, vendorAccount);
        const btcToMint = toContractBN(0.5 * mocHelper.RESERVE_PRECISION);
        // Double is sent only to avoid calculations.
        const btcTotal = toContractBN(0.5 * 2 * mocHelper.RESERVE_PRECISION);
        await this.revertingContract.mintBProx(BUCKET_X2, btcToMint, vendorAccount, {
          from: accounts[3],
          value: btcTotal
        });

        // From now reverting
        await this.revertingContract.setAcceptingMoney(false);
        rbtcBalances.push(toContractBN(await web3.eth.getBalance(accounts[1])));
        rbtcBalances.push(toContractBN(await web3.eth.getBalance(accounts[2])));
        rbtcBalances.push(toContractBN(await web3.eth.getBalance(this.revertingContract.address)));
      });
      describe('WHEN deleveraging is run', function() {
        beforeEach(async function() {
          await this.mocSettlement.pubRunDeleveraging();
        });
        it(`AND bucket ${BUCKET_X2} coverage should be 2`, async function() {
          const bxCoverage = await this.mocState.coverage(BUCKET_X2);
          mocHelper.assertBigCb(bxCoverage, 2, 'Coverage should be 2');
        });
        it('AND honest users receives RBTC', async function() {
          const finalBalance1 = toContractBN(await web3.eth.getBalance(accounts[1]));
          const finalBalance2 = toContractBN(await web3.eth.getBalance(accounts[2]));

          assert(finalBalance1 > rbtcBalances[0], 'Honest user balance does not increase');
          assert(finalBalance2 > rbtcBalances[1], 'Honest user balance does not increase');
        });
        it('AND attacker does not receive his RBTC', async function() {
          const finalBalance = toContractBN(
            await web3.eth.getBalance(this.revertingContract.address)
          );

          mocHelper.assertBig(finalBalance, rbtcBalances[2], 'Incorrect attackers balance');
        });
      });
    });
  });

  describe('During settlement bucket liquidation is not enabled', function() {
    const bprox2Positions = [0.5, 0.5, 0.5, 0.5, 0.01];
    describe('GIVEN five users have BProX2 and there is a position and the settlement is enabled', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(owner, 25, vendorAccount);
        await mocHelper.mintDocAmount(owner, 25000, vendorAccount);

        await Promise.all(
          bprox2Positions.map((position, i) =>
            mocHelper.mintBProxAmount(accounts[i + 1], BUCKET_X2, position, vendorAccount)
          )
        );
        await mocHelper.moc.redeemDocRequest(toContractBN(1, 'USD'), {
          from: owner
        });
        // Verify that the positions are placed
        await Promise.all(
          bprox2Positions.map(async (position, i) =>
            mocHelper.assertBigRBTC(
              await mocHelper.getBProxBalance(BUCKET_X2, accounts[i + 1]),
              position
            )
          )
        );
        await mocHelper.waitNBlocks(100);
      });
      describe('WHEN deleveraging has run almost completely', function() {
        beforeEach(async function() {
          // Run only a few deleveraging step
          await this.moc.runSettlement(3);
          await mocHelper.waitNBlocks(100);
          expect(await this.mocSettlement.isSettlementRunning()).to.be.true;
        });
        it(`THEN bucket liquidation should not be enabled ${BUCKET_X2} until the settlement finishes`, async function() {
          await expectRevert(
            this.moc.evalBucketLiquidation(BUCKET_X2),
            'Function can only be called when settlement is ready'
          );
        });
      });
    });
  });

  describe('Deleveraging can be run burning every position', function() {
    const bprox2Positions = [0.5, 0.5, 0.5, 0.5, 0.01];
    describe('GIVEN five users have only BProX2 positions and the settlement is enabled', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(owner, 25, vendorAccount);
        await mocHelper.mintDocAmount(owner, 25000, vendorAccount);

        await Promise.all(
          bprox2Positions.map((position, i) =>
            mocHelper.mintBProxAmount(accounts[i + 1], BUCKET_X2, position, vendorAccount)
          )
        );
        // Verify that the positions are placed
        await Promise.all(
          bprox2Positions.map(async (position, i) =>
            mocHelper.assertBigRBTC(
              await mocHelper.getBProxBalance(BUCKET_X2, accounts[i + 1]),
              position
            )
          )
        );
        await mocHelper.waitNBlocks(100);
      });
      describe('WHEN deleveraging has run completely', function() {
        beforeEach(async function() {
          // Run only a deleveraging step to finish
          await this.mocSettlement.pubRunDeleveraging();

          expect(await this.mocSettlement.isSettlementRunning()).to.be.false;
        });
        it('THEN all users BProx are burnt', async function() {
          await Promise.all(
            bprox2Positions.map(async (position, i) => {
              mocHelper.assertBigRBTC(
                await mocHelper.getBProxBalance(BUCKET_X2, accounts[i + 1]),
                0
              );
            })
          );
        });
      });
    });
  });

  describe('Coverage does not change on settlement', function() {
    const SETTLEMENT_STEPS_TO_RUN = 3;
    const bprox2Positions = [0.5, 0.5, 0.5, 0.5, 0.5];

    describe('GIVEN five users have BProX2 and the settlement is enabled', function() {
      beforeEach(async function() {
        await mocHelper.mintBProAmount(owner, 25, vendorAccount);
        await mocHelper.mintDocAmount(owner, 25000, vendorAccount);

        mocHelper.getBucketState(BUCKET_X2);
        await Promise.all(
          bprox2Positions.map((position, i) =>
            mocHelper.mintBProxAmount(accounts[i + 1], BUCKET_X2, position, vendorAccount)
          )
        );
        await Promise.all(
          bprox2Positions.map(async (position, i) =>
            mocHelper.assertBigRBTC(
              await mocHelper.getBProxBalance(BUCKET_X2, accounts[i + 1]),
              position
            )
          )
        );
        await mocHelper.waitNBlocks(100);
      });
      describe('WHEN deleveraging has run almost completely', function() {
        beforeEach(async function() {
          await this.moc.runSettlement(SETTLEMENT_STEPS_TO_RUN); // Run only a few deleveraging step
        });
        it('THEN the settlement is running', async function() {
          expect(await this.mocSettlement.isSettlementRunning()).to.be.true;
        });
        it(`THEN the bucket liquitadion should not be enabled ${BUCKET_X2} until the settlement finishes`, async function() {
          await expectRevert(
            this.moc.evalBucketLiquidation(BUCKET_X2),
            'Function can only be called when settlement is ready'
          );
        });
        it('THEN two positions are still on place', async function() {
          const expectedPositionsInPlace = bprox2Positions.length - SETTLEMENT_STEPS_TO_RUN;
          const individualResults = await Promise.all(
            bprox2Positions.map(async (position, i) =>
              toContractBN(position, 'Reserve').eq(
                await mocHelper.getBProxBalance(BUCKET_X2, accounts[i + 1])
              )
            )
          );

          const positionsInPlace = individualResults.reduce(
            (previousPositionsInPlace, currentPositionIsInPlace) =>
              currentPositionIsInPlace ? previousPositionsInPlace + 1 : previousPositionsInPlace
          );
          expect(
            positionsInPlace === expectedPositionsInPlace,
            `Positions in place should be ${expectedPositionsInPlace} and they actually are ${positionsInPlace}`
          );
        });
      });
    });
  });

  const scenarios = [
    {
      description: 'If there is one X2 position, it gets delevered and coverage is restored',
      users: [
        {
          nBPro: 10,
          nDoc: 10000,
          bproxMint: {
            nB: 1
          }, // Loads X2 with nB: 1 and nDoc: 10000
          expect: {
            returned: { nB: 1 },
            burn: { nBProx: 1 }
          }
        }
      ],
      expect: {
        coverage: { after: 2 } // X2 coverage is restored
      }
    },
    {
      description: 'If there are two X2 position, both got delevered and coverage is restored',
      // Loads X2 with nB: 1 and nDoc: 10000
      users: [
        {
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.5
          },
          expect: {
            returned: { nB: 0.5 },
            burn: { nBProx: 0.5 }
          }
        },
        {
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.5
          },
          expect: {
            returned: { nB: 0.5 },
            burn: { nBProx: 0.5 }
          }
        }
      ],
      expect: {
        coverage: { after: 2 } // X2 coverage is restored
      }
    },
    {
      description: 'no X2 position, nothings is moved',
      users: [
        {
          nBPro: 10,
          nDoc: 10000,
          bproxMint: {
            nB: 0
          },
          expect: {
            returned: { nB: 0 },
            burn: { nBProx: 0 }
          }
        }
      ],
      expect: {
        coverage: { after: 2 }
      }
    }
  ];
  scenarios.forEach(s => {
    const userPrevBalances = [];
    describe('GIVEN there is 1 BProx in Bucket BUCKET_X2', function() {
      beforeEach(async function() {
        await new Promise(resolve => {
          s.users.forEach(async (user, index) => {
            const account = accounts[index + 1];

            await mocHelper.mintBProAmount(account, user.nBPro, vendorAccount);
            await mocHelper.mintDocAmount(account, user.nDoc, vendorAccount);

            if (user.bproxMint.nB) {
              await mocHelper.mintBProx(account, BUCKET_X2, user.bproxMint.nB, vendorAccount);
            }
            userPrevBalances[index] = {
              nBProx: await mocHelper.getBProxBalance(BUCKET_X2, accounts[index + 1]),
              nB: await web3.eth.getBalance(accounts[index + 1])
            };
            if (index === s.users.length - 1) resolve();
          });
        });
      });
      describe('WHEN deleveraging is run', function() {
        beforeEach(async function() {
          await this.mocSettlement.pubRunDeleveraging();
        });
        s.users.forEach(async (u, index) => {
          const { nB } = u.expect.returned;
          const { nBProx } = u.expect.burn;
          it(`THEN ${nB} RBTC are returned to the user ${index}`, async function() {
            const userRbtcBalance = toContractBN(await web3.eth.getBalance(accounts[index + 1]));
            const returnedRbtc = userRbtcBalance.sub(toContractBN(userPrevBalances[index].nB));
            mocHelper.assertBigRBTC(returnedRbtc, nB, `returned RBTC should be ${nB}`);
          });
          it(`AND ${nBProx} are burnt for the user ${index}`, async function() {
            const userBProxBalance = await mocHelper.getBProxBalance(
              BUCKET_X2,
              accounts[index + 1]
            );
            const burnedBProx = userPrevBalances[index].nBProx.sub(userBProxBalance);
            mocHelper.assertBigRBTC(burnedBProx, nBProx, `burned BProx should be ${nBProx}`);
          });
        });
        const newCoverage = s.expect.coverage.after;
        it(`THEN bucket ${BUCKET_X2} coverage should be ${newCoverage}`, async function() {
          const bLCoverage = await this.mocState.coverage(BUCKET_X2);
          mocHelper.assertBigCb(bLCoverage, newCoverage, `Coverage should be ${newCoverage}`);
        });
      });
    });
  });
});
