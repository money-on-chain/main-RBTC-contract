const { BN, constants, expectEvent, expectRevert } = require('openzeppelin-test-helpers');

const { ZERO_ADDRESS } = constants;

function shouldBehaveLikeERC20Mintable(minter, [other]) {
  describe('as a mintable token', function() {
    describe('mint', function() {
      const amount = new BN(100);

      context('when the sender has minting permission', function() {
        const from = minter;

        function shouldMint(_amount) {
          beforeEach(async function() {
            ({ logs: this.logs } = await this.token.mint(other, _amount, { from }));
          });

          it('mints the requested amount', async function() {
            (await this.token.balanceOf(other)).should.be.bignumber.equal(_amount);
          });

          it('emits a mint and a transfer event', async function() {
            expectEvent.inLogs(this.logs, 'Transfer', {
              from: ZERO_ADDRESS,
              to: other,
              value: _amount
            });
          });
        }

        context('for a zero amount', function() {
          shouldMint(new BN(0));
        });

        context('for a non-zero amount', function() {
          shouldMint(amount);
        });
      });

      context('when the sender does not have minting permission', function() {
        const from = other;

        it('reverts', async function() {
          await expectRevert.unspecified(this.token.mint(other, amount, { from }));
        });
      });
    });
  });
}

module.exports = {
  shouldBehaveLikeERC20Mintable
};
