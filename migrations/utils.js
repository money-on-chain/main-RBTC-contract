/* eslint-disable no-console */
const jsonfile = require('jsonfile');
const { scripts, ConfigVariablesInitializer } = require('zos');

const { add, push, create, setAdmin } = scripts;
const forceDeploy = true;

const makeUtils = async (artifacts, networkName, config, owner, deployer) => {
  const MoC = artifacts.require('./MoC.sol');
  const BtcPriceProviderMock = artifacts.require('./mocks/BtcPriceProviderMock.sol');
  const MoCLib = artifacts.require('./MoCHelperLib.sol');
  const DocToken = artifacts.require('./token/DocToken.sol');
  const BProToken = artifacts.require('./token/BProToken.sol');
  const MoCToken = artifacts.require('./token/MoCToken.sol');
  const BProxManager = artifacts.require('./MoCBProxManager.sol');
  const MoCBurnout = artifacts.require('./MoCBurnout.sol');
  const MoCConverter = artifacts.require('./MoCConverter.sol');
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
  const MoCConnector = artifacts.require('./base/MoCConnector.sol');
  const MoCLibMock = artifacts.require('./mocks/MoCHelperLibMock.sol');
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
  let mocConverter;
  let mocExchange;
  let mocInrate;
  let moc;
  let mocConnector;
  let mocBurnout;
  let commissionSplitter;

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
        return config.oracle;
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

  const createInstances = async (MoCSettlementContract, MoCStateContract) => {
    const proxies = getProxies();
    doc = await DocToken.deployed();
    bpro = await BProToken.deployed();
    mocToken = await MoCToken.deployed();

    bprox = await BProxManager.at(getProxyAddress(proxies, 'MoCBProxManager'));
    mocSettlement = await MoCSettlementContract.at(getProxyAddress(proxies, 'MoCSettlement'));
    mocState = await MoCStateContract.at(getProxyAddress(proxies, 'MoCState'));
    mocConverter = await MoCConverter.at(getProxyAddress(proxies, 'MoCConverter'));
    mocExchange = await MoCExchange.at(getProxyAddress(proxies, 'MoCExchange'));
    moc = await MoC.at(getProxyAddress(proxies, 'MoC'));
    mocInrate = await MoCInrate.at(getProxyAddress(proxies, 'MoCInrate'));
    mocBurnout = await MoCBurnout.at(getProxyAddress(proxies, 'MoCBurnout'));
    mocConnector = await MoCConnector.at(getProxyAddress(proxies, 'MoCConnector'));
    commissionSplitter = await CommissionSplitter.at(
      getProxyAddress(proxies, 'CommissionSplitter')
    );
  };

  const linkMocLib = async MoCStateContract => {
    // Deploy and Link all contracts
    await deployer.link(MoCLib, MoC);
    await deployer.link(MoCLib, MoCConverter);
    await deployer.link(MoCLib, MoCStateContract);
    await deployer.link(MoCLib, MoCExchange);
    await deployer.link(MoCLib, MoCInrate);
  };

  const deployUpgradable = async (MoCSettlementContract, MoCStateContract, step) => {
    const contracts = [
      { name: 'MoC', alias: 'MoC' },
      { name: 'MoCConnector', alias: 'MoCConnector' },
      { name: 'MoCBProxManager', alias: 'MoCBProxManager' },
      { name: 'MoCBurnout', alias: 'MoCBurnout' },
      { name: MoCSettlementContract.contractName, alias: 'MoCSettlement' },
      { name: 'MoCConverter', alias: 'MoCConverter' },
      { name: MoCStateContract.contractName, alias: 'MoCState' },
      { name: 'MoCExchange', alias: 'MoCExchange' },
      { name: 'MoCInrate', alias: 'MoCInrate' },
      { name: 'CommissionSplitter', alias: 'CommissionSplitter' }
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
      mocBurnout = await create({ contractAlias: contract.alias, ...options });
    }
    if (index++ === step) {
      mocSettlement = await create({
        contractAlias: contract.alias,
        ...options
      });
    }
    if (index++ === step) {
      mocConverter = await create({
        contractAlias: contract.alias,
        ...options
      });
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
      mocOracle: mocPriceFeedAddress
    };
  };

  const initializeContracts = async () => {
    console.log('Initializing contracts');
    const oracleAddress = await bitcoinOracle();
    const governorAddress = await governorContractAddress();
    const stopperAddress = await stopperContractAddress();
    const mocOracleAddress = await mocOracle();

    console.log('Initializing MoC');
    await mocConnector.initialize(
      moc.address,
      doc.address,
      bpro.address,
      bprox.address,
      mocState.address,
      mocSettlement.address,
      mocConverter.address,
      mocExchange.address,
      mocInrate.address,
      mocBurnout.address,
      mocToken.address
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

    await mocConverter.initialize(mocConnector.address);
    console.log('Converter Initialized');

    var targetAddressBitPro = owner;
    if (config.targetAddressBitProInterest != '') {
      targetAddressBitPro = config.targetAddressBitProInterest;
    }

    var targetAddressCommission = owner;
    if (config.targetAddressCommissionPayment != '') {
      targetAddressCommission = config.targetAddressCommissionPayment;
    }

    await mocInrate.initialize(
      mocConnector.address,
      governorAddress,
      toContract(config.btcxTmin * 10 ** 18), // btcxTmin [using mocPrecision]
      toContract(config.btcxPower), // btcxPower [no precision]
      toContract(config.btcxTmax * 10 ** 18), // btcxTmax [using mocPrecision]
      toContract(config.bitProHolderRate * 10 ** 18), // BitPro Holder rate .25% (annual 0.0025 / 365 * 7) with [mocPrecision]
      config.dayBlockSpan * config.daysBitProHolderExecutePayment, // Blockspan to execute payment once a week
      targetAddressBitPro, // Target address of BitPro interest
      commissionSplitter.address, // Target address of commission payment
      //toContract(config.commissionRate * 10 ** 18), // commissionRate [mocPrecision]
      toContract(config.docTmin * 10 ** 18), // docTmin [using mocPrecision]
      toContract(config.docPower), // docPower [no precision]
      toContract(config.docTmax * 10 ** 18) // docTmax [using mocPrecision]
    );
    console.log('Inrate Initialized');

    // Initializing values
    await bprox.initialize(
      mocConnector.address,
      governorAddress,
      toContract(config.c0Cobj * 10 ** 18),
      toContract(config.x2Cobj * 10 ** 18)
    ); // mocPrecision
    console.log('BProxManager Initialized');

    await mocBurnout.initialize(mocConnector.address);
    console.log('Burnout Initialized');

    await mocSettlement.initialize(
      mocConnector.address,
      governorAddress,
      settlementBlockSpan(config)
    );
    console.log('Settlement Initialized');

    await mocState.initialize(
      mocConnector.address,
      governorAddress,
      oracleAddress,
      toContract(config.liq * 10 ** 18), // _liq
      toContract(config.utpdu * 10 ** 18), // _utpdu
      toContract(config.maxDiscRate * 10 ** 18), // _maxDiscRate
      config.dayBlockSpan, // _dayBlockSpan
      toContract(config.initialEma * 10 ** 18), // _ema
      toContract(config.smoothFactor * 10 ** 18), // _smoothFactor
      config.dayBlockSpan, // _emaBlockSpan
      toContract(config.maxMintBPro * 10 ** 18),
      mocOracleAddress
    );
    console.log('State Initialized');

    await commissionSplitter.initialize(
      moc.address,
      targetAddressCommission,
      toContract(config.mocProportion),
      governorAddress
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
      contractAlias: 'MoCBurnout',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCSettlement',
      newAdmin: adminAddress,
      ...options
    });
    await setAdmin({
      contractAlias: 'MoCConverter',
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
    deployMoCOracleMock
  };
};

const isDevelopment = currentNetwork =>
  currentNetwork === 'development' || currentNetwork === 'coverage' || currentNetwork === 'regtest';

module.exports = { makeUtils, isDevelopment };
