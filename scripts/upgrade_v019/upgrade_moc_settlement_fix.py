"""

Title: Upgrade Moc Settlement v019
Project: MoC and RRC20
Networks: mocTestnet, mocTestnetAlpha, mocMainnet, rdocTestnet, rdocMainnet

This is script upgrade MoC Settlement Fix task pointer

"""


import os
from web3 import Web3
from moneyonchain.manager import ConnectionManager

network = 'mocMainnet2'
config_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.json')

connection_manager = ConnectionManager(options=config_path, network=network)

print("Connecting to %s..." % network)
print("Connected: {conectado}".format(conectado=connection_manager.is_connected))

path_build = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../build/contracts')

moc_settlement_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['MoCSettlement'])

print("Calling Settlement fixTasksPointer ...")
moc_settlement = connection_manager.load_json_contract(
    os.path.join(path_build, "MoCSettlement_v019.json"),
    deploy_address=moc_settlement_address)
tx_hash = connection_manager.fnx_transaction(moc_settlement, 'fixTasksPointer')
tx_receipt = connection_manager.wait_transaction_receipt(tx_hash)
print(tx_receipt)
print("Fix done!")


"""
Connecting to mocTestnetAlpha...
Connected: True
Calling Settlement fixTasksPointer ...
AttributeDict({'transactionHash': HexBytes('0xfa41ebb0b458b525df95aeb4e120ed215202284978c153dd0bd4c348794127b5'), 'transactionIndex': 1, 'blockHash': HexBytes('0x2192bd91a5fcd7712e7b26bbc2892ef3952bcb7bc2955e589bcf94a68ff4ad6e'), 'blockNumber': 833705, 'cumulativeGasUsed': 454132, 'gasUsed': 73028, 'contractAddress': None, 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': '0xa0dA80B5E5bdf96F9e99630Fa333821fB741A308', 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Fix done!

Connecting to mocTestnet...
Connected: True
Calling Settlement fixTasksPointer ...
AttributeDict({'transactionHash': HexBytes('0x7bb1ef87860a5bd8319befcffc7285203244088a99db84d18032bc334f6b142a'), 'transactionIndex': 3, 'blockHash': HexBytes('0x0c345db7e21903af09184541cddaabbc34b63c308682c60297d4bd21e1d5d53d'), 'blockNumber': 834211, 'cumulativeGasUsed': 161810, 'gasUsed': 73028, 'contractAddress': None, 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': '0x367D283c53f8F10e47424e2AeB102F45eCC49FEa', 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Fix done!
"""