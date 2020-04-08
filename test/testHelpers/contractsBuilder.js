const { TestHelper } = require('zos');
const { Contracts, ZWeb3 } = require('zos-lib');

ZWeb3.initialize(web3.currentProvider);

const BtcPriceProviderMock = artifacts.require('./contracts/mocks/BtcPriceProviderMock.sol');
const DoC = artifacts.require('./contracts/DocToken.sol');
const MoC = artifacts.require('./contracts/MoC.sol');
const MoCState = artifacts.require('./contracts/MoCState.sol');
const MoCStateMock = artifacts.require('./contracts/mocks/MoCStateMock.sol');
const MoCConverter = artifacts.require('./contracts/MoCConverter.sol');
const MoCExchange = artifacts.require('./contracts/MoCExchange.sol');
const MoCInrate = artifacts.require('./contracts/MoCInrate.sol');
const MoCSettlementMock = artifacts.require('./contracts/mocks/MoCSettlementMock.sol');
const BPro = artifacts.require('./contracts/BProToken.sol');
const BProxManager = artifacts.require('./contracts/MoCBProxManager.sol');
const MoCSettlement = artifacts.require('./contracts/MoCSettlement.sol');
const MoCBurnout = artifacts.require('./contracts/MoCBurnout.sol');
const MoCConnector = artifacts.require('./contracts/base/MoCConnector.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');
const ProxyAdmin = artifacts.require('ProxyAdmin');
const UpgradeDelegator = artifacts.require('UpgradeDelegator');
const Stopper = artifacts.require('moc-governance/contracts/Stopper/Stopper.sol');
const MocStateChanger = artifacts.require('./contracts/MocStateChanger.sol');
const MocInrateChanger = artifacts.require('./contracts/MocInrateChanger.sol');
const MoCSettlementChanger = artifacts.require('./contracts/MoCSettlementChanger.sol');
const MoCBucketContainerChanger = artifacts.require('./contracts/MoCBucketContainerChanger.sol');
const MoCRestartSettlementChanger = artifacts.require(
  './contracts/MoCRestartSettlementChanger.sol'
);
const MoCStallSettlementChanger = artifacts.require('./contracts/MoCStallSettlementChanger.sol');
const MocChanger = artifacts.require('./contracts/MocChanger.sol');
const CommissionSplitter = artifacts.require('CommissionSplitter.sol');

const MoCProxy = Contracts.getFromLocal('MoC');
const MoCStateProxy = Contracts.getFromLocal('MoCState');
const MoCStateMockProxy = Contracts.getFromLocal('MoCStateMock');
const MoCConverterProxy = Contracts.getFromLocal('MoCConverter');
const MoCExchangeProxy = Contracts.getFromLocal('MoCExchange');
const MoCInrateProxy = Contracts.getFromLocal('MoCInrate');
const MoCSettlementMockProxy = Contracts.getFromLocal('MoCSettlementMock');
const BProxManagerProxy = Contracts.getFromLocal('MoCBProxManager');
const MoCSettlementProxy = Contracts.getFromLocal('MoCSettlement');
const MoCBurnoutProxy = Contracts.getFromLocal('MoCBurnout');
const MoCConnectorProxy = Contracts.getFromLocal('MoCConnector');
const GovernorProxy = Contracts.getFromLocal('Governor');
const StopperProxy = Contracts.getFromLocal('Stopper');
const CommissionSplitterProxy = Contracts.getFromLocal('CommissionSplitter');
const RevertingOnSend = artifacts.require('./contracts/test-contracts/RevertingOnSend.sol');

const { toContract } = require('../../utils/numberHelper');

