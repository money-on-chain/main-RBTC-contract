const { TestHelper } = require('zos');
const { Contracts, ZWeb3 } = require('zos-lib');

ZWeb3.initialize(web3.currentProvider);

const BtcPriceProviderMock = artifacts.require('./contracts/mocks/BtcPriceProviderMock.sol');
const DoC = artifacts.require('./contracts/DocToken.sol');
const MoC = artifacts.require('./contracts/MoC.sol');
const MoCState = artifacts.require('./contracts/MoCState.sol');
const MoCStateMock = artifacts.require('./contracts/mocks/MoCStateMock.sol');
const MoCExchange = artifacts.require('./contracts/MoCExchange.sol');
const MoCInrate = artifacts.require('./contracts/MoCInrate.sol');
const MoCSettlementMock = artifacts.require('./contracts/mocks/MoCSettlementMock.sol');
const MoCPriceProviderMock = artifacts.require('./contracts/mocks/MoCPriceProviderMock.sol');

const BPro = artifacts.require('./contracts/BProToken.sol');
const BProxManager = artifacts.require('./contracts/MoCBProxManager.sol');
const MoCSettlement = artifacts.require('./contracts/MoCSettlement.sol');

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
const MoCExchangeProxy = Contracts.getFromLocal('MoCExchange');
const MoCInrateProxy = Contracts.getFromLocal('MoCInrate');
const MoCSettlementMockProxy = Contracts.getFromLocal('MoCSettlementMock');
const BProxManagerProxy = Contracts.getFromLocal('MoCBProxManager');
const MoCSettlementProxy = Contracts.getFromLocal('MoCSettlement');
const MoCConnectorProxy = Contracts.getFromLocal('MoCConnector');
const GovernorProxy = Contracts.getFromLocal('Governor');
const StopperProxy = Contracts.getFromLocal('Stopper');
const CommissionSplitterProxy = Contracts.getFromLocal('CommissionSplitter');
const RevertingOnSend = artifacts.require('./contracts/test-contracts/RevertingOnSend.sol');

const MoCToken = artifacts.require('./contracts/MoCToken.sol');

const MoCVendors = artifacts.require('./contracts/MoCVendors.sol');
const MoCVendorsProxy = Contracts.getFromLocal('MoCVendors');
const MoCVendorsChanger = artifacts.require('./contracts/MoCVendorsChanger.sol');

const { toContract } = require('../../utils/numberHelper');

const baseParams = {
  btcPrice: toContract(10000 * 10 ** 18), // mocPrecision
  mocPrice: toContract(10000 * 10 ** 18), // mocPrecision
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
  // commissionRate: toContract(0 * 10 ** 18), // mocPrecision
  peg: toContract(1),

  maxMintBPro: toContract(5000 * 10 ** 18),
  docTmin: toContract(0), // mocPrecision
  docTmax: toContract(0.0002611578760678 * 10 ** 18), // mocPrecision
  docPower: toContract(1),
  mocProportion: toContract(0.01 * 10 ** 18), // mocPrecision

  liquidationEnabled: false,
  _protected: toContract(1.5 * 10 ** 18), // mocPrecision

  startStoppable: true
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

const getCommissionsArrayZero = async mocInrate => {
  const ret = [
    {
      txType: (await mocInrate.MINT_BPRO_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.MINT_BPRO_FEES_MOC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_MOC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_MOC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_MOC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_MOC()).toString(),
      fee: '0'
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_MOC()).toString(),
      fee: '0'
    }
  ];
  return ret;
};

