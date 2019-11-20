const { expectRevert } = require('openzeppelin-test-helpers');

const testHelperBuilder = require('../mocHelper.js');

const CONTRACT_IS_PAUSED = 'contract_is_paused';
const UNSTOPPABLE = 'unstoppable';
let mocHelper;
let toContractBN;
let BUCKET_X2;

contract('MoC', function([owner, userAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.governor = mocHelper.governor;
    this.stopper = mocHelper.stopper;
    ({ BUCKET_X2 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();
    await mocHelper.mintBPro(owner, 10);
    await mocHelper.mintDoc(userAccount, 10000);
    await mocHelper.stopper.pause(mocHelper.moc.address);
    const paused = await mocHelper.moc.paused();
    assert(paused, 'MoC contract must be paused');
  });

  describe('GIVEN the MoC contract is paused', function() {
    describe('AND a user tries to do mint and reedem operations', function() {
      it('THEN all must revert', async function() {
        await assertAllMintReedemMocHelperPausedFunctions(userAccount);
      });
    });
    describe('AND a user tries to do redeem operations', function() {
      it('THEN redeemBProx must revert', async function() {
        await assertAllMocPausedFunctions(owner, userAccount);
      });
      it('THEN redeemDocRequest must revert', async function() {
        await expectRevert(mocHelper.moc.redeemDocRequest(100), CONTRACT_IS_PAUSED);
      });
    });
    describe('AND a user tries to send RBTC to MoC Contract', function() {
      it('THEN fallback function must revert', async function() {
        await expectRevert(
          web3.eth.sendTransaction({
            from: userAccount,
            to: mocHelper.moc.address,
            value: toContractBN(1)
          }),
          CONTRACT_IS_PAUSED
        );
      });
    });
    describe('AND the MoC contract is unpaused', function() {
      beforeEach(async function() {
        await mocHelper.stopper.unpause(mocHelper.moc.address);
        const paused = await mocHelper.moc.paused();
        assert(!paused, 'MoC contract must not be paused');
      });
      it('THEN reedem FreeDocs must be executed', async function() {
        await mocHelper.redeemFreeDoc({ userAccount, docAmount: 3 });
      });
      it('THEN mintBPro must be executed', async function() {
        mocHelper.mintBPro(owner, 10);
      });
    });
  });

  describe('GIVEN a the MoC contract is unpaused', function() {
    describe('AND governor makes unstopable MoC', function() {
      it('THEN Moc.pause() must revert as unstoppable', async function() {
        await mocHelper.stopper.unpause(mocHelper.moc.address);
        await mocHelper.mockMocChanger.setStoppable(false);
        await mocHelper.governor.executeChange(mocHelper.mockMocChanger.address);
        await expectRevert(mocHelper.moc.pause(), UNSTOPPABLE);
      });
    });
  });
});

const assertAllMintReedemMocHelperPausedFunctions = userAccount => {
  const testFunctions = [
    { name: 'mintBPro', args: [userAccount, 10] },
    { name: 'mintDoc', args: [userAccount, 10000] },
    {
      name: 'mintBProx',
      args: [userAccount, BUCKET_X2, toContractBN(10), toContractBN(9000)]
    },
    { name: 'redeemFreeDoc', args: [{ userAccount, docAmount: 3 }] },
    { name: 'redeemBPro', args: [userAccount, 10] }
  ];

  // Get all tx promises
  const txs = testFunctions.map(func => mocHelper[func.name](...func.args));

  return Promise.all(txs.map(tx => expectRevert(tx, CONTRACT_IS_PAUSED)));
};

const assertAllMocPausedFunctions = (owner, userAccount) => {
  const testFunctions = [
    { name: 'redeemBProx', args: [BUCKET_X2, 3] },
    { name: 'alterRedeemRequestAmount', args: [false, 100] },
    { name: 'runSettlement', args: [1] },
    { name: 'dailyInratePayment', args: [{ from: owner }] },
    { name: 'payBitProHoldersInterestPayment', args: [{ from: owner }] },
    { name: 'setBurnoutAddress', args: [userAccount, { from: owner }] }
  ];
  const txs = testFunctions.map(func => mocHelper.moc[func.name](...func.args));

  return Promise.all(txs.map(tx => expectRevert(tx, CONTRACT_IS_PAUSED)));
};
