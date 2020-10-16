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

  describe('BPro rediming with commissions', function() {
    const scenarios = [
      // RBTC commission
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 0
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 99.8, // (bproToRedeem) - (bproToRedeem * commissionRate)
          commissionAmountRbtc: 0.2, // (bproToRedeem * REDEEM_BPRO_FEES_RBTC = 0.002)
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 0
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0.1, // (bproToRedeem * REDEEM_BPRO_FEES_RBTC = 0.002)
          bproToRedeemOnRBTC: 49.9, // (bproToRedeem) - (bproToRedeem * commissionRate)
          commissionAmountMoC: 0,
          mocAmount: 0
        }
      },
      // MoC commission
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 100,
          mocAmount: 1000
        },
        expect: {
          bproRedeemed: 100,
          bproToRedeemOnRBTC: 100,
          commissionAmountRbtc: 0,
          commissionAmountMoC: 0.8, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          mocAmount: 998.5 // mocAmount - (bproToRedeem * MINT_BPRO_FEES_MOC) = 1000 - 0.7 = 999.3
          // => 999.3 - (bproToRedeem * REDEEM_BPRO_FEES_MOC)
        }
      },
      {
        params: {
          bproToMint: 100,
          bproToRedeem: 50,
          mocAmount: 1000
        },
        expect: {
          bproRedeemed: 50,
          commissionAmountRbtc: 0,
          bproToRedeemOnRBTC: 50,
          commissionAmountMoC: 0.4, // (bproToRedeem * REDEEM_BPRO_FEES_MOC = 0.008)
          mocAmount: 998.9 // mocAmount - (bproToRedeem * MINT_BPRO_FEES_MOC) = 1000 - 0.007 = 999.3
          // => 999.3 - (bproToRedeem * REDEEM_BPRO_FEES_MOC)
        }
      }
    ];

    scenarios.forEach(async scenario => {
      describe(`WHEN he tries to redeem ${scenario.params.bproToRedeem} BPros`, function() {
        let initialBProBalance;
        let prevCommissionAccountBalance;
        let prevUserBtcBalance;
        let prevUserMoCBalance; // If user has MoC balance, then commission fees will be in MoC
        let prevCommissionsAccountMoCBalance;
        let tx;
        let txCost;

        beforeEach(async function() {
          await mocHelper.mintMoCToken(userAccount, scenario.params.mocAmount, owner);
          await mocHelper.approveMoCToken(
            mocHelper.moc.address,
            scenario.params.mocAmount,
            userAccount
          );
          // Mint according to scenario
          const txTypeMint =
            scenario.params.mocAmount === 0
              ? await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC()
              : await mocHelper.mocInrate.MINT_BPRO_FEES_MOC();
          await mocHelper.mintBProAmount(userAccount, scenario.params.bproToMint, txTypeMint);
          // Calculate balances before redeeming
          initialBProBalance = await mocHelper.getBProBalance(userAccount);
          prevCommissionAccountBalance = toContractBN(
            await web3.eth.getBalance(commissionsAccount)
          );
          prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
          prevCommissionsAccountMoCBalance = await mocHelper.getMoCBalance(commissionsAccount);
          tx = await mocHelper.redeemBPro(userAccount, scenario.params.bproToRedeem);
          txCost = toContractBN(await mocHelper.getTxCost(tx));
        });

        it(`THEN the user has ${scenario.expect.bproToRedeemOnRBTC} more rbtc`, async function() {
          const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
          const diff = userBtcBalance.sub(prevUserBtcBalance).add(txCost);

          mocHelper.assertBigRBTC(
            diff,
            scenario.expect.bproToRedeemOnRBTC,
            'user rbtc balance is incorrect'
          );
        });
        it('THEN he receives only the max redeem amount', async function() {
          const bproBalance = await mocHelper.getBProBalance(userAccount);
          const balanceDiff = initialBProBalance.sub(bproBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.bproRedeemed,
            'The redemption bpro amount was incorrect'
          );
        });
        it(`THEN commission account balance increase by ${scenario.expect.commissionAmountRbtc} Rbtcs`, async function() {
          const btcBalance = toContractBN(await web3.eth.getBalance(commissionsAccount));
          const balanceDiff = btcBalance.sub(prevCommissionAccountBalance);

          mocHelper.assertBigRBTC(
            balanceDiff,
            scenario.expect.commissionAmountRbtc,
            'The commission account balance is incorrect'
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
    describe('GIVEN since there is no allowance to pay comission in MoC', function() {
      it('WHEN a user tries to redeem BPros with no MoC allowance, THEN commission is paid in RBTC', async function() {
        const mocAmountToMint = 1000;
        const mocAmountToApprove = 0;
        const rbtcExpectedBalance = 0;
        await mocHelper.mintMoCToken(userAccount, mocAmountToMint, owner);
        await mocHelper.approveMoCToken(mocHelper.moc.address, mocAmountToApprove, userAccount);
        const prevUserMoCBalance = await mocHelper.getMoCBalance(userAccount);
        const prevUserBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
        const tx = await mocHelper.redeemBPro(userAccount, 10);
        const userMoCBalance = await mocHelper.getMoCBalance(userAccount);
        const diffMoC = prevUserMoCBalance.sub(userMoCBalance);
        const userBtcBalance = toContractBN(await web3.eth.getBalance(userAccount));
        const usedGas = toContractBN(await mocHelper.getTxCost(tx));
        const diffRbtc = prevUserBtcBalance.sub(userBtcBalance).sub(usedGas);

        // Check that the used paid in RBTC because MoC allowance is 0
        mocHelper.assertBigRBTC(diffMoC, mocAmountToApprove, 'user MoC balance is incorrect');

        mocHelper.assertBigRBTC(diffRbtc, rbtcExpectedBalance, 'user RBTC balance is incorrect');
      });
    });
    describe('GIVEN since the user does not have MoC, but there is MoC allowance AND RBTC balance', function() {
      it('WHEN a user tries to redeem BPros with MoC allowance, THEN commission is paid in RBTC', async function() {
        const accounts = await web3.eth.getAccounts();
        const otherAddress = accounts[1];
        // DO NOT mint MoC token on purpose
        await mocHelper.approveMoCToken(mocHelper.moc.address, 1000, otherAddress);

        const prevUserMoCBalanceOtherAddress = new BN(0); // No MoC balance
        const expectedMoCAmount = 0;
        const expectedMoCCommission = 0;
        const mintAmount = 100;
        const redeemAmount = 100;
        // commission = mintAmount * MINT_BPRO_FEES_RBTC() + redeemAmount * REDEEM_BPRO_FEES_RBTC()
        const expectedRbtcCommission = 0.3;
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = expectedRbtcCommission; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
        // Mint
        const mintBpro = await mocHelper.mintBProAmount(otherAddress, mintAmount, txType);
        const redeemBpro = await mocHelper.redeemBPro(userAccount, redeemAmount);
        const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro)).add(
          toContractBN(await mocHelper.getTxCost(redeemBpro))
        );

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
    describe('GIVEN since the user does not have MoC nor BPro balance, but there is MoC allowance', function() {
      it('WHEN a user tries to redeem BPros, THEN expect exception', async function() {
        const password = '!@superpassword';
        const failingAddress = await web3.eth.personal.newAccount(password);
        await web3.eth.personal.unlockAccount(failingAddress, password, 600);
        // User does not have BPro to redeem

        try {
          await mocHelper.mintMoCToken(failingAddress, 0, owner);
          await mocHelper.approveMoCToken(mocHelper.moc.address, 0, failingAddress);
          const tx = await mocHelper.redeemBPro(failingAddress, 10);
          assert(tx === null, 'This should not happen');
        } catch (err) {
          assert(
            err.message.search(NOT_ENOUGH_FUNDS_ERROR) >= 0,
            'Sender does not have enough funds'
          );
        }
      });
    });
    describe('GIVEN since the address of the MoCToken is 0x0', function() {
      it('WHEN a user tries to redeem BPros, THEN commission is paid in RBTC', async function() {
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
        const redeemAmount = 100;
        // commission = mintAmount * MINT_BPRO_FEES_RBTC() + redeemAmount * REDEEM_BPRO_FEES_RBTC()
        const expectedRbtcCommission = 0.3;
        const prevUserBtcBalanceOtherAddress = toContractBN(
          await web3.eth.getBalance(otherAddress)
        );
        const expectedRbtcAmount = expectedRbtcCommission; // total cost
        const prevCommissionsAccountBtcBalance = toContractBN(
          await web3.eth.getBalance(commissionsAccount)
        );

        const txType = await mocHelper.mocInrate.MINT_BPRO_FEES_RBTC();
        // Mint
        const mintBpro = await mocHelper.mintBProAmount(otherAddress, mintAmount, txType);
        const redeemBpro = await mocHelper.redeemBPro(userAccount, redeemAmount);
        const usedGas = toContractBN(await mocHelper.getTxCost(mintBpro)).add(
          toContractBN(await mocHelper.getTxCost(redeemBpro))
        );

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
