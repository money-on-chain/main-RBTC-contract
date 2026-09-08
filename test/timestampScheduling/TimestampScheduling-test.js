const { expectRevert, time } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

const EmaTimeBasedChangerMock = artifacts.require('EmaTimeBasedChangerMock');
const BitProInterestTimeBasedChangerMock = artifacts.require('BitProInterestTimeBasedChangerMock');

const DAY = 24 * 60 * 60;

contract('MoC timestamp scheduling', function([owner, account, interestTarget, vendor]) {
  let mocHelper;

  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
  });

  beforeEach(async function() {
    await mocHelper.revertState();
  });

  it('initializes the EMA schedule on fresh deployment and gates calculations daily', async function() {
    const latestBlock = await web3.eth.getBlock('latest');
    const lastCalculation = await mocHelper.mocState.lastEmaCalculationTimestamp();

    assert.equal((await mocHelper.mocState.emaCalculationTimeSpan()).toNumber(), DAY);
    assert(lastCalculation.toNumber() > 0, 'EMA schedule was not initialized');
    assert(
      lastCalculation.toNumber() <= Number(latestBlock.timestamp),
      'EMA timestamp is after the latest block'
    );
    assert(
      !(await mocHelper.mocState.shouldCalculateEma()),
      'EMA was enabled before one day elapsed'
    );

    await time.increase(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due at its timestamp');
    await mocHelper.mocState.calculateBitcoinMovingAverage();
    assert(!(await mocHelper.mocState.shouldCalculateEma()), 'EMA was not gated after calculation');

    await time.increase(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due after one day');
  });

  it('does not allow migration initialization to overwrite a fresh EMA schedule', async function() {
    const changer = await EmaTimeBasedChangerMock.new(
      mocHelper.mocState.address,
      (await time.latest()).toString()
    );
    await expectRevert(
      mocHelper.governor.executeChange(changer.address),
      'EMA schedule already initialized'
    );
  });

  it('initializes the interest schedule on fresh deployment and gates payments weekly', async function() {
    await mocHelper.registerVendor(vendor, 0, owner);
    await mocHelper.mintBPro(account, mocHelper.toContractBN(2), vendor);
    await mocHelper.mockMocInrateChanger.setBitProRate(mocHelper.toContractBN(0.5 * 10 ** 18));
    await mocHelper.mockMocInrateChanger.setBitProInterestAddress(interestTarget);
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

    const latestBlock = await web3.eth.getBlock('latest');
    const lastPayment = await mocHelper.mocInrate.lastBitProInterestTimestamp();
    assert(lastPayment.toNumber() > 0, 'interest schedule was not initialized');
    assert(
      lastPayment.toNumber() <= Number(latestBlock.timestamp),
      'interest timestamp is after the latest block'
    );

    assert.equal((await mocHelper.mocInrate.bitProInterestTimeSpan()).toNumber(), 7 * DAY);
    assert(
      !(await mocHelper.isBitProInterestEnabled()),
      'interest was enabled before one week elapsed'
    );
    await time.increase(7 * DAY + 1);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not enabled after one week');

    await mocHelper.payBitProHoldersInterestPayment();
    assert(!(await mocHelper.isBitProInterestEnabled()), 'interest was not gated after payment');

    await time.increase(7 * DAY + 1);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not due after another week');
  });

  it('does not allow migration initialization to overwrite a fresh interest schedule', async function() {
    const changer = await BitProInterestTimeBasedChangerMock.new(
      mocHelper.mocInrate.address,
      (await time.latest()).toString()
    );
    await expectRevert(
      mocHelper.governor.executeChange(changer.address),
      'Interest schedule already initialized'
    );
  });
});