const createContracts = params => async ({ owner, useMock }) => {
  const project = await TestHelper();

  const {
    btcPrice,
    mocPrice,
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
    // commissionRate,
    peg,
    maxMintBPro,
    docTmin,
    docTmax,
    docPower,
    startStoppable,
    mocProportion = baseParams.mocProportion,
    liquidationEnabled,
    _protected
  } = params;

  const settlementContract = useMock ? MoCSettlementMock : MoCSettlement;
  const stateContract = useMock ? MoCStateMock : MoCState;
  const settlementContractProxy = useMock ? MoCSettlementMockProxy : MoCSettlementProxy;
  const stateContractProxy = useMock ? MoCStateMockProxy : MoCStateProxy;

  // Non-upgradeable
  const bpro = await BPro.new({ from: owner });
  const doc = await DoC.new({ from: owner });
  const btcPriceProvider = await BtcPriceProviderMock.new(btcPrice);
  const mocToken = await MoCToken.new({ from: owner });
  const mocPriceProvider = await MoCPriceProviderMock.new(mocPrice);

  // Upgradeable
  const mocSettlementProxy = await project.createProxy(settlementContractProxy);
  const mocStateProxy = await project.createProxy(stateContractProxy);
  const mocConnectorProxy = await project.createProxy(MoCConnectorProxy);
  const bproxProxy = await project.createProxy(BProxManagerProxy);
  const mocExchangeProxy = await project.createProxy(MoCExchangeProxy);
  const mocInrateProxy = await project.createProxy(MoCInrateProxy);
  const mocProxy = await project.createProxy(MoCProxy);
  const commissionSplitterProxy = await project.createProxy(CommissionSplitterProxy);
  const mocVendorsProxy = await project.createProxy(MoCVendorsProxy);

  // Governance
  const governorProxy = await project.createProxy(GovernorProxy);
  const stopperProxy = await project.createProxy(StopperProxy);
  const proxyAdmin = await ProxyAdmin.new();
  const upgradeDelegator = await UpgradeDelegator.new();
  const mocSettlement = await settlementContract.at(mocSettlementProxy.address);
  const mocState = await stateContract.at(mocStateProxy.address);
  const mocConnector = await MoCConnector.at(mocConnectorProxy.address);
  const bprox = await BProxManager.at(bproxProxy.address);
  const mocExchange = await MoCExchange.at(mocExchangeProxy.address);
  const mocInrate = await MoCInrate.at(mocInrateProxy.address);
  const moc = await MoC.at(mocProxy.address);
  const commissionSplitter = await CommissionSplitter.at(commissionSplitterProxy.address);
  const governor = await Governor.at(governorProxy.address);
  const stopper = await Stopper.at(stopperProxy.address);
  const mocVendors = await MoCVendors.at(mocVendorsProxy.address);

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
    mocPriceProvider.address,
    mocToken.address,
    mocVendors.address,
    liquidationEnabled,
    _protected,
    { from: owner }
  );
  const mockMocInrateChanger = await MocInrateChanger.new(
    mocInrate.address,
    7 * dayBlockSpan,
    btcxTmin,
    btcxTmax,
    btcxPower,
    bitProRate,
    // commissionRate,
    docTmin,
    docTmax,
    docPower,
    await getCommissionsArrayZero(mocInrate),
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
  const mockMoCVendorsChanger = await MoCVendorsChanger.new(
    mocVendors.address,
    owner, //  vendorGuardianAddress
    {
      from: owner
    }
  );
  const mockMocChanger = await MocChanger.new(moc.address, governor.address, stopper.address, {
    from: owner
  });
  const mocInrateInitializeParams = {
    connectorAddress: mocConnector.address,
    governor: governor.address,
    btcxTmin,
    btcxPower,
    btcxTmax,
    bitProRate,
    blockSpanBitPro: dayBlockSpan * 7,
    bitProInterestTargetAddress: owner,
    commissionsAddressTarget: owner,
    // commissionRate,
    docTmin,
    docPower,
    docTmax
  };
  const mocStateInitializeParams = {
    connectorAddress: mocConnector.address,
    governor: governor.address,
    btcPriceProvider: btcPriceProvider.address,
    liq, // mocPrecision
    utpdu, // mocPrecision
    maxDiscRate: maxDiscountRate, // mocPrecision
    dayBlockSpan, // no Precision
    ema: btcPrice,
    smoothFactor: smoothingFactor,
    emaBlockSpan,
    maxMintBPro,
    mocPriceProvider: mocPriceProvider.address,
    mocTokenAddress: mocToken.address,
    mocVendorsAddress: mocVendors.address,
    liquidationEnabled,
    protected: _protected
  };

  // Initialize contracts
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
  await moc.initialize(mocConnector.address, governor.address, stopper.address, startStoppable);
  await stopper.initialize(owner);
  await mocExchange.initialize(mocConnector.address);
  // Making sure to call the correct initialize function
  await mocState.methods[
    'initialize((address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address,address,bool,uint256))'
  ](mocStateInitializeParams);
  // Making sure to call the correct initialize function
  await mocInrate.methods[
    'initialize((address,address,uint256,uint256,uint256,uint256,uint256,address,address,uint256,uint256,uint256))'
  ](mocInrateInitializeParams);
  await bprox.initialize(mocConnector.address, governor.address, c0Cobj, x2Cobj);
  await mocSettlement.initialize(mocConnector.address, governor.address, settlementBlockSpan);
  await governor.initialize(owner);
  await commissionSplitter.initialize(
    moc.address,
    owner,
    mocProportion,
    governor.address,
    mocToken.address,
    owner
  );
  await upgradeDelegator.initialize(governor.address, proxyAdmin.address);
  await mocVendors.initialize(
    mocConnector.address,
    governor.address,
    owner //  vendorGuardianAddress
  );

  // Execute changes in MoCInrate
  await governor.executeChange(mockMocInrateChanger.address);
  // Execute changes in MoCVendors
  // await governor.executeChange(mockMoCVendorsChanger.address);

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
  await project.changeProxyAdmin(mocExchangeProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocInrateProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(governorProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(stopperProxy.address, proxyAdmin.address);
  await project.changeProxyAdmin(commissionSplitter.address, proxyAdmin.address);
  await project.changeProxyAdmin(mocVendorsProxy.address, proxyAdmin.address);

  // Contract that reverts when receiving RBTC on fallback function
  const revertingContract = await RevertingOnSend.new(moc.address, {
    from: owner
  });

  return {
    commissionSplitter,
    mocConnector,
    moc,
    mocState,
    mocInrate,
    bprox,
    bpro,
    doc,
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
    revertingContract,
    mocToken,
    mocPriceProvider,
    mocExchange,
    mocVendors,
    mockMoCVendorsChanger
  };
};

module.exports = {
  createBaseContracts: createContracts(baseParams),
  createContracts
};
