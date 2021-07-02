# Getting BTC2X

BTC2X is targeted towards users looking to profit from long positions in bitcoin, with two times the risk and reward. Leveraged instruments borrow capital from the base bucket (50% in a X2) and pay a daily rate to it as return.

There is a relation between DOCS and BTC2X. The more DOCs minted, the more BTC2X can be minted, since they are used for leverage.

The BTC2X token does not implement an ERC20 interface and can not be traded freely because leveraged instruments cannot change owner. BTC2X are assigned to the user BTCX positions can be canceled any time though.

The daily rate can be obtained invoking the `dailyInrate()` view of the **MocInrate** contract.
