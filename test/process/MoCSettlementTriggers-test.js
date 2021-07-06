const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;

const isDay = (precision, big, _expected) => {
  const expected = toContractBN(_expected);
  const ONE = toContractBN(1);
  return big.gte(expected.mul(precision)) && big.lt(expected.add(ONE).mul(precision));
};

// TODO: Fix this tests
contract.skip('MoC', function([owner, userAccount]) {
  const dayBlockSpan = 4 * 60 * 24;
  const twoDays = 2 * dayBlockSpan + 20;
  const arbitraryBlockSpan = 41;

  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: false });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mocSettlement = mocHelper.mocSettlement;
    this.mockMoCSettlementChanger = mocHelper.mockMoCSettlementChanger;
    this.governor = mocHelper.governor;
  });

  // Tests skipped because takes a lot of time to mine the blocks needed
  describe(`GIVEN settlement blockSpan is ${twoDays}`, function() {
    beforeEach(async function() {
      await mocHelper.revertState();
      await this.mockMoCSettlementChanger.setBlockSpan(dayBlockSpan);
      await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
    });
    it('THEN days til settlement should be 2', async function() {
      const days = await this.mocState.daysToSettlement();

      assert(isDay(mocHelper.DAY_PRECISION, days, 2), 'Incorrect days to settlement');
    });
    describe('WHEN one day of blocks pass', function() {
      beforeEach(async function() {
        await mocHelper.waitNBlocks(dayBlockSpan);
      });
      it('THEN days til settlement should be 1', async function() {
        const days = await this.mocState.daysToSettlement();
        assert(isDay(mocHelper.DAY_PRECISION, days, 1), 'Incorrect days to settlement');
      });
      describe('AND 1 more day pass', function() {
        beforeEach(async function() {
          await mocHelper.waitNBlocks(dayBlockSpan + 50);
        });
        it('THEN days to settlement is 0', async function() {
          const days = await this.mocState.daysToSettlement();

          assert(isDay(mocHelper.DAY_PRECISION, days, 0), 'Incorrect days to settlement');
        });
        describe('AND settlement is called', function() {
          it('THEN days to settlement is 2 again', async function() {
            await mocHelper.executeSettlement();
            const days = await this.mocState.daysToSettlement();

            // Should be 2, but ganache auto mine the transaction's block
            assert(isDay(mocHelper.DAY_PRECISION, days, 1), 'Incorrect days to settlement');
          });
        });
      });
    });
  });

  describe(`GIVEN settlement blockSpan is ${arbitraryBlockSpan}`, function() {
    beforeEach(async function() {
      await this.mockMoCSettlementChanger.setBlockSpan(arbitraryBlockSpan);
      await this.governor.executeChange(mocHelper.mockMoCSettlementChanger.address);
    });
    describe('WHEN a user runs the settlement before time', function() {
      it('THEN it reverts', async function() {
        const settlementPromise = this.moc.runSettlement(100, { from: userAccount });
        await expectRevert.unspecified(settlementPromise);
      });
      it('THEN settelment is disabled', async function() {
        const isSettlementEnable = await this.moc.isSettlementEnabled();
        assert.isFalse(isSettlementEnable);
      });
    });
    describe(`AND ${arbitraryBlockSpan} blocks pass by`, function() {
      beforeEach(async function() {
        await mocHelper.waitNBlocks(arbitraryBlockSpan);
      });
      it('THEN settlement is enabled', async function() {
        const isSettlementEnable = await this.moc.isSettlementEnabled();
        assert.isTrue(isSettlementEnable);
      });
    });
  });
});
