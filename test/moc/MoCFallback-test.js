const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
const { BN } = web3.utils;

contract('MoC', function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    this.moc = mocHelper.moc;
  });

  beforeEach(function() {
    return mocHelper.revertState();
  });

  describe('RBTC sending', function() {
    describe('GIVEN a user sends 1 RBTC to the contract', function() {
      it('THEN the contracts increse its balance by 100 RBTC', async function() {
        await this.moc.sendTransaction({
          from: owner,
          to: this.moc.address,
          value: new BN(1).mul(mocHelper.RESERVE_PRECISION)
        });
        const balance = await web3.eth.getBalance(this.moc.address);

        mocHelper.assertBigRBTC(balance, 1, '100 was not in the first account');
      });
    });
  });
});
