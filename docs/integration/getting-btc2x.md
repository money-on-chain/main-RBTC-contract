# Getting BTCx

BTCx is targeted towards users looking to profit from long positions in bitcoin, with two times the risk and reward. Leveraged instruments borrow capital from the base bucket (50% in a X2) and pay a daily rate to it as return.

There is a relation between DOCS and BTCx. The more DOCs minted, the more BTCx can be minted, since they are used for leverage.

The BTCx token does not implement an ERC20 interface and can not be traded freely because leveraged instruments cannot change owner. BTCx are assigned to the user BTCX positions can be canceled any time though.

The daily rate can be obtained invoking the `dailyInrate()` view of the **MocInrate** contract.
