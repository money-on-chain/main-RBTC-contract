const MoCConverter_v019 = artifacts.require('./contracts/MoCConverter_v019.sol');
const MoCHelperLib_v019 = artifacts.require('./contracts/MoCHelperLib_v019.sol');
const MoCConverter = artifacts.require('./contracts/MoCConverter.sol');
const MoCHelperLib = artifacts.require('./contracts/MoCHelperLib.sol');
const MoCConnector = artifacts.require('./contracts/MoCConnector.sol');

const AdminUpgradeabilityProxy = artifacts.require(
  'zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol'
);
const ProxyAdmin = artifacts.require('zos-lib/contracts/upgradeability/ProxyAdmin.sol');

contract.only('Test solidity MocHelperLib', function([owner]) {
  it('Remains mocLibConfig after upgrade', async function() {
    const mocConnector = await MoCConnector.new();
    const moCHelperLib_v019 = await MoCHelperLib_v019.new();
    // Link MoCHelperLib
    console.log('Link MoCHelperLib_v019');
    MoCConverter_v019.link('MoCHelperLib_v019', moCHelperLib_v019.address);

    const oldConverter = await MoCConverter_v019.new();
    const proxyAdmin = await ProxyAdmin.new(owner);
    console.log('oldConverter', oldConverter.address);

    const encoded = oldConverter.contract.methods.initialize(mocConnector.address).encodeABI();
    const proxy = await AdminUpgradeabilityProxy.new(
      oldConverter.address,
      proxyAdmin.address,
      encoded
    );
    console.log('after proxy', proxy.address);
    const oldConverterContract = await MoCConverter_v019.at(proxy.address);
    console.log('btcToBProWithPrice');
    let result = await oldConverterContract.btcToBProWithPrice(
      '1000000000000000',
      '55748900000000000000000'
    );
    console.log('btcToBProWithPrice result', result.toString());
    try {
      result = await oldConverterContract.btcToMoCWithPrice(
        '1000000000000000',
        '55748900000000000000000',
        '1000000000000000000'
      );
      console.log('----- btcToMoCWithPrice did not fail --------');
      return;
    } catch (err) {
      console.log('btcToMoCWithPrice should fail');
    }
    console.log('should fail', result.toString());

    const moCHelperLib = await MoCHelperLib.new();
    // Link MoCHelperLib
    console.log('Link MoCHelperLib');
    MoCConverter.link('MoCHelperLib', moCHelperLib.address);
    const newConverter = await MoCConverter.new();
    await proxyAdmin.upgrade(proxy.address, newConverter.address);
    console.log('upgraded', newConverter.address);
    const newConverterContract = await MoCConverter.at(proxy.address);
    console.log('after upgrade');

    result = await newConverterContract.btcToBProWithPrice(
      '1000000000000000',
      '55748900000000000000000'
    );
    console.log('btcToBProWithPrice', result.toString());

    // await newConverterContract.initializePrecisions();
    // console.log('initializePrecisions');

    result = await newConverterContract.btcToMoCWithPrice(
      '1000000000000000',
      '55748900000000000000000',
      '1000000000000000000'
    );
    console.log('btcToMoCWithPrice', result.toString());
  });
});
