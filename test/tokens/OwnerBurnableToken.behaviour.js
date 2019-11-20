const { expectEvent, expectRevert, BN } = require('openzeppelin-test-helpers');

const { inLogs } = expectEvent;

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

require('chai')
  .use(require('bn-chai')(web3.utils.BN))
  .should();

function shouldBehaveLikeOwnerBurnableToken([owner, userAccount], _initialBalance) {
  const initialBalance = new BN(_initialBalance);
  describe('GIVEN an Ownlable Burnable Token', function() {
    const from = owner;

    describe('WHEN the given amount is not greater than balance of the sender', function() {
      const amount = new BN(100);

      beforeEach(async function() {
        ({ logs: this.logs } = await this.token.burn(userAccount, amount, {
          from
        }));
      });

      it('THEN burns the requested amount', async function() {
        const balance = await this.token.balanceOf(userAccount);
        balance.should.be.bignumber.equal(initialBalance.sub(amount));
      });
      it('AND emits a transfer event', async function() {
        const event = await inLogs(this.logs, 'Transfer');
        event.args.from.should.equal(userAccount);
        event.args.to.should.equal(ZERO_ADDRESS);
        event.args.value.should.be.bignumber.equal(amount);
      });
    });

    describe('WHEN the given amount is greater than the balance of the sender', function() {
      const amount = initialBalance + 1;

      it('reverts', async function() {
        await expectRevert.unspecified(this.token.burn(userAccount, amount, { from }));
      });
    });

    describe('WHEN user tries to burn himself', function() {
      const amount = new BN(900);

      it('reverts', async function() {
        await expectRevert.unspecified(this.token.burn(userAccount, amount, { from: userAccount }));
      });
    });
  });
}

module.exports = {
  shouldBehaveLikeOwnerBurnableToken
};
