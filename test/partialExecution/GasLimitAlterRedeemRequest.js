const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let toContractBN;
const NOT_AVAILABLE = 'This is not an active redeemer';
const OUT_OF_BOUNDARIES = 'Index out of boundaries';
const scenario = {
  accounts: 3,
  mintBpro: 1000000,
  mintDoc: 100000,
  redeemRequestPerAccount: 50,
  redeemAmountInitOwner: 1,
  redeemAmountInitAccount2: 100,
  redeemAmountInitAccount3: 88,
  redeemStress: 10,
  redeemStressSizePerAccount: 2,
  redeemAlterAdd: 100,
  redeemAlterSub: 90,
  expect: {
    redeemQueueSize: 3,
    redeemAmountOwnerAfterAdd: 150,
    redeemAmountOwnerAfterSub: 60,
    redeemAmountAccount2AfterSub: 0
  }
};

const initializeSettlement = async (owner, account2, account3, arrayRedeemSize, vendorAccount) => {
  await mocHelper.mintBProAmount(owner, scenario.mintBpro, vendorAccount, { from: owner });
  await mocHelper.mintDocAmount(owner, scenario.mintDoc, vendorAccount, { from: owner });

  const promisesOwner = [...Array(arrayRedeemSize).keys()].map(() =>
    mocHelper.moc.redeemDocRequest(toContractBN(scenario.redeemAmountInitOwner, 'USD'), {
      from: owner
    })
  );

  const promisesAccount2 = [...Array(arrayRedeemSize).keys()].map(() =>
    mocHelper.moc.redeemDocRequest(toContractBN(scenario.redeemAmountInitAccount2, 'USD'), {
      from: account2
    })
  );

  const promisesAccount3 = [...Array(arrayRedeemSize).keys()].map(() =>
    mocHelper.moc.redeemDocRequest(toContractBN(scenario.redeemAmountInitAccount3, 'USD'), {
      from: account3
    })
  );

  const promises = promisesOwner.concat(promisesAccount2).concat(promisesAccount3);

  await Promise.all(promises);
};

const initializeSettlementStress = async (accounts, arrayRedeemSize, vendorAccount) => {
  mocHelper.revertState();
  // Avoid interests
  await mocHelper.mocState.setDaysToSettlement(0);
  const docAccounts = accounts.slice(0, 5);
  await Promise.all(
    docAccounts.map(account => mocHelper.mintBProAmount(account, 100000, vendorAccount))
  );
  await Promise.all(
    docAccounts.map(account => mocHelper.mintDocAmount(account, 100000, vendorAccount))
  );

  let promises = [];

  accounts.map(account => {
    const promisesByAccount = [...Array(arrayRedeemSize).keys()].map(() =>
      mocHelper.moc.redeemDocRequest(toContractBN(100, 'USD'), {
        from: account
      })
    );

    promises = promises.concat(promisesByAccount);
    return promisesByAccount;
  });

  await Promise.all(promises);
  await mocHelper.mocSettlement.setBlockSpan(1);
};

