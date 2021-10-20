# The MoC Contract

The Money On Chain's Smart Contract suite is in control of the minting and redeeming of its tokens, including the BitPro, DoC and BTCx tokens. This means that the generation of new tokens is controlled programmatically by said suite. To get some new tokens you should interact with the suite. The entry point is the MoC smart contract whose addresses are available on the following networks:

- mainnet: [ 0xf773B590aF754D597770937Fa8ea7AbDf2668370 ](https://explorer.rsk.co/address/0xf773b590af754d597770937fa8ea7abdf2668370)
- testnet: [ 0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F ](https://explorer.testnet.rsk.co/address/0x2820f6d4d199b8d8838a4b26f9917754b86a0c1f)

In the world of second and third generation blockchains it is not possible to update the code of an already deployed smart contract. If we need to fix a bug or update the logic of a function, then we can use the proxy architecture pattern.

The proxy pattern allows all function calls to go through a Proxy contract that will redirect the message to another smart contract that contains the business logic. MoC is a Proxy Contract.

When the logic needs to be updated, a new version of your business logic contract is created and the reference is updated in the proxy contract. You can read more about proxies contracts [here](https://blog.openzeppelin.com/proxy-patterns/).
