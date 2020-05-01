const BigNumber = require("bignumber.js");
const Web3 = require("web3");
//You must compile the smart contracts or use the official ABIs of the //repository
const MocAbi = require("../../build/contracts/MoC.json");
const MoCInrateAbi = require("../../build/contracts/MoCInrate.json");
const MoCStateAbi = require("../../build/contracts/MoCState.json");
const truffleConfig = require('../../truffle');

/**
 * Get a provider from truffle.js file
 * @param {String} network 
 */
const getDefaultProvider = network =>
    truffleConfig.networks[network].provider || truffleConfig.networks[network].endpoint;

/**
 * Get a gasPrice from truffle.js file
 * @param {String} network 
 */
const getGasPrice = network =>
    truffleConfig.networks[network].gasPrice || 60000000;

/**
 * Get a new web3 instance from truffle.js file
 */
const getWeb3 = (network) => {
    const provider = getDefaultProvider(network);
    return new Web3(provider, null, {
        transactionConfirmationBlocks: 1
    });
};

const web3 = getWeb3('rskTestnet');
const gasPrice = getGasPrice('rskTestnet');

//Contract addresses on testnet
const mocContractAddress = "0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F";
const mocInrateAddress = "0x76790f846FAAf44cf1B2D717d0A6c5f6f5152B60";
const mocStateAddress = "0x0adb40132cB0ffcEf6ED81c26A1881e214100555";

const execute = async () => {
    web3.eth.defaultGas = 2000000;

    /**
     * Loads an specified contract
     * @param {ContractABI} abi
     * @param {String} contractAddress
     */
    const getContract = async (abi, contractAddress) =>
        new web3.eth.Contract(abi, contractAddress);

    /**
     * Transforms BigNumbers into
     * @param {BigNumber} number
     */
    const toContract = number => new BigNumber(number).toFixed(0);

    // Loading moc contract
    const moc = await getContract(MocAbi.abi, mocContractAddress);
    if (!moc) {
        throw Error("Can not find MoC contract.");
    }

    // Loading mocInrate contract. It is necessary to compute commissions
    const mocInrate = await getContract(MoCInrateAbi.abi, mocInrateAddress);
    if (!mocInrate) {
        throw Error("Can not find MoC Inrate contract.");
    }

    // Loading mocState contract. It is necessary to compute max BPRO available to mint
    const mocState = await getContract(MoCStateAbi.abi, mocStateAddress);
    if (!mocState) {
        throw Error("Can not find MoCState contract.");
    }

    const mintBpro = async btcAmount => {
        const [from] = await web3.eth.getAccounts();
        const weiAmount = web3.utils.toWei(btcAmount, "ether");
        // Computes commision value
        const commissionValue = new BigNumber(
            await mocInrate.methods.calcCommissionValue(weiAmount).call()
        );
        // Computes totalBtcAmount to call mintBpro
        const totalBtcAmount = toContract(commissionValue.plus(weiAmount));
        console.log(
            `Calling Bpro minting with account: ${from} and amount: ${weiAmount}.`
        );
        moc.methods
            .mintBPro(weiAmount)
            .send({ from, value: totalBtcAmount, gasPrice }, function (
                error,
                transactionHash
            ) {
                if (error) console.log(error);
                if (transactionHash) console.log("txHash: ".concat(transactionHash));
            }).on('transactionHash', function (hash) {
                console.log("TxHash: ".concat(hash))
            })
            .on('receipt', function (receipt) {
                console.log(receipt);
            })
            .on('error', console.error);
    };

    // Gets max BPRO available to mint
    const maxBproAvailable = await mocState.methods.maxMintBProAvalaible().call();
    const bproPriceInRBTC = await mocState.methods.bproTecPrice().call();
    console.log("=== Max Available BPRO: ".concat(maxBproAvailable.toString()));
    console.log("=== BPRO in RBTC: ".concat(bproPriceInRBTC.toString()));
    const btcAmount = "0.00001";

    // Call mint
    await mintBpro(btcAmount);
};

execute()
    .then(() => console.log("Completed"))
    .catch(err => {
        console.log("Error", err);
    });