contract.skip('MoC: Gas limit on alter redeem request', function([
  owner,
  account2,
  account3,
  account4,
  vendorAccount,
  ...accounts
]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);

    await initializeSettlement(
      owner,
      account2,
      account3,
      scenario.redeemRequestPerAccount,
      vendorAccount
    );
  });

  describe(`GIVEN there are ${scenario.accounts} accounts which call redeemDocRequest ${scenario.redeemRequestPerAccount} times per account`, function() {
    it(`THEN there are only ${scenario.expect.redeemQueueSize} RedeemRequest`, async function() {
      const redeemQueueSize = await mocHelper.moc.redeemQueueSize();
      mocHelper.assertBig(
        redeemQueueSize,
        scenario.expect.redeemQueueSize,
        `There are not ${scenario.expect.redeemQueueSize} Redeem Request`
      );
    });
    it('THEN each account must have amount != 0 per RedeemRequest', async function() {
      const totalOwner = await mocHelper.moc.docAmountToRedeem(owner);
      mocHelper.assertBigDollar(
        totalOwner,
        scenario.redeemRequestPerAccount * scenario.redeemAmountInitOwner,
        `Amount != ${scenario.redeemRequestPerAccount *
          scenario.redeemAmountInitOwner} in Redeem Request - owner`
      );

      const totalAccount2 = await mocHelper.moc.docAmountToRedeem(account2);
      mocHelper.assertBigDollar(
        totalAccount2,
        scenario.redeemRequestPerAccount * scenario.redeemAmountInitAccount2,
        `Amount != ${scenario.redeemRequestPerAccount *
          scenario.redeemAmountInitAccount2} in Redeem Request - account 2`
      );

      const totalAccount3 = await mocHelper.moc.docAmountToRedeem(account3);
      mocHelper.assertBigDollar(
        totalAccount3,
        scenario.redeemRequestPerAccount * scenario.redeemAmountInitAccount3,
        `Amount != ${scenario.redeemRequestPerAccount *
          scenario.redeemAmountInitAccount3} in Redeem Request - account 3`
      );
    });
  });

  describe(`GIVEN there are ${scenario.accounts} accounts`, function() {
    describe(`AND an owner adds ${scenario.redeemAlterAdd} Doc to Redeem Request`, function() {
      it(`THEN the account must have ${scenario.expect.redeemAmountOwnerAfterAdd} Docs on RedeemRequest`, async function() {
        const tx = await mocHelper.moc.alterRedeemRequestAmount(
          true,
          toContractBN(100 * mocHelper.MOC_PRECISION),
          {
            from: owner
          }
        );
        const totalOwner = await mocHelper.moc.docAmountToRedeem(owner);
        mocHelper.assertBigDollar(
          totalOwner,
          scenario.expect.redeemAmountOwnerAfterAdd,
          `Amount != ${scenario.expect.redeemAmountOwnerAfterAdd} in Redeem Request - owner`
        );

        const redeemEvent = await mocHelper.findEvents(tx, 'RedeemRequestAlter', owner);
        mocHelper.assertBigDollar(redeemEvent.delta, 0, 'Delta in adding must be 0');
      });
      describe(`AND an owner subs ${scenario.redeemAlterSub} Doc to Redeem Request`, function() {
        it(`THEN the account must have ${scenario.expect.redeemAmountOwnerAfterSub} Docs on RedeemRequest`, async function() {
          const tx = await mocHelper.moc.alterRedeemRequestAmount(
            false,
            toContractBN(scenario.redeemAlterSub * mocHelper.MOC_PRECISION),
            { from: owner }
          );
          const totalOwner = await mocHelper.moc.docAmountToRedeem(owner);
          mocHelper.assertBigDollar(
            totalOwner,
            scenario.expect.redeemAmountOwnerAfterSub,
            `Amount != ${scenario.expect.redeemAmountOwnerAfterSub} in Redeem Request - owner`
          );
          const redeemEvent = await mocHelper.findEvents(tx, 'RedeemRequestAlter', owner);
          mocHelper.assertBigDollar(redeemEvent.delta, 0, 'Delta in sub must be 0');
        });
      });
    });
  });

  describe(`GIVEN there are ${scenario.accounts} accounts`, function() {
    describe('AND another account tries to alter a redeemRequest without previous creation', function() {
      it('THEN transaction must revert', async function() {
        await expectRevert(
          mocHelper.moc.alterRedeemRequestAmount(
            true,
            toContractBN(100 * mocHelper.MOC_PRECISION),
            {
              from: account4
            }
          ),
          NOT_AVAILABLE
        );
      });
    });
  });
  describe(`GIVEN there are ${scenario.accounts} accounts with redeem request`, function() {
    describe('AND a settlement with 150 steps is run', function() {
      it('THEN redeemQueue must be empty', async function() {
        await mocHelper.moc.runSettlement(150, { gas: 7e6 });
        const redeemQueueSize = await mocHelper.moc.redeemQueueSize();
        mocHelper.assertBig(redeemQueueSize, 0, 'There are Redeem Requests');
      });
      it('THEN all redeem request must be cleaned', async function() {
        const totalOwner = await mocHelper.moc.docAmountToRedeem(owner);
        mocHelper.assertBigDollar(totalOwner, 0, 'Amount != 0 in Redeem Request - owner');

        const totalAccount2 = await mocHelper.moc.docAmountToRedeem(account2);
        mocHelper.assertBigDollar(
          totalAccount2,
          0,
          'Amount != 0 in Redeem Request - totalAccount2'
        );

        const totalAccount3 = await mocHelper.moc.docAmountToRedeem(account3);
        mocHelper.assertBigDollar(
          totalAccount3,
          0,
          'Amount != 0 in Redeem Request - totalAccount3'
        );
      });
      describe('AND owner tries to alter a redeem without creation after settlement', function() {
        it('THEN transaction must revert', async function() {
          await expectRevert(
            mocHelper.moc.alterRedeemRequestAmount(
              true,
              toContractBN(100 * mocHelper.MOC_PRECISION),
              {
                from: owner
              }
            ),
            NOT_AVAILABLE
          );
        });
      });
    });
  });

  describe(`GIVEN there are ${accounts.length} accounts`, function() {
    describe(`AND there are ${scenario.redeemStressSizePerAccount} redeem request creations per account`, function() {
      beforeEach(async function() {
        mocHelper.revertState();
        await initializeSettlementStress(
          accounts,
          scenario.redeemStressSizePerAccount,
          vendorAccount
        );
        const redeemQueueSize = await mocHelper.moc.redeemQueueSize();
        mocHelper.assertBig(
          redeemQueueSize,
          accounts.length,
          `There are not ${accounts.length} redeem Requests`
        );
      });
      it(`THEN redeemQueue size must be ${accounts.length}`, async function() {
        const redeemQueueSizeBeforeSettlement = await mocHelper.moc.redeemQueueSize();
        mocHelper.assertBig(
          redeemQueueSizeBeforeSettlement,
          accounts.length,
          'Redeem Requests amount must match users accounts'
        );
      });
      describe('WHEN a user tries to read redeem request with index = 100000', function() {
        it('THEN transaction must revert', function() {
          return expectRevert(mocHelper.moc.getRedeemRequestAt(100000), OUT_OF_BOUNDARIES);
        });
      });
      describe('WHEN settlement is run to clear redeem queue', function() {
        it('THEN redeemQueue must be empty', async function() {
          // Run N settlement 100 step pages to guarantee completion
          const promisesQuantity = Math.ceil(accounts.length / 100);
          await Promise.all(
            [...Array(promisesQuantity).keys()].map(() =>
              mocHelper.moc.runSettlement(100, { gas: 7e6 })
            )
          );

          const redeemQueueSizeAfterSettlement = await mocHelper.moc.redeemQueueSize();
          mocHelper.assertBig(
            redeemQueueSizeAfterSettlement,
            0,
            'There are Redeem Requests after settlement'
          );
        });
      });
    });
  });
});
