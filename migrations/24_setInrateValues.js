const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const MoCInrateChanger = artifacts.require('MocInrateChanger.sol');
const MoCInrate = artifacts.require('MoCInrate.sol');
const { toContract } = require('../utils/numberHelper.js');
const BigNumber = require('bignumber.js');

const consolePrintTestVariables = obj => {
  for (let i = 0; i < Object.keys(obj).length; i++) {
    const variableName = Object.keys(obj)[i];
    // eslint-disable-next-line no-console
    console.log(`${variableName}: ${obj[variableName].toString()}`);
  }
};

const getCommissionsArray = (mocInrate) => async () => {
  let mocPrecision = 10 ** 18;

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

module.exports = async deployer => {
  // const proxies = getProxies();
  // const moc = await MoC.at(getProxyAddress(proxies, 'MoC'));
  const mocInrate = await MoCInrate.at('0x3A11535315682780e096a3369E31dd84d9A32aF8');

  //const bitProRate = toContract(0.000047945 * 10 ** 18); // mocPrecision -- weekly 0.0025 / 365 * 7
  const dayBlockSpan = 7 * 2880;
  const btcxTmin = toContract(0.000133681 * 10 ** 18);
  const btcxTmax = toContract(0.004 * 10 ** 18);
  const btcxPower = toContract(4);
  const bitProHolderRate = toContract(0.000047945 * 10 ** 18);
  const docPower = toContract(4);

  // Hardcoding certain values
  const docTmin = toContract(0.000133681 * 10 ** 18);
  const docTmax = toContract(0.004 * 10 ** 18);

  // Setting commissions
  const commissions = await getCommissionsArray(mocInrate)();

  const prueba = {dayBlockSpan, btcxTmin, btcxTmax, btcxPower, bitProHolderRate, docPower, docTmin, docTmax, commissions};
  consolePrintTestVariables(prueba);

  const mockMocInrateChanger = await MoCInrateChanger.new(
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
    commissions
  );

  const governor = await Governor.at('0xC5a3d6cBe0EeF0cF20cF7CA5540deaac19b2129e');
  // Execute changes in MoCInrate
  await governor.executeChange(mockMocInrateChanger.address);
};
