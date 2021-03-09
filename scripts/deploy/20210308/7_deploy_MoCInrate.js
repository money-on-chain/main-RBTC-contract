/* eslint-disable no-console */
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');
const UpgraderChanger = artifacts.require('./changers/UpgraderChanger.sol');
const Governor = artifacts.require('moc-governance/contracts/Governance/Governor.sol');

const MoCInrate = artifacts.require('./MoCInrate.sol');
const MoCInrateChangerDeploy = artifacts.require('./MoCInrateChangerDeploy.sol');

const BigNumber = require('bignumber.js');
const deployConfig = require('./deployConfig.json');

const getCommissionsArray = mocInrate => async currentNetwork => {
  const mocPrecision = 10 ** 18;

  const ret = [
    {
      txType: (await mocInrate.MINT_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_RBTC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BPRO_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_DOC_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_DOC_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.MINT_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    },
    {
      txType: (await mocInrate.REDEEM_BTCX_FEES_MOC()).toString(),
      fee: BigNumber(deployConfig[currentNetwork].valuesToAssign.newCommissionRate)
        .times(mocPrecision)
        .toString()
    }
  ];
  return ret;
};

module.exports = async (deployer, currentNetwork, [owner], callback) => {
  try {
    // Get proxy contract
    const proxyMocInrate = await AdminUpgradeabilityProxy.at(
      deployConfig[currentNetwork].addresses.MoCInrate
    );

    // Upgrade delegator and Governor addresses (used to make changes to contracts)
    const upgradeDelegatorAddress = deployConfig[currentNetwork].addresses.UpgradeDelegator;
    const governor = await Governor.at(deployConfig[currentNetwork].addresses.Governor);

    // Deploy contract implementation
    console.log('- Deploy MoCInrate');
    const mocInrate = await deployer.deploy(MoCInrate);

    // Upgrade contracts with proxy (using the contract address of contracts just deployed)
    console.log('- Upgrade MoCInrate');
    const upgradeMocInrate = await deployer.deploy(
      UpgraderChanger,
      proxyMocInrate.address,
      upgradeDelegatorAddress,
      mocInrate.address
    );

    // Execute changes in contracts
    console.log('Execute change - MoCInrate');
    await governor.executeChange(upgradeMocInrate.address);

    // Setting commissions
    const commissions = await getCommissionsArray(mocInrate)(currentNetwork);

    // Use changer contract
    const mockMocInrateChangerDeploy = await MoCInrateChangerDeploy.new(
      mocInrate.address,
      commissions
    );

    // Execute changes in MoCInrate
    console.log('Execute change - MoCInrateChangerDeploy');
    await governor.executeChange(mockMocInrateChangerDeploy.address);
  } catch (error) {
    console.log(error);
  }

  callback();
};
