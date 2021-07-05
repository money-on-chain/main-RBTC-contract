# MoCLibConnection

- Referenced by: MocExchangeEvents, MoCLibConnection, MoCExchange, MoCInrate, MoCConverter, MoCState, MoC
- References/uses: MoCHelperLib

It's a common way of "injecting" MoCHelperLib into the contracts that will need it, along with some useful precision methods. Contracts that need this library will inherit from MoCLibConnection.
