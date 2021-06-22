const flat = require('flat');
const fs = require('fs');
const { createBaseContracts } = require('./testHelpers/contractsBuilder');
const functionHelper = require('./testHelpers/functionHelper');
const precisionHelper = require('./testHelpers/precisionHelper');
const assertsHelper = require('./testHelpers/assertsHelper');
const networkFunctions = require('./testHelpers/networkHelper');
const eventsFunctions = require('./testHelpers/eventsHelper');
const { toContractBN } = require('./testHelpers/formatHelper');

const UINT_MAX_VALUE = 2 ** 256 - 1;

const getContractReadyState = (unitsMapping, unitsPrecision) => state => {
  const flatted = flat(state);
  const transform = toContractBN(unitsPrecision);
  const getPrecisionString = key =>
    unitsMapping[
      key
        .split('.')
        .reverse()
        .find(it => it in unitsMapping)
    ];
  const transformed = Object.keys(flatted).reduce((_acum, key) => {
    // Infinity doesn't have precision
    const value =
      flatted[key] === '∞'
        ? UINT_MAX_VALUE
        : transform(flatted[key], getPrecisionString(key)).toString();
    return {
      ..._acum,
      [key]: value
    };
  }, {});

  return flat.unflatten(transformed);
};

module.exports = async ({ owner, useMock = true }) => {
  const networkId = await web3.eth.net.getId();
  if (networkId >= 30 && networkId <= 33) {
    // workaround for nonce too high error due to zos pushing all the contracts at once
    // surpasing the RSK limit of 4 tx of the same account in the mempool
    // remove whne upgrade from zos to open zepelin sdk
    // https://github.com/OpenZeppelin/openzeppelin-sdk/issues/1250
    const data = fs.readFileSync('./zos.json.empty');
    fs.writeFileSync('./zos.json', data);
  }
  const contracts = await createBaseContracts({
    owner,
    useMock
  });

  const { saveState } = networkFunctions;
  // Fix snapshot after moc deploy
  await saveState();

  const precisions = await precisionHelper(contracts.moc);
  const mocFunctions = await functionHelper(contracts, precisions);
  const asserts = await assertsHelper(precisions);

  return {
    toContractBN: toContractBN(precisions.unitsPrecision),
    getContractReadyState: getContractReadyState(
      precisions.unitsMapping,
      precisions.unitsPrecision
    ),
    ...networkFunctions,
    ...asserts,
    ...contracts,
    ...precisions,
    ...mocFunctions,
    ...eventsFunctions
  };
};
