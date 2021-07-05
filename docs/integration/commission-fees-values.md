# Commission fees values

The value of the commission fee depends on the desired operation and the token used to pay for it. Keep in mind that if the account has balance and allowance of MoC token, commissions will be paid with this token; otherwise commissions will be paid in RBTC.

The exact percentage of the commission is set in the variable **commissionRatesByTxType** (which maps a transaction type with its commission) of the **MocInrate** contract. The transactions types are constants defined in the same contract. The different valid transaction types are the following:

| Transaction Type | Description |
| --- | --- |
| `MINT_BPRO_FEES_RBTC` | Mint BPRO with fees in RBTC |
| `REDEEM_BPRO_FEES_RBTC` | Redeem BPRO with fees in RBTC |
| `MINT_DOC_FEES_RBTC` | Mint DOC with fees in RBTC |
| `REDEEM_DOC_FEES_RBTC` | Redeem DOC with fees in RBTC |
| `MINT_BTCX_FEES_RBTC` | Mint BTCx with fees in RBTC |
| `REDEEM_BTCX_FEES_RBTC` | Redeem BTCx with fees in RBTC |
| `MINT_BPRO_FEES_MOC` | Mint BPRO with fees in MoC |
| `REDEEM_BPRO_FEES_MOC` | Redeem BPRO with fees in MoC |
| `MINT_DOC_FEES_MOC` | Mint DOC with fees in MoC |
| `REDEEM_DOC_FEES_MOC` | Redeem DOC with fees in MoC |
| `MINT_BTCX_FEES_MOC` | Mint BTCx with fees in MoC |
| `REDEEM_BTCX_FEES_MOC` | Redeem BTCx with fees in MoC |

Note that these commissions have also a precision of 18 decimals, i.e. a 1 \* 10^15 in that parameter means that 0.1% is being charged as a commission.
