const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;
const Upgrader = artifacts.require('./contracts/changers/UpgraderChanger.sol');
const Changer = artifacts.require('./contracts/changers/MaxGasPriceChanger.sol');
const MoCv0115 = artifacts.require('./contracts_updated/MoC_v0115.sol');
const MoC = artifacts.require('./contracts/MoC.sol');
let changer;
let mocv0115;
let moc;

contract('MoC: MaxGasPriceChanger', function([owner]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
  });
  describe('GIVEN a MoC_v0115 deployed', function() {
    before(async function() {
      // to re-use deployments and simplify the test we first
      // upgrade MoC to the old implementation MoC_v0115
      mocv0115 = await MoCv0115.new({ from: owner });
      const upgrader = await Upgrader.new(
        mocHelper.moc.address,
        mocHelper.upgradeDelegator.address,
        mocv0115.address,
        { from: owner }
      );
      await mocHelper.governor.executeChange(upgrader.address, { from: owner });
    });
    describe('WHEN an user mints 1000 BPro using a high gas price', function() {
      before(async function() {
        await mocHelper.moc.mintBPro(toContractBN(1000 * mocHelper.MOC_PRECISION), {
          from: owner,
          value: toContractBN(1000 * mocHelper.MOC_PRECISION),
          gasPrice: '21000000001'
        });
      });
      it('THEN he has 1000 BPro', async function() {
        const balance = await mocHelper.getBProBalance(owner);
        mocHelper.assertBigRBTC(balance, 1000, 'userAccount BBProPro balance was not 10000');
      });
      describe('AND new MoC implementation is deployed and changer executed', function() {
        before(async function() {
          moc = await MoC.new({ from: owner });
          changer = await Changer.new(
            mocHelper.moc.address,
            mocHelper.upgradeDelegator.address,
            moc.address,
            mocHelper.moc.address, // should be ROC address but it's not relevant for this test
            mocHelper.upgradeDelegator.address,
            moc.address,
            '21000000000', // max gas price
            { from: owner }
          );
          await mocHelper.governor.executeChange(changer.address, { from: owner });
        });
        it('THEN user still has 1000 BPro', async function() {
          const balance = await mocHelper.getBProBalance(owner);
          mocHelper.assertBigRBTC(balance, 1000, 'userAccount BPro balance was not 10000');
        });
        it('THEN max gas price is applied', async function() {
          const maxGasPrice = await mocHelper.moc.maxGasPrice();
          mocHelper.assertBig(maxGasPrice, '21000000000', 'maxGasPrice was not 21000000000');
        });
        describe('WHEN user tries to mint BPro using a high gas price than the limit', function() {
          it('THEN transaction reverts because uses a higher gas price', async function() {
            const tx = mocHelper.moc.mintBPro(1000, { value: 1000, gasPrice: '21000000001' });
            await expectRevert(tx, 'gas price is above the max allowed');
          });
        });
      });
    });
  });
});
