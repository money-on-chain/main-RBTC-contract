const testHelperBuilder = require('../mocHelper.js');

let mocHelper;
let BUCKET_X2;
contract('MoC: RedeemBProx', function([owner, vendorAccount, ...accounts]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    this.moc = mocHelper.moc;
    ({ BUCKET_X2 } = mocHelper);
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Register vendor for test
    await mocHelper.registerVendor(vendorAccount, 0, owner);
  });

  const scenarios = [
    {
      description: 'One Position and price goes down',
      users: [
        {
          btcPrice: 9500.23,
          nBPro: 10,
          nDoc: 10000,
          bproxMint: {
            nB: 1
          }
        }
      ]
    },
    {
      description: 'Three positions and price goes up',
      // Loads X2 with nB: 1 and nDoc: 10000
      users: [
        {
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.5
          }
        },
        {
          btcPrice: 9668.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.6
          }
        },
        {
          btcPrice: 10883.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.3
          }
        }
      ]
    },
    {
      description: 'Two positions and price going down',
      // Loads X2 with nB: 1 and nDoc: 10000
      users: [
        {
          btcPrice: 9668.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.4
          }
        },
        {
          btcPrice: 8000.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.6
          }
        }
      ]
    },
    {
      description: 'Two positions and price going up',
      // Loads X2 with nB: 1 and nDoc: 10000
      users: [
        {
          btcPrice: 10233.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.4
          }
        },
        {
          btcPrice: 11023.33,
          nBPro: 5,
          nDoc: 5000,
          bproxMint: {
            nB: 0.6
          }
        }
      ]
    }
  ];
  scenarios.forEach(s => {
    describe(`GIVEN there are ${s.description}`, function() {
      beforeEach(async function() {
        await new Promise(resolve => {
          s.users.forEach(async (user, index) => {
            const account = accounts[index + 1];

            await mocHelper.mintBProAmount(account, user.nBPro, vendorAccount);
            await mocHelper.mintDocAmount(account, user.nDoc, vendorAccount);
            await mocHelper.mintBProx(account, BUCKET_X2, user.bproxMint.nB, vendorAccount);
            if (index === s.users.length - 1) resolve();
          });
        });
      });
      describe('WHEN all users redeem their BUCKET_X2 positions', function() {
        it('THEN BUCKET_X2 bucket should be empty', async function() {
          await new Promise(resolve => {
            s.users.forEach(async (user, index) => {
              const userBProxBalance = await mocHelper.getBProxBalance(
                BUCKET_X2,
                accounts[index + 1]
              );

              if (user.btcPrice) {
                await mocHelper.setBitcoinPrice(user.btcPrice * mocHelper.MOC_PRECISION);
              }

              await mocHelper.redeemBProx(
                accounts[index + 1],
                BUCKET_X2,
                userBProxBalance,
                vendorAccount
              );

              if (index === s.users.length - 1) resolve();
            });
          });

          const { nB, nBPro, nDoc } = await mocHelper.getBucketState(BUCKET_X2);
          mocHelper.assertBig(nB, 0, 'nB is not empty');
          mocHelper.assertBig(nBPro, 0, 'nBPro is not empty');
          mocHelper.assertBig(nDoc, 0, 'nDoc is not empty');
        });
      });
    });
  });
});
