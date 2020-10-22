const { promisify } = require('util');

const { BN } = web3.utils;

let lastSnapshot;

const waitNBlocks = async n => {
  const sendAsync = promisify(web3.currentProvider.send);
  await Promise.all(
    [...Array(n).keys()].map(i =>
      sendAsync({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: i
      })
    )
  );
};

const saveState = async () =>
  new Promise(resolve => {
    web3.currentProvider.send(
      {
        jsonrpc: '2.0',
        method: 'evm_snapshot',
        id: 0
      },
      (error, res) => {
        const result = parseInt(res.result, 0);
        lastSnapshot = result;
        resolve(result);
      }
    );
  });

const revertState = async () => {
  await new Promise((resolve, reject) =>
    web3.currentProvider.send(
      {
        jsonrpc: '2.0',
        method: 'evm_revert',
        params: lastSnapshot,
        id: 0
      },
      (error, res) => {
        resolve(res.result);

        if (error) {
          reject(error);
        }
      }
    )
  );

  lastSnapshot = await saveState();
};

const getTxCost = async ({ receipt }) => {
  const { gasPrice } = await web3.eth.getTransaction(receipt.transactionHash);
  return new BN(receipt.gasUsed).mul(new BN(gasPrice));
};

module.exports = {
  saveState,
  revertState,
  getTxCost,
  waitNBlocks
};