const baseParams = {
  btcPrice: toContract(10000 * 10 ** 18), // mocPrecision
  smoothingFactor: toContract(0.01653 * 10 ** 18), // coefficientPrecision
  c0Cobj: toContract(3 * 10 ** 18), // mocPrecision
  x2Cobj: toContract(2 * 10 ** 18), // mocPrecision
  liq: toContract(1.04 * 10 ** 18), // mocPrecision
  utpdu: toContract(2 * 10 ** 18), // mocPrecision
  maxDiscountRate: toContract(50), // mocPrecision

  settlementBlockSpan: toContract(100),
  dayBlockSpan: toContract(4 * 60 * 24),
  btcxTmin: toContract(0), // mocPrecision
  btcxTmax: toContract(0.0002611578760678 * 10 ** 18), // mocPrecision
  btcxPower: toContract(1),
  bitProRate: toContract(0.000047945 * 10 ** 18), // mocPrecision -- weekly 0.0025 / 365 * 7
  emaBlockSpan: toContract(40),
  commissionRate: toContract(0 * 10 ** 18), // mocPrecision
  peg: toContract(1),

  maxMintBPro: toContract(5000 * 10 ** 18),
  docTmin: toContract(0), // mocPrecision
  docTmax: toContract(0.0002611578760678 * 10 ** 18), // mocPrecision
  docPower: toContract(1),
  mocProportion: toContract(0.01 * 10 ** 18), // mocPrecision

  startStoppable: true
};

