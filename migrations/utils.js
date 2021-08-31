/* eslint-disable no-console */
const jsonfile = require('jsonfile');
const { scripts, ConfigVariablesInitializer } = require('zos');

const { add, push, create, setAdmin } = scripts;
const forceDeploy = true;

const fs = require('fs');

const makeUtils = async (artifacts, networkName, config, owner, deployer) => {
  const MoC = artifacts.require('./MoC.sol');
  const BtcPriceProviderMock = artifacts.require('./mocks/BtcPriceProviderMock.sol');
  const MoCLib = artifacts.require('./MoCHelperLib.sol');
  const DocToken = artifacts.require('./token/DocToken.sol');
  const BProToken = artifacts.require('./token/BProToken.sol');
  const MoCToken = artifacts.require('./token/MoCToken.sol');
  const BProxManager = artifacts.require('./MoCBProxManager.sol');
  const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
  const Stopper = artifacts.require('moc-governance/contracts/Stopper/Stopper.sol');
  const UpgradeDelegator = artifacts.require(
    'moc-governance/contracts/Upgradeability/UpgradeDelegator.sol'
  );
  const CommissionSplitter = artifacts.require('CommissionSplitter');
  const MoCPriceProviderMock = artifacts.require('./mocks/MoCPriceProviderMock.sol');

  const ProxyAdmin = artifacts.require('ProxyAdmin');
  const MoCInrate = artifacts.require('./MoCInrate.sol');
  const MoCExchange = artifacts.require('./MoCExchange.sol');
  const MoCVendors = artifacts.require('./MoCVendors.sol');
  const MoCConnector = artifacts.require('./base/MoCConnector.sol');
  const MoCLibMock = artifacts.require('./mocks/MoCHelperLibMock.sol');

  const MoCHelperLibHarness = artifacts.require(
    './contracts/test-contracts/MoCHelperLibHarness.sol'
  );

  const { toContract } = require('../utils/numberHelper');

  const { network, txParams } = await ConfigVariablesInitializer.initNetworkConfiguration({
    network: networkName,
    from: owner
  });
  const options = { network, txParams };
  let doc;
  let bpro;
  let mocToken;
  let bprox;
  let mocSettlement;
  let mocState;
  let mocExchange;
  let mocInrate;
  let moc;
  let mocConnector;
  let commissionSplitter;
  let mocVendors;

  const bitcoinOracle = async () => {
    switch (networkName) {
      case 'regtest':
      case 'coverage':
      case 'development':
        return (await BtcPriceProviderMock.deployed()).address;
      default:
        return config.oracle;
    }
  };

  const mocOracle = async () => {
    switch (networkName) {
      case 'regtest':
      case 'coverage':
      case 'development':
        return (await MoCPriceProviderMock.deployed()).address;
      default:
        return config.mocOracle;
    }
  };

  const governorContractAddress = async () => {
    switch (networkName) {
      case 'regtest':
      case 'coverage':
      case 'development':
        return (await Governor.deployed()).address;
      default:
        return config.governor;
    }
  };

  const stopperContractAddress = async () => {
    switch (networkName) {
      case 'regtest':
      case 'coverage':
      case 'development':
        return (await Stopper.deployed()).address;
      default:
        return config.stopper;
    }
  };

  const proxyAdminContractAddress = async () => {
    switch (networkName) {
      case 'regtest':
      case 'coverage':
      case 'development':
        return (await ProxyAdmin.deployed()).address;
      default:
        return config.proxyAdmin;
    }
  };

  const deployMocLibMock = async () => {
    await deployer.link(MoCLib, MoCLibMock);
    await deployer.deploy(MoCLibMock);
  };

  const deployMoCHelperLibHarness = async () => {
    await deployer.link(MoCLib, MoCHelperLibHarness);
    await deployer.deploy(MoCHelperLibHarness);
    const mocHelperLibHarness = await MoCHelperLibHarness.deployed();
    await mocHelperLibHarness.initialize();
    console.log('MoCHelperLibHarness initialized');
  };

  const deployOracleMock = async () => {
    await deployer.deploy(BtcPriceProviderMock, toContract(config.initialPrice * 10 ** 18));
  };

  const deployMoCOracleMock = async () => {
    await deployer.deploy(MoCPriceProviderMock, toContract(config.initialPrice * 10 ** 18));
  };

  const deployGovernorContract = async () => {
    await deployer.deploy(Governor);
    const governor = await Governor.deployed();
    governor.initialize(owner);
  };

  const deployStopperContract = async () => {
    await deployer.deploy(Stopper, owner);
  };

  const deployUpgradeDelegatorContract = async () => {
    const governorAddress = await governorContractAddress();
    console.log(governorAddress);
    const proxyAdminAddress = await proxyAdminContractAddress();
    await deployer.deploy(UpgradeDelegator);
    const delegator = await UpgradeDelegator.deployed();
    await delegator.initialize(governorAddress, proxyAdminAddress);
    const proxyAdmin = await ProxyAdmin.at(proxyAdminAddress);
    await proxyAdmin.transferOwnership(delegator.address);
  };

  const deployProxyAdminContract = async () => {
    await deployer.deploy(ProxyAdmin);
  };

  const transferOwnershipAndMinting = async (token, address) => {
    const symbol = await token.symbol();

    console.log(`Changing ${symbol} ownership`);
    await token.transferOwnership(address);
    console.log(`${symbol} Ownership completely changed`);

    console.log(`Changing ${symbol} minter`);
    await token.addMinter(address);
    await token.renounceMinter();
    console.log(`${symbol} minter successfully changed`);
  };

  const transferPausingRole = async (token, address) => {
    const symbol = await token.symbol();

    console.log(`Changing ${symbol} pauser`);
    await token.addPauser(address);
    await token.renouncePauser();
    console.log(`${symbol} pauser successfully changed`);
  };

  const getProxies = () => {
    const { proxies } = jsonfile.readFileSync(`./zos.${network}.json`);
    return proxies;
  };

  const getProxyAddress = (proxies, contractName) => {
    const projectPrefix = 'money-on-chain';
    const proxiesOfInterest = proxies[`${projectPrefix}/${contractName}`];
    return proxiesOfInterest[proxiesOfInterest.length - 1].address;
  };

  const getImplementationAddress = (proxies, contractName) => {
    const projectPrefix = 'money-on-chain';
    const proxiesOfInterest = proxies[`${projectPrefix}/${contractName}`];
    return proxiesOfInterest[proxiesOfInterest.length - 1].implementation;
  };

  const createInstances = async (MoCSettlementContract, MoCStateContract) => {
    const proxies = getProxies();
    doc = await DocToken.deployed();
    bpro = await BProToken.deployed();
    mocToken = await MoCToken.deployed();

    bprox = await BProxManager.at(getProxyAddress(proxies, 'MoCBProxManager'));
    mocSettlement = await MoCSettlementContract.at(getProxyAddress(proxies, 'MoCSettlement'));
    mocState = await MoCStateContract.at(getProxyAddress(proxies, 'MoCState'));
    mocExchange = await MoCExchange.at(getProxyAddress(proxies, 'MoCExchange'));
    moc = await MoC.at(getProxyAddress(proxies, 'MoC'));
    mocInrate = await MoCInrate.at(getProxyAddress(proxies, 'MoCInrate'));
    mocConnector = await MoCConnector.at(getProxyAddress(proxies, 'MoCConnector'));
    commissionSplitter = await CommissionSplitter.at(
      getProxyAddress(proxies, 'CommissionSplitter')
    );
    mocVendors = await MoCVendors.at(getProxyAddress(proxies, 'MoCVendors'));
  };

  const linkMocLib = async MoCStateContract => {
    // Deploy and Link all contracts
    await deployer.link(MoCLib, MoC);
    await deployer.link(MoCLib, MoCStateContract);
    await deployer.link(MoCLib, MoCExchange);
    await deployer.link(MoCLib, MoCInrate);
    await deployer.link(MoCLib, MoCVendors);
  };

  const deployUpgradable = async (MoCSettlementContract, MoCStateContract, step) => {
    const contracts = [
      { name: 'MoC', alias: 'MoC' },
      { name: 'MoCConnector', alias: 'MoCConnector' },
      { name: 'MoCBProxManager', alias: 'MoCBProxManager' },
      { name: MoCSettlementContract.contractName, alias: 'MoCSettlement' },
      { name: 'MoCConverter', alias: 'MoCConverter' }, // Remove this after fixing the indexes
      { name: MoCStateContract.contractName, alias: 'MoCState' },
      { name: 'MoCExchange', alias: 'MoCExchange' },
      { name: 'MoCInrate', alias: 'MoCInrate' },
      { name: 'CommissionSplitter', alias: 'CommissionSplitter' },
      { name: 'MoCVendors', alias: 'MoCVendors' }
    ];
    const contract = contracts[step - 1];
    console.log(`deploying Upgradable ${step - 1}: ${contract.name}`);
    add({
      contractsData: [contract]
    });
    await push({ force: forceDeploy, ...options });
    console.log(`pushed ${step - 1}: ${contract.name}`);
    let index = 1;
    if (index++ === step) {
      moc = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      mocConnector = await create({
        contractAlias: contract.alias,
        ...options
      });
    }
    if (index++ === step) {
      bprox = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      mocSettlement = await create({
        contractAlias: contract.alias,
        ...options
      });
    }
    if (index++ === step) {
      // index=5
      // mocConverter = await create({
      //   contractAlias: contract.alias,
      //   ...options
      // });
    }
    if (index++ === step) {
      mocState = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      mocExchange = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      mocInrate = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      commissionSplitter = await create({
        contractAlias: contract.alias,
        ...options
      });
    }
    if (index++ === step) {
      mocVendors = await create({ contractAlias: contract.alias, ...options });
    }
  };

  const getContractAddresses = async () => {
    const proxies = getProxies();
    console.log(await proxyAdminContractAddress());
    const proxyAdmin = await ProxyAdmin.at(await proxyAdminContractAddress());
    const bitcoinPriceFeedAddress = await bitcoinOracle();
    const mocPriceFeedAddress = await mocOracle();
    return {
      moc: getProxyAddress(proxies, 'MoC'),
      oracle: bitcoinPriceFeedAddress,
      mocBProxManager: getProxyAddress(proxies, 'MoCBProxManager'),
      mocState: getProxyAddress(proxies, 'MoCState'),
      mocInrate: getProxyAddress(proxies, 'MoCInrate'),
      commissionSplitter: getProxyAddress(proxies, 'CommissionSplitter'),
      governor: await governorContractAddress(),
      stopper: await stopperContractAddress(),
      proxyAdmin: proxyAdmin.address,
      upgradeDelegator: await proxyAdmin.owner(),
      mocOracle: mocPriceFeedAddress,
      mocVendors: getProxyAddress(proxies, 'MoCVendors'),
      mocExchange: getProxyAddress(proxies, 'MoCExchange'),
      mocSettlement: getProxyAddress(proxies, 'MoCSettlement'),
      mocConnector: getProxyAddress(proxies, 'MoCConnector')
    };
  };

  const getImplementationAddresses = async () => {
    const proxies = getProxies();
    const proxyAdmin = await ProxyAdmin.at(await proxyAdminContractAddress());
    const bitcoinPriceFeedAddress = await bitcoinOracle();
    const mocPriceFeedAddress = await mocOracle();
    return {
      moc: getImplementationAddress(proxies, 'MoC'),
      oracle: bitcoinPriceFeedAddress,
      mocBProxManager: getImplementationAddress(proxies, 'MoCBProxManager'),
      mocState: getImplementationAddress(proxies, 'MoCState'),
      mocInrate: getImplementationAddress(proxies, 'MoCInrate'),
      commissionSplitter: getImplementationAddress(proxies, 'CommissionSplitter'),
      governor: await governorContractAddress(),
      stopper: await stopperContractAddress(),
      proxyAdmin: proxyAdmin.address,
      upgradeDelegator: await proxyAdmin.owner(),
      mocOracle: mocPriceFeedAddress,
      mocVendors: getImplementationAddress(proxies, 'MoCVendors'),
      mocExchange: getImplementationAddress(proxies, 'MoCExchange'),
      mocSettlement: getImplementationAddress(proxies, 'MoCSettlement'),
      mocConnector: getImplementationAddress(proxies, 'MoCConnector'),
      mocToken: (await MoCToken.deployed()).address,
      mocHelperLib: (await MoCLib.deployed()).address
    };
  };

  const initializeContracts = async () => {
    console.log('Initializing contracts');
    const oracleAddress = await bitcoinOracle();
    const governorAddress = await governorContractAddress();
    const stopperAddress = await stopperContractAddress();
    const mocOracleAddress = await mocOracle();

    let targetAddressBitPro = owner;
    if (config.targetAddressBitProInterest !== '') {
      targetAddressBitPro = config.targetAddressBitProInterest;
    }

    let targetAddressCommission = owner;
    if (config.targetAddressCommissionPayment !== '') {
      targetAddressCommission = config.targetAddressCommissionPayment;
    }

    let mocTokenCommissionsAddress = owner;
    if (config.mocTokenCommissionsAddress !== '') {
      ({ mocTokenCommissionsAddress } = config.mocTokenCommissionsAddress);
    }

    const mocInrateInitializeParams = {
      connectorAddress: mocConnector.address,
      governor: governorAddress,
      btcxTmin: toContract(config.btcxTmin * 10 ** 18), // btcxTmin [using mocPrecision]
      btcxPower: toContract(config.btcxPower), // btcxPower [no precision]
      btcxTmax: toContract(config.btcxTmax * 10 ** 18), // btcxTmax [using mocPrecision]
      bitProRate: toContract(config.bitProHolderRate * 10 ** 18), // BitPro Holder rate .25% (annual 0.0025 / 365 * 7) with [mocPrecision]
      blockSpanBitPro: config.dayBlockSpan * config.daysBitProHolderExecutePayment, // Blockspan to execute payment once a week
      bitProInterestTargetAddress: targetAddressBitPro, // Target address of BitPro interest
      commissionsAddressTarget: commissionSplitter.address, // Target address of commission payment
      // toContract(config.commissionRate * 10 ** 18), // commissionRate [mocPrecision]
      docTmin: toContract(config.docTmin * 10 ** 18), // docTmin [using mocPrecision]
      docPower: toContract(config.docPower), // docPower [no precision]
      docTmax: toContract(config.docTmax * 10 ** 18) // docTmax [using mocPrecision]
    };
    const mocStateInitializeParams = {
      connectorAddress: mocConnector.address,
      governor: governorAddress,
      btcPriceProvider: oracleAddress,
      liq: toContract(config.liq * 10 ** 18),
      utpdu: toContract(config.utpdu * 10 ** 18),
      maxDiscRate: toContract(config.maxDiscRate * 10 ** 18),
      dayBlockSpan: config.dayBlockSpan,
      ema: toContract(config.initialEma * 10 ** 18),
      smoothFactor: toContract(config.smoothFactor * 10 ** 18),
      emaBlockSpan: config.dayBlockSpan,
      maxMintBPro: toContract(config.maxMintBPro * 10 ** 18),
      mocPriceProvider: mocOracleAddress,
      mocTokenAddress: mocToken.address,
      mocVendorsAddress: mocVendors.address,
      liquidationEnabled: config.liquidationEnabled,
      protected: toContract(config.protected * 10 ** 18)
    };

    console.log('Initializing MoC');
    await mocConnector.initialize(
      moc.address,
      doc.address,
      bpro.address,
      bprox.address,
      mocState.address,
      mocSettlement.address,
      mocExchange.address,
      mocInrate.address,
      mocVendors.address // pass other address as parameter because MoCBurnout is deprecated
    );
    console.log('MoCConnector Initialized');

    await moc.initialize(
      mocConnector.address,
      governorAddress,
      stopperAddress,
      config.startStoppable
    );
    console.log('MoC Initialized');

    await mocExchange.initialize(mocConnector.address);
    console.log('Exchange Initialized');

    // Making sure to call the correct initialize function
    await mocInrate.methods[
      'initialize((address,address,uint256,uint256,uint256,uint256,uint256,address,address,uint256,uint256,uint256))'
    ](mocInrateInitializeParams);
    console.log('Inrate Initialized');

    // Initializing values
    await bprox.initialize(
      mocConnector.address,
      governorAddress,
      toContract(config.c0Cobj * 10 ** 18),
      toContract(config.x2Cobj * 10 ** 18)
    ); // mocPrecision
    console.log('BProxManager Initialized');

    await mocSettlement.initialize(
      mocConnector.address,
      governorAddress,
      settlementBlockSpan(config)
    );
    console.log('Settlement Initialized');

    let vendorGuardianAddress = owner;
    if (config.vendorGuardianAddress !== '') {
      ({ vendorGuardianAddress } = config.vendorGuardianAddress);
    }

    await mocVendors.initialize(mocConnector.address, governorAddress, vendorGuardianAddress);
    console.log('Vendors Initialized');

    // Making sure to call the correct initialize function
    await mocState.methods[
      'initialize((address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address,address,bool,uint256))'
    ](mocStateInitializeParams);
    console.log('State Initialized');

    await commissionSplitter.initialize(
      moc.address,
      targetAddressCommission,
      toContract(config.mocProportion),
      governorAddress,
      mocToken.address,
      mocTokenCommissionsAddress
    );
    console.log('CommissionSplitter Initialized');
  };

  const setGovernance = async () => {
    const adminAddress = await proxyAdminContractAddress();
    await setAdmin({
      contractAlias: 'MoC',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCConnector',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCBProxManager',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCSettlement',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCState',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCExchange',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCInrate',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'CommissionSplitter',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCVendors',
      newAdmin: adminAddress,
      ...options
    });
  };

  const transferDocRoles = async () => {
    await transferOwnershipAndMinting(doc, mocExchange.address);
  };

  const transferBproRoles = async () => {
    await transferOwnershipAndMinting(bpro, mocExchange.address);
  };

  const transferBproPausingRole = async () => {
    await transferPausingRole(bpro, moc.address);
  };

  const settlementBlockSpan = () => toContract(config.dayBlockSpan * config.settlementDays);

  const saveConfig = async (path, networkConfig) => {
    const contractAddresses = await getContractAddresses();
    const implementationAddr = await getImplementationAddresses();

    const proxyAddresses = {
      MoC: contractAddresses.moc,
      MoCConnector: contractAddresses.mocConnector,
      MoCExchange: contractAddresses.mocExchange,
      MoCSettlement: contractAddresses.mocSettlement,
      MoCInrate: contractAddresses.mocInrate,
      MoCState: contractAddresses.mocState,
      MoCVendors: contractAddresses.mocVendors,
      CommissionSplitter: contractAddresses.commissionSplitter
    };

    const implementationAddresses = {
      MoC: implementationAddr.moc,
      MoCConnector: implementationAddr.mocConnector,
      MoCExchange: implementationAddr.mocExchange,
      MoCSettlement: implementationAddr.mocSettlement,
      MoCInrate: implementationAddr.mocInrate,
      MoCState: implementationAddr.mocState,
      ProxyAdmin: implementationAddr.proxyAdmin,
      UpgradeDelegator: implementationAddr.upgradeDelegator,
      Governor: implementationAddr.governor,
      MoCToken: implementationAddr.mocToken,
      MoCPriceProvider: implementationAddr.mocOracle,
      MoCVendors: implementationAddr.mocVendors,
      MoCHelperLib: implementationAddr.mocHelperLib,
      CommissionSplitter: implementationAddr.commissionSplitter
    };

    let vendorGuardianAddress = owner;
    if (networkConfig.vendorGuardianAddress !== '') {
      ({ vendorGuardianAddress } = networkConfig.vendorGuardianAddress);
    }

    let mocTokenCommissionsAddress = owner;
    if (config.mocTokenCommissionsAddress !== '') {
      ({ mocTokenCommissionsAddress } = config.mocTokenCommissionsAddress);
    }

    const valuesToAssign = {
      commissionRates: networkConfig.commissionRates,
      liquidationEnabled: networkConfig.liquidationEnabled,
      protected: networkConfig.protected,
      vendorGuardianAddress,
      mocTokenCommissionsAddress
    };

    const changerAddresses = {};

    let governorOwnerAddress = owner;
    if (networkConfig.governorOwnerAddress !== '') {
      ({ governorOwnerAddress } = networkConfig.governorOwnerAddress);
    }

    const configValues = {
      proxyAddresses,
      implementationAddresses,
      valuesToAssign,
      changerAddresses,
      governorOwnerAddress
    };

    fs.writeFileSync(path, JSON.stringify(configValues, null, 2));
  };

  return {
    initializeContracts,
    linkMocLib,
    deployUpgradable,
    transferDocRoles,
    transferBproRoles,
    transferBproPausingRole,
    deployMocLibMock,
    deployOracleMock,
    deployGovernorContract,
    deployUpgradeDelegatorContract,
    deployProxyAdminContract,
    deployStopperContract,
    setGovernance,
    createInstances,
    getContractAddresses,
    deployMoCOracleMock,
    deployMoCHelperLibHarness,
    saveConfig
  };
};

const isDevelopment = currentNetwork =>
  currentNetwork === 'development' || currentNetwork === 'coverage' || currentNetwork === 'regtest';

module.exports = { makeUtils, isDevelopment };
