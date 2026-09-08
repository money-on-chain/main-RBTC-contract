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

  it('initializes EMA with a timestamp and subsequently gates it for one day', async function() {
    const latestBlock = await web3.eth.getBlock('latest');
    const nextCalculation = Number(latestBlock.timestamp) + DAY;
    const changer = await EmaTimeBasedChangerMock.new(mocHelper.mocState.address, nextCalculation);
    await mocHelper.governor.executeChange(changer.address);

    assert(!(await mocHelper.mocState.shouldCalculateEma()), 'EMA was enabled before its timestamp');

    await increaseTime(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due at its timestamp');
    await mocHelper.mocState.calculateBitcoinMovingAverage();
    assert(!(await mocHelper.mocState.shouldCalculateEma()), 'EMA was not gated after calculation');

    await increaseTime(DAY);
    assert(await mocHelper.mocState.shouldCalculateEma(), 'EMA was not due after one day');
  });

  it('uses the configured weekly timestamp and schedules from the payment execution time', async function() {
    await mocHelper.registerVendor(vendor, 0, owner);
    await mocHelper.mintBPro(account, mocHelper.toContractBN(2), vendor);
    await mocHelper.mockMocInrateChanger.setBitProRate(mocHelper.toContractBN(0.5 * 10 ** 18));
    await mocHelper.mockMocInrateChanger.setBitProInterestAddress(interestTarget);
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);

    const latestBlock = await web3.eth.getBlock('latest');
    const nextPayment = Number(latestBlock.timestamp) + DAY;
    const changer = await BitProInterestTimeBasedChangerMock.new(
      mocHelper.mocInrate.address,
      nextPayment
    );
    await mocHelper.governor.executeChange(changer.address);

    assert(!(await mocHelper.isBitProInterestEnabled()), 'interest was enabled before its timestamp');
    await increaseTime(DAY);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not enabled at its timestamp');

    await mocHelper.payBitProHoldersInterestPayment();
    assert(!(await mocHelper.isBitProInterestEnabled()), 'interest was not gated after payment');

    await increaseTime(7 * DAY);
    assert(await mocHelper.isBitProInterestEnabled(), 'interest was not due after one week');
  });
});
