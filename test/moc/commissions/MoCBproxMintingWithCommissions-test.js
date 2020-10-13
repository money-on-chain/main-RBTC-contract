const testHelperBuilder = require('../../mocHelper.js');
const { expectRevert } = require('openzeppelin-test-helpers');

let mocHelper;
let toContractBN;
let BUCKET_X2;

const { BN } = web3.utils;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";

contract('MoC : MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner, useMock: true });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mocState = mocHelper.mocState;
    ({ BUCKET_X2 } = mocHelper);
    this.mocToken = mocHelper.mocToken;
    this.mocConnector = mocHelper.mocConnector;
  });

  beforeEach(async function() {
    await mocHelper.revertState();

    // Commission rates are set in contractsBuilder.js

    // set commissions address
    await mocHelper.mockMocInrateChanger.setCommissionsAddress(commissionsAccount);
    // update params
    await mocHelper.governor.executeChange(mocHelper.mockMocInrateChanger.address);
  });

  describe.only('BProx minting with commissions', function() {
    const scenarios = [
      // // RBTC commission
      {
        params: {
          nBProx: 5,
          mocAmount: 0
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5.025',
          commission: {
            nBtc: '0.025'  // (nBProx * MINT_BTCX_FEES_RBTC = 0.005)
          },
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      {
        params: {
          nBProx: 10,
          mocAmount: 0
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8.04',
          commission: {
            nBtc: '0.04'  // (nBProx * MINT_BTCX_FEES_RBTC = 0.005)
          },
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      // MoC commission
      {
        params: {
          nBProx: 5,
          mocAmount: 1000
        },
        expect: {
          nBProx: '5',
          nBtc: '5',
          totalCostOnBtc: '5',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.00055', // (nBProx * MINT_BTCX_FEES_MOC = 0.00011)
          mocAmount: '999.80145' // mocAmount - commissionAmountMoC - commissionMintBpro (0.126) - commissionMintDoc (0.072)
        }
      },
      {
        params: {
          nBProx: 10,
          mocAmount: 1000
        },
        expect: {
          nBProx: '8',
          nBtc: '8',
          totalCostOnBtc: '8',
          commission: {
            nBtc: '0'
          },
          commissionAmountMoC: '0.00088', // (nBProx * MINT_BTCX_FEES_MOC = 0.00011)
          mocAmount: '999.80112' // mocAmount - commissionAmountMoC - commissionMintBpro (0.126) - commissionMintDoc (0.072)
        }
      }
    ];

    describe('GIVEN the user have 18 BPro and 8000 DOCs and no interest is charged', function() {

      scenarios.forEach(async s => {
        describe(`WHEN a user sends BTC to mint ${s.params.nBProx} Bprox`, function() {
          let initialCommissionAccountBalance;
          let prevUserBtcBalance;
          let txCost;
          let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
          let prevCommissionsAccountMoCBalance;

          beforeEach(async function() {
            await mocHelper.mintMoCToken(userAccount, s.params.mocAmount, owner);
            await mocHelper.approveMoCToken(
              mocHelper.moc.address,
              s.params.mocAmount,
              userAccount
            );

            await this.mocState.setDaysToSettlement(toContractBN(0, 'DAY'));
            // Mint according to scenario
            const txTypeMintBPro =
              s.params.mocAmount === 0
                ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
                : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
            const txTypeMintDoc =
                s.params.mocAmount === 0
                  ? await mocHelper.mocInrate.MINT_DOC_FEES_RBTC()
                  : await mocHelper.mocInrate.MINT_DOC_FEES_MOC();
            await mocHelper.mintBProAmount(userAccount, 18, txTypeMintBPro);
            await mocHelper.mintDocAmount(userAccount, 80000, txTypeMintDoc);

            // Calculate balances before minting
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            initialCommissionAccountBalance = toContractBN(
              await web3.eth.getBalance(commissionsAccount)
            );
            prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
            prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);

            // Set transaction type according to scenario
            const txType =
            s.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();

            const tx = await mocHelper.mintBProxAmount(userAccount, BUCKET_X2, s.params.nBProx, txType);
            txCost = toContractBN(await mocHelper.getTxCost(tx));

            // console.log("txTypeMintBPro: ", txTypeMintBPro.toString());
            // console.log("txTypeMintDoc: ", txTypeMintDoc.toString());
            // console.log("txType: ", txType.toString());
            // console.log("MoC token address: ", this.mocToken.address);
            // console.log("MoC token allowance: ", (await this.mocToken.allowance(userAccount, this.mocToken.address)).toString());
          });
          it(`THEN he receives ${s.expect.nBProx} Bprox`, async function() {
            const balance = await mocHelper.getBProxBalance(BUCKET_X2, userAccount);
            mocHelper.assertBigRBTC(balance, s.expect.nBProx, 'Bprox balance is incorrect');
          });
          it(`THEN the user rbtc balance has decrease by ${s.expect.nBtc} Rbtcs by Mint + ${s.expect.commission.nBtc} Rbtcs by commissions`, async function() {
            const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
            const diff = prevUserBtcBalance.sub(userBtcBalance).sub(txCost);

            // console.log("prevUserBtcBalance: ", prevUserBtcBalance.toString());
            // console.log("userBtcBalance: ", userBtcBalance.toString());
            // console.log("txCost: ", txCost.toString());
            // console.log("diff: ", diff.toString());
            // console.log("mocHelper.mocInrate.MINT_BTCX_FEES_MOC(): ", (await mocHelper.mocInrate.MINT_BTCX_FEES_MOC()).toString());
            // console.log("mocHelper.mocInrate.commissionRatesByTxType(11): ", (await mocHelper.mocInrate.commissionRatesByTxType(11)).toString());
            // console.log("mocHelper.mocInrate.calcComissionValue(): ", (await mocHelper.mocInrate.calcCommissionValue('1000000000000000000',11)).toString());
            // console.log("prevUserMoCBalance: ", prevUserMoCBalance.toString());
            // const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
            // console.log("userMoCBalance: ", userMoCBalance.toString());

            mocHelper.assertBigRBTC(
              diff,
              s.expect.totalCostOnBtc,
              'user rbtc balance is incorrect'
            );
          });
          it('THEN the commissions accounts balance increase', async function() {
            const balance = toContractBN(await web3.eth.getBalance(commissionsAccount));
            const diff = balance.sub(initialCommissionAccountBalance);
            const expected = toContractBN(s.expect.commission.nBtc, 'BTC');
            mocHelper.assertBig(diff, expected, 'the commissions accounts balance is not correct');
          });
          it(`THEN the user MoC balance has decreased by ${s.expect.commissionAmountMoC} MoCs by commissions`, async function() {
            const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
            const diffAmount = new BN(prevUserMoCBalance).sub(
              new BN(web3.utils.toWei(s.expect.commissionAmountMoC.toString()))
            );
            const diffCommission = prevUserMoCBalance.sub(userMoCBalance);
            mocHelper.assertBigRBTC(
              diffAmount,
              s.expect.mocAmount,
              'user MoC balance is incorrect'
            );
            mocHelper.assertBigRBTC(
              diffCommission,
              s.expect.commissionAmountMoC,
              'MoC commission is incorrect'
            );
          });
          it(`THEN the commissions account MoC balance has increased by ${s.expect.commissionAmountMoC} MoCs`, async function() {
            const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
            const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);
            mocHelper.assertBigRBTC(
              diff,
              s.expect.commissionAmountMoC,
              'commissions account MoC balance is incorrect'
            );
          });
        });
      });
    });
    // TODO: check if it should revert
    describe('GIVEN since the user sends not enough amount to pay comission in RBTC', function() {
      it('WHEN a user tries to mint BProx with 10 RBTCs and does not send to pay commission', async function() {
        const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
        const mint = await mocHelper.mintBProx(userAccount, BUCKET_X2, 10, 10);
        //await expectRevert.unspecified(mint);
      });
    });
    // TODO: check if it should revert
    describe('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to mint BProx with no MoC allowance, THEN expect revert', async function() {
        await mocHelper.mintMoCToken(userAccount, 1000, owner);
        // DO NOT approve MoC token on purpose
        const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
        const mint = await mocHelper.mintBProx(userAccount, BUCKET_X2, 10);
        //await expectRevert.unspecified(mint);
      });
    });
    describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
      it('WHEN a user tries to mint BProx with MoC allowance, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        // DO NOT mint MoC token on purpose
        await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);

        const prevUserMoCBalanceOtherAddress = new BN(0); // No MoC balance
        const expectedMoCAmount = 0;
        const expectedMoCCommission = 0;
        const mintAmount = 100;
        const expectedRbtcCommission = 0.5; // mintAmount * MINT_BTCX_FEES_RBTC()
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = 100.5; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
        // Mint
        //const mint = await mocHelper.mintBProxAmount(otherAddress, mintAmount, txType);
        const mint = await mocHelper.mintBProxAmount(otherAddress, BUCKET_X2, mintAmount, txType);
        //const mint = await mocHelper.mintBProx(otherAddress, BUCKET_X2, mintAmo);
        const usedGas = toContractBN(await mocHelper.getTxCost(mint));

        const userMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress);
        const diffMoCAmount = prevUserMoCBalanceOtherAddress.sub(new BN(expectedMoCCommission));
        const diffMoCCommission = prevUserMoCBalanceOtherAddress.sub(userMoCBalanceOtherAddress);

        // RBTC commission
        const commissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );
        const diffRbtcCommission = commissionsAccountBtcBalance.sub(
          prevCommissionsAccountBtcBalance
        );
        const userBtcBalanceOtherAccount = toContractBN(await web3.eth.getBalance(otherAddress));
        const diffRbtcAmount = prevUserBtcBalanceOtherAddress
          .sub(userBtcBalanceOtherAccount)
          .sub(usedGas);

        mocHelper.assertBigRBTC(diffMoCAmount, expectedMoCAmount, 'user MoC balance is incorrect');
        mocHelper.assertBigRBTC(
          diffMoCCommission,
          expectedMoCCommission,
          'MoC commission is incorrect'
        );
        mocHelper.assertBigRBTC(
          diffRbtcAmount,
          expectedRbtcAmount,
          'user rbtc balance is incorrect'
        );
        mocHelper.assertBigRBTC(
          diffRbtcCommission,
          expectedRbtcCommission,
          'commissions account balance is incorrect'
        );
      });
    });
    describe('GIVEN since the user does not have MoC nor RBTC balance, but there is MoC allowance', function() {
      it('WHEN a user tries to mint BProx, THEN expect exception', async function() {
        const password = '!@superpassword';
        const failingAddress = await web3.eth.personal.newAccount(password);
        await web3.eth.personal.unlockAccount(failingAddress, password, 600);

        try {
          await web3.eth.sendTransaction({
            from: owner,
            to: failingAddress,
            value: '10000000000000'
          });
          await mocHelper.mintMoCToken(failingAddress, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
          const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_MOC();
          const mint = await mocHelper.mintBProxAmount(failingAddress, 10, txType);
          assert(mint === null, 'This should not happen');
        } catch (err) {
          assert(
            err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
            'Sender does not have enough funds'
          );
        }
      });
    });
    describe('GIVEN since the address of the MoCToken is 0x0', function() {
      it('WHEN a user tries to mint BProx, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        const mocTokenAddress = this.mocToken.address;
        // Set MoCToken address to 0
        const zeroAddress = '0x0000000000000000000000000000000000000000';
        await this.mocConnector.setMoCToken(zeroAddress);

        const prevUserMoCBalanceOtherAddress = new BN(0); // No MoC balance
        const expectedMoCAmount = 0;
        const expectedMoCCommission = 0;
        const mintAmount = 100;
        const expectedRbtcCommission = 0.1; // mintAmount * MINT_BPRO_FEES_RBTC()
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = 100.1; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_BTCX_FEES_RBTC();
        // Mint
        const mint = await mocHelper.mintBProxAmount(otherAddress, mintAmount, txType);
        const usedGas = toContractBN(await mocHelper.getTxCost(mint));

        const userMoCBalanceOtherAddress = await mocHelper.getMoCBalance(otherAddress);
        const diffMoCAmount = prevUserMoCBalanceOtherAddress.sub(new BN(expectedMoCCommission));
        const diffMoCCommission = prevUserMoCBalanceOtherAddress.sub(userMoCBalanceOtherAddress);

        // RBTC commission
        const commissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );
        const diffRbtcCommission = commissionsAccountBtcBalance.sub(
          prevCommissionsAccountBtcBalance
        );
        const userBtcBalanceOtherAccount = toContractBN(await web3.eth.getBalance(otherAddress));
        const diffRbtcAmount = prevUserBtcBalanceOtherAddress
          .sub(userBtcBalanceOtherAccount)
          .sub(usedGas);

        // Set MoCToken address back to its original address
        await this.mocConnector.setMoCToken(mocTokenAddress);

        mocHelper.assertBigRBTC(diffMoCAmount, expectedMoCAmount, 'user MoC balance is incorrect');
        mocHelper.assertBigRBTC(
          diffMoCCommission,
          expectedMoCCommission,
          'MoC commission is incorrect'
        );
        mocHelper.assertBigRBTC(
          diffRbtcAmount,
          expectedRbtcAmount,
          'user rbtc balance is incorrect'
        );
        mocHelper.assertBigRBTC(
          diffRbtcCommission,
          expectedRbtcCommission,
          'commissions account balance is incorrect'
        );
      });
    });
  });
});
