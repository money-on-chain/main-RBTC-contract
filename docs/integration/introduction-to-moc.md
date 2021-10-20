# Introduction to MoC

Money On Chain is a suite of smart contracts whose purpose is providing:

- A bitcoin-collateralized stable-coin, Dollar On Chain, (DoC)
- A passive income hodler-targeted token, BitPro (BPRO)
- A leveraged Bitcoin investment instrument (BTCX series).

The rationale behind this is that deposits of RBTC help collateralize the DoCs, BitPro absorbs the USD-BTC rate fluctuations, and BTCx is leveraged borrowing value from BitPro and DoC holders, with a daily interest rate being paid to the former.

Note in this tutorial we will use BTC and RBTC as interchangeable terms, as there is a 1:1 peg guaranteed by the RSK network, but in all the cases we mean RBTC as this is the correct coin of the RSK token.

MoC system is a network of cooperative smart contracts working together to ultimately provide a US dollar pegged ERC20 Token (DoC). In this sense, the contracts we can categorize them into 4 categories:

- _MoC state Contracts_: They keep MoC state variables and logic (MoC, MoCState, MoCBucketContainer, MoCSettlement)
- _MoC pure logic Contracts & Libraries_: Functional extensions of the above merely to have responsibility separation and contracts size (aka deploy fee) low. (MoCHelperLib, MoCLibConnection, MoCConverter, MoCExchange, MoCConnector, MoCBProxManager, MoCInrate, MoCWhitelist, MoCBase)
- _Tokens_: Tokens backed by the system (OwnerBurnableToken, DocToken, BProToken, MoCToken)
- _External Dependencies_: External contracts the system relies on, in this case the Oracle or price provider; this could evolve independently of MoC system as along as the interface is maintained. (PriceProvider)

Also you can read official information about [MoC architecture and Money on Chain's smart contracts](../README.md)
