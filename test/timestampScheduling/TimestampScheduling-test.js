const testHelperBuilder = require('../mocHelper.js');

const EmaTimeBasedChangerMock = artifacts.require('EmaTimeBasedChangerMock');
const BitProInterestTimeBasedChangerMock = artifacts.require('BitProInterestTimeBasedChangerMock');

const DAY = 24 * 60 * 60;

const increaseTime = async seconds => {
  await new Promise((resolve, reject) => {
    web3.currentProvider.send(
      { jsonrpc: '2.0', method: 'evm_increaseTime', params: [seconds], id: Date.now() },
      (error, result) => (error ? reject(error) : resolve(result))
    );
  });
  await new Promise((resolve, reject) => {
    web3.currentProvider.send(
      { jsonrpc: '2.0', method: 'evm_mine', params: [], id: Date.now() + 1 },
      (error, result) => (error ? reject(error) : resolve(result))
    );
  });
};

contract('MoC timestamp scheduling', function([owner, account, interestTarget, vendor]) {
  let mocHelper;

  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
  });

  beforeEach(async function() {
    await mocHelper.revertState();
  });

  it('stores the last EMA timestamp and gates calculations for one day', async function() {
    const latestBlock = await web3.eth.getBlock('latest');
    const lastCalculation = Number(latestBlock.timestamp);
    const changer = await EmaTimeBasedChangerMock.new(mocHelper.mocState.address, lastCalculation);
    await mocHelper.governor.executeChange(changer.address);

    assert.equal((await mocHelper.mocState.emaCalculationTimeSpan()).toNumber(), DAY);
    assert.equal(
      (await mocHelper.mocState.lastEmaCalculationTimestamp()).toNumber(),
      lastCalculation
    );
    assert(
      !(await mocHelper.mocState.shouldCalculateEma()),
      'EMA was enabled before one day elapsed'
    );

    await increaseTime(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due at its timestamp');
    await mocHelper.mocState.calculateBitcoinMovingAverage();
    assert(!(await mocHelper.mocState.shouldCalculateEma()), 'EMA was not gated after calculation');

    await increaseTime(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due after one day');
  });

  it('stores the last interest payment timestamp and gates payments for one week', async function() {
    await mocHelper.registerVendor(vendor, 0, owner);
    await mocHelper.mintBPro(account, mocHelper.toContractBN(2), vendor);
    await mocHelper.mockMocInrateChanger.setBitProRate(mocHelper.toContractBN(0.5 * 10 ** 18));
    await mocHelper.mockMocInrateChanger.setBitProInterestAddress(interestTarget);
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

    const latestBlock = await web3.eth.getBlock('latest');
    const lastPayment = Number(latestBlock.timestamp);
    const changer = await BitProInterestTimeBasedChangerMock.new(
      mocHelper.mocInrate.address,
      lastPayment
    );
    await mocHelper.governor.executeChange(changer.address);

    assert.equal((await mocHelper.mocInrate.bitProInterestTimeSpan()).toNumber(), 7 * DAY);
    assert.equal((await mocHelper.mocInrate.lastBitProInterestTimestamp()).toNumber(), lastPayment);
    assert(
      !(await mocHelper.isBitProInterestEnabled()),
      'interest was enabled before one week elapsed'
    );
    await increaseTime(7 * DAY + 1);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not enabled after one week');

    await mocHelper.payBitProHoldersInterestPayment();
    assert(!(await mocHelper.isBitProInterestEnabled()), 'interest was not gated after payment');

    await increaseTime(7 * DAY + 1);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not due after another week');
  });
});
