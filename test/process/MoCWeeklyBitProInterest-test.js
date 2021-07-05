const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
let BUCKET_C0;

contract('MoC: BitPro holder interests payment', function([
  owner,
  account,
  targetAddr,
  vendorAccount
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
    ({ BUCKET_C0 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  const scenarios = [
    {
      description: 'There are no money in the inrate bag. C0 buckets keeps the same',
      bitProMintBtc: 0,
      bitProInterestTargetAddress: targetAddr,
      bitProHolderRate: 0.5 * 10 ** 18,
      blockSpan: 20 * 3,
      expect: {
        bucket0AfterInterest: 0,
        targetAddrBalance: 0,
        paymentValue: 0
      }
    },
    {
      description: 'There are money in the bucket 0. Function should decrease C0 bucket RBTCs',
      bitProMintBtc: 2,
      bitProHolderRate: 0.5 * 10 ** 18,
      blockSpan: 20 * 7,
      bitProInterestTargetAddress: targetAddr,
      expect: {
        bucket0AfterInterest: 1,
        targetAddrBalance: 1,
        paymentValue: 1
      }
    }
  ];
  scenarios.forEach(s => {
    let beforeTargetAddressBalance = 0;
    describe('GIVEN there are 2 RBTCs in the C0 nBTC Bucket', function() {
      beforeEach(async function() {
        await mocHelper.mintBPro(account, toContractBN(s.bitProMintBtc), vendorAccount);
        await this.mockMocInrateChanger.setBitProRate(toContractBN(s.bitProHolderRate));
        await this.mockMocInrateChanger.setBitProInterestAddress(s.bitProInterestTargetAddress);
        await this.mockMocInrateChanger.setBitProInterestBlockSpan(s.blockSpan);
        await this.governor.executeChange(this.mockMocInrateChanger.address);
        beforeTargetAddressBalance = toContractBN(await web3.eth.getBalance(targetAddr));
      });
      it(`THEN payment value is ${s.expect.paymentValue}`, async function() {
        const bitProInterest = await mocHelper.calculateBitProHoldersInterest();
        const interestsValue = bitProInterest[0];
        mocHelper.assertBigRBTC(
          interestsValue,
          s.expect.paymentValue,
          'Weekly BitPro holders is deferent'
        );
      });
      it('THEN bitpro blockSpan is correct', async function() {
        const bitProBlockSpan = await mocHelper.getBitProInterestBlockSpan();
        assert(bitProBlockSpan, s.blockSpan, 'BitPro holders blockSpan is deferent');
      });
      it('THEN bitpro weekly rate is correct', async function() {
        const bitProRate = await mocHelper.getBitProRate();
        assert(bitProRate, s.bitProHolderRate, 'BitPro holders rate is deferent');
      });
      it('THEN destination address is correct', async function() {
        const address = await mocHelper.getBitProInterestAddress();
        assert(address, targetAddr, 'Destination address is incorrect');
      });
      describe('WHEN payment is run', function() {
        let tx;
        beforeEach(async function() {
          tx = await mocHelper.payBitProHoldersInterestPayment();
        });
        it('THEN the event is emitted', function() {
          const [event] = mocHelper.findEvents(tx, 'RiskProHoldersInterestPay');

          assert(event, 'Payment event was not emitted');
          mocHelper.assertBigRBTC(
            event.amount,
            s.expect.paymentValue,
            'Amount in event is incorrect'
          );
        });
        it(`THEN bucket C0 BTCs should decrease in ${s.expect.bucket0AfterInterest}`, async function() {
          const { nB } = await mocHelper.getBucketState(BUCKET_C0);
          mocHelper.assertBigRBTC(
            nB,
            s.expect.bucket0AfterInterest,
            'Bucket 0 RBTCs did not decrease'
          );
        });
        it(`THEN destination address balance increase by ${s.expect.targetAddrBalance}`, async function() {
          const afterTargetAddressBalance = toContractBN(await web3.eth.getBalance(targetAddr));

          mocHelper.assertBigRBTC(
            afterTargetAddressBalance.sub(beforeTargetAddressBalance),
            s.expect.targetAddrBalance,
            'Bucket 0 RBTCs did not decrease'
          );
        });
        it('THEN Weekly BitPro holders interest should be disabled', async function() {
          const enabled = await mocHelper.isBitProInterestEnabled();
          assert(!enabled, 'Weekly bitPro holder interest is still enabled');
        });
      });
    });
  });
});
