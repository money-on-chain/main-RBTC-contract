const { assert } = require('chai');
const { expectRevert } = require('openzeppelin-test-helpers');
const testHelperBuilder = require('../../mocHelper.js');

let mocHelper;
let toContractBN;

const { BN } = web3.utils;

// eslint-disable-next-line quotes
const NOT_ENOUGH_FUNDS_ERROR = "sender doesn't have enough funds to send tx";

contract('MoC: MoCExchange', function([owner, userAccount, commissionsAccount]) {
  before(async function() {
    mocHelper = await testHelperBuilder({ owner });
    ({ toContractBN } = mocHelper);
    this.moc = mocHelper.moc;
    this.mockMocInrateChanger = mocHelper.mockMocInrateChanger;
    this.governor = mocHelper.governor;
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

  describe('BPro minting with commissions', function() {
    const scenarios = [
      // RBTC commission
      {
        params: {
          bproToMint: 1000,
          mocAmount: 0
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 1, // (bproToMint * MINT_BPRO_FEES_RBTC = 0.001)
          totalCostOnBtc: 1001,
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      // MoC commission
      {
        params: {
          bproToMint: 1000,
          mocAmount: 1000
        },
        expect: {
          bproToMint: 1000,
          bproToMintOnRbtc: 1000,
          commissionAmountRbtc: 0,
          totalCostOnBtc: 1000,
          commissionAmountMoC: 7, // (bproToMint * MINT_BPRO_FEES_MOC = 0.007)
          mocAmount: 993
        }
      }
    ];
    scenarios.forEach(async scenario => {
      describe(`GIVEN ${scenario.params.bproToMint} BitPro are minted and ${scenario.params.mocAmount} MoC are available in user account`, function() {
        let prevUserBtcBalance;
        let prevUserBproBalance;
        let prevCommissionsAccountBtcBalance;
        let prevMocBtcBalance;
        let usedGas;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;

        beforeEach(async function() {
          await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
          await mocHelper.approveMoCToken(
            mocHelper.moc.address,
            scenario.params.mocAmount,
            userAccount
          );
          // Set transaction type according to scenario
          const txType =
            scenario.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          // Calculate balances before minting
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserBproBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevMocBtcBalance = toContractBN(await web3.eth.getBalance(this.moc.address));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const mintTx = await mocHelper.mintBProAmount(
            userAccount,
            scenario.params.bproToMint,
            txType
          );
          usedGas = toContractBN(await mocHelper.getTxCost(mintTx));
        });
        it(`THEN the user has ${scenario.expect.bproToMint} more BitPros`, async function() {
          const UserBproBalance = await mocHelper.getBProBalance(userAccount);
          const diff = UserBproBalance.sub(prevUserBproBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMint,
            'user bitPro balance is incorrect'
          );
        });
        it(`THEN the user rbtc balance has decrease by ${scenario.expect.bproToMintOnRbtc} Rbtcs by Mint + ${scenario.expect.commissionAmountRbtc} Rbtcs by commissions`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.totalCostOnBtc,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN global balance increases by the correct amount of BTCs', async function() {
          const mocBtcBalance = await web3.eth.getBalance(this.moc.address);
          const diff = new BN(mocBtcBalance).sub(new BN(prevMocBtcBalance));
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToMintOnRbtc,
            'Should increase sale total amount'
          );
        });
        it(`THEN the commissions account rbtc balance has increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          const commissionsAccountBtcBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          const diff = commissionsAccountBtcBalance.sub(prevCommissionsAccountBtcBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountRbtc,
            'commissions account balance is incorrect'
          );
        });
        it(`THEN the user MoC balance has decreased by ${scenario.expect.commissionAmountMoC} MoCs by commissions`, async function() {
          const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
          const diffAmount = new BN(prevUserMoCBalance).sub(
            new BN(web3.utils.toWei(scenario.expect.commissionAmountMoC.toString()))
          );
          const diffCommission = prevUserMoCBalance.sub(userMoCBalance);
          mocHelper.assertBigRBTC(
            diffAmount,
            scenario.expect.mocAmount,
            'user MoC balance is incorrect'
          );
          mocHelper.assertBigRBTC(
            diffCommission,
            scenario.expect.commissionAmountMoC,
            'MoC commission is incorrect'
          );
        });
        it(`THEN the commissions account MoC balance has increased by ${scenario.expect.commissionAmountMoC} MoCs`, async function() {
          const commissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          const diff = commissionsAccountMoCBalance.sub(prevCommissionsAccountMoCBalance);
          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.commissionAmountMoC,
            'commissions account MoC balance is incorrect'
          );
        });
      });
    });

    describe('GIVEN since the user sends not enough amount to pay comission in RBTC', function() {
      it('WHEN a user tries to mint BPros with 10 RBTCs and does not send to pay commission', async function() {
        const mintBpro = mocHelper.mintBPro(userAccount, 10);
        await expectRevert(mintBpro, 'amount is not enough');
      });
    });

    describe('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to mint BPros with no MoC allowance, THEN expect revert', async function() {
        await mocHelper.mintMoCToken(userAccount, 1000, owner);
        // DO NOT approve MoC token on purpose
        const mintBpro = mocHelper.mintBPro(userAccount, 10);
        await expectRevert(mintBpro, 'amount is not enough');
      });
    });
    describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
      it('WHEN a user tries to mint BPros with MoC allowance, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        // DO NOT mint MoC token on purpose
        await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);

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

        const txType = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
        // Mint
        const mintBpro = await mocHelper.mintBProAmount(otherAddress, mintAmount, txType);
        const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro));

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
      it('WHEN a user tries to mint BPros, THEN expect exception', async function() {
        const password = '!@superpassword';
        const failingAddress = await web3.eth.personal.newAccount(password);
        await web3.eth.personal.unlockAccount(failingAddress, password, 600);

        await web3.eth.sendTransaction({
          from: owner,
          to: failingAddress,
          value: '10000000000000'
        });
        try {
          await mocHelper.mintBPro(failingAddress, 10);
          assert.fail('Minting BPro should have failed');
        } catch (err) {
          assert(err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0, 'Sender does have enough funds');
        }
      });
    });
    describe('GIVEN since the address of the MoCToken is 0x0', function() {
      it('WHEN a user tries to mint BPros, THEN commission is paid in RBTC', async function() {
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

        const txType = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
        // Mint
        const mintBpro = await mocHelper.mintBProAmount(otherAddress, mintAmount, txType);
        const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro));

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
