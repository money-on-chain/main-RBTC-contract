# From outside the blockchain

The logic of the Money on Chain platform is developed with smart contracts that run on the RSK blockchain. To interact with this kind of technology, we developed a dApp (decentralized application), which is a web or mobile application that invokes the functions of the smart contracts.

You can find tutorials about developing dApps in the following resources:

- [The Ultimate Ethereum Dapp Tutorial (How to Build a Full Stack Decentralized Application Step-By-Step)](https://www.dappuniversity.com/articles/the-ultimate-ethereum-dapp-tutorial)

- [ETHEREUM PET SHOP -- YOUR FIRST DAPP](https://www.trufflesuite.com/tutorials/pet-shop)

- [RSK Truffle Boxes](https://developers.rsk.co/tools/truffle/boxes/)

The web3 library is one of the most popular to invoke the functions of smart contracts and there are different projects to use them with

- [javascript](https://web3js.readthedocs.io/)
- [Python](https://web3py.readthedocs.io/en/stable/)
- [Java and Android](https://docs.web3j.io/)
- [.NET](https://nethereum.readthedocs.io/en/latest/)
- [Swift](https://web3swift.io/)

[Truffle Framework](https://www.trufflesuite.com/) offers some template projects and tools that you can use to develop applications that use smart contracts.

We use **web3.js** and **truffle** in this tutorial.

An RSK smart contract is bytecode implemented on the RSK blockchain. When a smart contract is compiled, an ABI (application binary interface) is generated and it is required so that you can specify which contract function to invoke, as well as get a guarantee that the function will return the data in the format you expect.
The ABI in JSON format must be provided to web3 to build decentralized applications.
