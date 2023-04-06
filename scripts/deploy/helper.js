/* eslint-disable no-console */
/* eslint-disable func-names */

const fs = require('fs');
const { scripts, ConfigVariablesInitializer } = require('zos');

const { add, push, create, setAdmin } = scripts;

const getConfig = (network, path) => {
  console.log('Configuration path: ', path);
  let config;

  if (fs.existsSync(path)) {
    const rawdata = fs.readFileSync(path);
    config = JSON.parse(rawdata);
  } else {
    throw new Error(`Missing configuration for network '${network}'.`);
  }
  return config;
};

const getNetwork = processArgs => {
  let network = 'development';
  for (let i = 0; i < processArgs.length; i++) {
    if (processArgs[i] === '--network') {
      network = processArgs[i + 1];
      break;
    }
  }
  return network;
};

const saveConfig = (config, path) => {
  // console.log('saveConfig path: ', path);
  fs.writeFileSync(path, JSON.stringify(config, null, 2));
};

const getProxies = network => {
  const zosPath = `./zos.${network}.json`;
  console.log('Using zos path: ', zosPath);
  let proxies;

  if (fs.existsSync(zosPath)) {
    const rawdata = fs.readFileSync(zosPath);
    proxies = JSON.parse(rawdata);
  } else {
    throw new Error(`Missing zos.(network).json path for network '${network}'.`);
  }
  return proxies;
};

// eslint-disable-next-line max-len
const deployProxyContract = async (
  { network, contractAlias, newAdmin, owner },
  constructorArguments
) => {
  console.log(
    'Deploy proxy contract',
    network,
    contractAlias,
    newAdmin,
    Object.values(constructorArguments)
  );

  const { txParams } = await ConfigVariablesInitializer.initNetworkConfiguration({
    network,
    from: owner
  });

  const options = { network, txParams };
  console.log('Adding contract to zos tracking system');
  add({ contractsData: [contractAlias] });
  // This may cause problems if there are too many implementations
  // being pushed. Try removing them in zos.json if you are having this issue
  console.log('Pushing implementations');
  await push({ force: true, ...options });
  console.log('Creating proxy');
  const proxyContract = await create({
    contractAlias,
    ...options
  });
  console.log('Initializing');
  proxyContract.methods.initialize(Object.values(constructorArguments));
  console.log('Setting admin');
  await setAdmin({
    contractAlias,
    ...options,
    newAdmin
  });
  console.log('Finished deploying Proxy');

  return proxyContract;
};

const shouldExecuteChanges = currentNetwork =>
  currentNetwork === 'development' ||
  currentNetwork === 'coverage' ||
  currentNetwork === 'regtest' ||
  currentNetwork === 'prueba';

module.exports = {
  getConfig,
  getNetwork,
  saveConfig,
  deployProxyContract,
  shouldExecuteChanges,
  getProxies
};
