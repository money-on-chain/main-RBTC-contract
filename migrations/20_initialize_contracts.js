/* eslint-disable no-console */
const utils = require('./utils');
const allConfigs = require('./configs/config');
const { toContract } = require('../utils/numberHelper.js');
const BigNumber = require('bignumber.js');

const MoCStateMock = artifacts.require('./mocks/MoCStateMock.sol');
const MoCSettlementMock = artifacts.require('./mocks/MoCSettlementMock.sol');
const MoCSettlement = artifacts.require('./MoCSettlement.sol');
const MoCState = artifacts.require('./MoCState.sol');
const MoC = artifacts.require('./MoC.sol');
const MoCInrate = artifacts.require('./MoCInrate.sol');
const MocInrateChanger = artifacts.require('./MocInrateChanger.sol');
const Governor = artifacts.require('./Governor.sol');

const getCommissionsArray = (moc, mocInrate) => async () => {
  let mocPrecision = 10 ** 18;
  if (typeof moc !== 'undefined') {
    mocPrecision = await moc.getMocPrecision();
  }

  const ret = [
    {
      txType: (await mocInrate.MINT_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(0.001)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(0.002)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(0.003)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(0.004)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(0.005)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(0.006)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(0.007)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(0.008)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_MOC()).toString(),
      fee: BigNumber(0.009)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_MOC()).toString(),
      fee: BigNumber(0.01)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(0.011)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(0.012)
        .times(mocPrecision)
        .toString()
    }
  ];
  return ret;
};

module.exports = async (deployer, currentNetwork, [owner]) => {
  // Workaround to get the link working on tests
  const { createInstances, initializeContracts, getProxies, getProxyAddress } = await utils.makeUtils(
    artifacts,
    currentNetwork,
    allConfigs[currentNetwork],
    owner,
    deployer
  );

  if (utils.isDevelopment(currentNetwork)) await createInstances(MoCSettlementMock, MoCStateMock);
  else await createInstances(MoCSettlement, MoCState);
  console.log(`Initialize contracts - network: ${currentNetwork}`);
  await initializeContracts();

  const proxies = getProxies();
  const moc = await MoC.at(getProxyAddress(proxies, 'MoC'));
  const mocInrate = await MoCInrate.at(getProxyAddress(proxies, 'MoCInrate'));


  //const bitProRate = toContract(0.000047945 * 10 ** 18); // mocPrecision -- weekly 0.0025 / 365 * 7
  const dayBlockSpan = 7 * allConfigs[currentNetwork].dayBlockSpan;
  const btcxTmin = toContract(allConfigs[currentNetwork].btcxTmin);
  const btcxTmax = toContract(allConfigs[currentNetwork].btcxTmax * 10 ** 18);
  const btcxPower = toContract(allConfigs[currentNetwork].btcxPower);
  const bitProHolderRate = toContract(allConfigs[currentNetwork].bitProHolderRate);
  const docTmin = toContract(allConfigs[currentNetwork].docTmin);
  const docTmax = toContract(allConfigs[currentNetwork].docTmax);
  const docPower = toContract(allConfigs[currentNetwork].docPower);
    // Setting commissions
  const commissions = await getCommissionsArray(moc, mocInrate)();

  const mockMocInrateChanger = await MocInrateChanger.new(
    mocInrate.address,
    dayBlockSpan,
    btcxTmin,
    btcxTmax,
    btcxPower,
    bitProHolderRate,
    // commissionRate,
    docTmin,
    docTmax,
    docPower,
    commissions,
    { from: owner }
  );

  //const governor = await Governor.at(allConfigs[currentNetwork].governor);
  const governor = await Governor.deployed();

  // Execute changes in MoCInrate
  await governor.executeChange(mockMocInrateChanger.address);
};
