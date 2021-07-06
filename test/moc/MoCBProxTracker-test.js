const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let BUCKET_X2;

contract('MoCBProxManager: BProx Address tracking ', function([
  owner,
  account1,
  account2,
  account3,
  vendorAccount
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ BUCKET_X2 } = mocHelper);
    this.moc = mocHelper.moc;
    this.bprox = mocHelper.bprox;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  describe('GIVEN a new user mints BProx', function() {
    beforeEach(async function() {
      await mocHelper.mintBProAmount(owner, 30, vendorAccount);
      await mocHelper.mintDocAmount(owner, 50000, vendorAccount);
      await mocHelper.mintBProx(account1, BUCKET_X2, 1, vendorAccount);
    });
    it('THEN he enters the address tracker', async function() {
      const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
      assert.equal(activeAddress[0], account1, 'Address is addeed');
    });
    it('THEN if he mints again, tracker is not altered', async function() {
      const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
      const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
      assert.equal(activeAddressLength, 1, 'length should be one');
      assert.equal(activeAddress[0], account1, 'Address is addeed');
    });
    describe('AND another account also mints', function() {
      beforeEach(async function() {
        await mocHelper.mintBProx(account2, BUCKET_X2, 1, vendorAccount);
      });
      it('THEN both get tracked', async function() {
        const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
        const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
        assert.equal(activeAddressLength, 2, 'length should be two');
        assert.equal(activeAddress[1], account2, 'account 1 Address is addeed');
      });
      describe('WHEN account 1 liquidates his entire position', function() {
        beforeEach(async function() {
          await mocHelper.redeemBProx(account1, BUCKET_X2, 1, vendorAccount);
        });
        it('THEN tracker shrinks', async function() {
          const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
          const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
          assert.equal(activeAddressLength, 1, 'length should be one');
          assert.equal(activeAddress[0], account2, 'account 2 should have moved');
        });
        describe('AND a third user mints', function() {
          it('THEN tracker length is two and third user is tracked', async function() {
            await mocHelper.mintBProx(account3, BUCKET_X2, 1, vendorAccount);
            const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
            const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
            assert.equal(activeAddressLength, 2, 'length should be two');
            assert.equal(activeAddress[1], account3, 'account 3 is the last');
          });
        });
        describe('AND account1 mints again', function() {
          it('THEN tracker length is two and owner is last', async function() {
            await mocHelper.mintBProx(account1, BUCKET_X2, 1, vendorAccount);
            const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
            const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
            assert.equal(activeAddressLength, 2, 'length should be two');
            assert.equal(activeAddress[1], account1, 'owner is the new last');
          });
        });
      });
      describe('WHEN account 1 partially liquidates his position', function() {
        it('THEN tracker remains the same', async function() {
          await mocHelper.redeemBProx(account1, BUCKET_X2, 0.5, vendorAccount);
          const activeAddress = await this.bprox.getActiveAddresses(BUCKET_X2);
          const activeAddressLength = await this.bprox.getActiveAddressesCount(BUCKET_X2);
          assert.equal(activeAddressLength, 2, 'length should be unchanged');
          assert.equal(activeAddress[0], account1, 'owner in 0');
          assert.equal(activeAddress[1], account2, 'account1 in 1');
        });
      });
    });
  });
});