const createContracts = params => async ({ owner, useMock }) => {
  const project = await TestHelper();

  const {
    btcPrice,
    smoothingFactor,
    c0Cobj,
    x2Cobj,
    liq,
    utpdu,
    maxDiscountRate,
    settlementBlockSpan,
    dayBlockSpan,
    btcxTmin,
    btcxPower,
    btcxTmax,
    emaBlockSpan,
    bitProRate,
    commissionRate,
    peg,
    maxMintBPro,
    docTmin,
    docTmax,
    docPower,
    startStoppable,
    mocProportion = baseParams.mocProportion
  } = params;
  const settlementContract = useMock ? MoCSettlementMock : MoCSettlement;
  const stateContract = useMock ? MoCStateMock : MoCState;
  const settlementContractProxy = useMock ? MoCSettlementMockProxy : MoCSettlementProxy;
  const stateContractProxy = useMock ? MoCStateMockProxy : MoCStateProxy;

  // Non-upgradeable
  const bpro = await BPro.new({ from: owner });
  const doc = await DoC.new({ from: owner });
  const btcPriceProvider = await BtcPriceProviderMock.new(btcPrice);

  // Upgradeable
  const mocSettlementProxy = await project.createProxy(settlementContractProxy);
  const mocStateProxy = await project.createProxy(stateContractProxy);
  const mocConnectorProxy = await project.createProxy(MoCConnectorProxy);
  const bproxProxy = await project.createProxy(BProxManagerProxy);
  const mocConverterProxy = await project.createProxy(MoCConverterProxy);
  const mocExchangeProxy = await project.createProxy(MoCExchangeProxy);
  const mocInrateProxy = await project.createProxy(MoCInrateProxy);
  const mocBurnoutProxy = await project.createProxy(MoCBurnoutProxy);
  const mocProxy = await project.createProxy(MoCProxy);
  const commissionSplitterProxy = await project.createProxy(CommissionSplitterProxy);

  // Governance
  const governorProxy = await project.createProxy(GovernorProxy);
  const stopperProxy = await project.createProxy(StopperProxy);
  const proxyAdmin = await ProxyAdmin.new();
  const upgradeDelegator = await UpgradeDelegator.new();
  const mocSettlement = await settlementContract.at(mocSettlementProxy.address);
  const mocState = await stateContract.at(mocStateProxy.address);
  const mocConnector = await MoCConnector.at(mocConnectorProxy.address);
  const bprox = await BProxManager.at(bproxProxy.address);
  const mocConverter = await MoCConverter.at(mocConverterProxy.address);
  const mocExchange = await MoCExchange.at(mocExchangeProxy.address);
  const mocInrate = await MoCInrate.at(mocInrateProxy.address);
  const mocBurnout = await MoCBurnout.at(mocBurnoutProxy.address);
  const moc = await MoC.at(mocProxy.address);
  const commissionSplitter = await CommissionSplitter.at(commissionSplitterProxy.address);

  const governor = await Governor.at(governorProxy.address);
  const stopper = await Stopper.at(stopperProxy.address);

  const mockMocStateChanger = await MocStateChanger.new(
    mocState.address,
    btcPriceProvider.address,
    peg,
    utpdu,
    maxDiscountRate,
    dayBlockSpan,
    liq,
    smoothingFactor,
    emaBlockSpan,
    maxMintBPro,
    { from: owner }
  );
  const mockMocInrateChanger = await MocInrateChanger.new(
    mocInrate.address,
    7 * dayBlockSpan,
    btcxTmin,
    btcxTmax,
    btcxPower,
    bitProRate,
    commissionRate,
    docTmin,
    docTmax,
    docPower,
    { from: owner }
  );

  const mockMoCSettlementChanger = await MoCSettlementChanger.new(
    mocSettlement.address,
    dayBlockSpan,
    {
      from: owner
    }
  );
  const mockMoCStallSettlementChanger = await MoCStallSettlementChanger.new(mocSettlement.address);
  const mockMoCRestartSettlementChanger = await MoCRestartSettlementChanger.new(
    mocSettlement.address
  );
  const mockMoCBucketContainerChanger = await MoCBucketContainerChanger.new(
    bprox.address,
    c0Cobj,
    x2Cobj,
    {
      from: owner
    }
  );
  const mockMocChanger = await MocChanger.new(moc.address, governor.address, stopper.address, {
    from: owner
  });

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
    mocBurnout.address
  );

  // Initialize contracts
  await mocConverter.initialize(mocConnector.address);
  await moc.initialize(mocConnector.address, governor.address, stopper.address, startStoppable);
  await stopper.initialize(owner);
  await mocExchange.initialize(mocConnector.address);
  await mocState.initialize(
    mocConnector.address,
    governor.address,
    btcPriceProvider.address,
    liq, // mocPrecision
    utpdu, // mocPrecision
    maxDiscountRate, // mocPrecision
    dayBlockSpan, // no Precision
    btcPrice,
    smoothingFactor,
    emaBlockSpan,
    maxMintBPro
  );

  await mocInrate.initialize(
    mocConnector.address,
    governor.address,
    btcxTmin,
    btcxPower,
    btcxTmax,
    bitProRate,
    dayBlockSpan * 7,
    owner,
    owner,
    commissionRate,
    docTmin,
    docPower,
    docTmax
  );
  await bprox.initialize(mocConnector.address, governor.address, c0Cobj, x2Cobj);
  await mocSettlement.initialize(mocConnector.address, governor.address, settlementBlockSpan);
  await mocBurnout.initialize(mocConnector.address);
  await governor.initialize(owner);
  await commissionSplitter.initialize(moc.address, owner, mocProportion, governor.address);

  await upgradeDelegator.initialize(governor.address, proxyAdmin.address);
  // Transfer roles
  await transferOwnershipAndMinting(doc, mocExchange.address);
  await transferOwnershipAndMinting(bpro, mocExchange.address);
  await transferPausingRole(bpro, moc.address);
  await proxyAdmin.transferOwnership(upgradeDelegator.address);

  // Transfer upgrade adminship
  await project.changeProxyAdmin(mocSettlementProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocStateProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocConnectorProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(bproxProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocConverterProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocExchangeProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocInrateProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocBurnoutProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(governorProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(stopperProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(commissionSplitter.address, proxyAdmin.address);

  // Contract that reverts when receiving RBTC on fallback function
  const revertingContract = await RevertingOnSend.new(moc.address, {
    from: owner
  });

  // Fix the mocBProxManager

  /*
  const bProxManagerNewImplementation = await BProxManagerFixer.new();

  const bProxManagerUpgrader = await BProxManagerUpgrader.new(
    bprox.address,
    upgradeDelegator.address,
    bProxManagerNewImplementation.address
  );
  await governor.executeChange(bProxManagerUpgrader.address, { gas: 6e6 });
  const bproxFixed = await BProxManagerFixer.at(bprox.address);
  await bproxFixed.fixGovernor();
  */
  return {
    commissionSplitter,
    mocConnector,
    moc,
    mocState,
    mocInrate,
    bprox,
    bpro,
    doc,
    mocBurnout,
    mocSettlement,
    btcPriceProvider,
    mockMocStateChanger,
    governor,
    stopper,
    mockMocInrateChanger,
    mockMoCSettlementChanger,
    mockMoCBucketContainerChanger,
    mockMocChanger,
    mockMoCStallSettlementChanger,
    mockMoCRestartSettlementChanger,
    revertingContract
  };
};

const transferOwnershipAndMinting = async (token, address) => {
  await token.transferOwnership(address);
  await token.addMinter(address);
  await token.renounceMinter();
};

const transferPausingRole = async (token, address) => {
  await token.addPauser(address);
  await token.renouncePauser();
};

module.exports = {
  createBaseContracts: createContracts(baseParams),
  createContracts
};
