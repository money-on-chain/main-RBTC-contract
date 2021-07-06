# MoCWhitelist

- Referenced by: MoCConnector
- References/uses: Ownable
- Inherits from: Ownable

Handles contract whitelisting, a list of allowed contracts to call on each other.
Due to the big code size, it was necessary to separate the logic into many contracts, and those contracts had to trigger changes in each other that naturally should belonged to internal functions. To solve this, we make this functions public but only accepting calls from certain addresses (whitelisted), which are configured to the necessary contracts while deploy and initialize.
