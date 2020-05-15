"""

Title: Upgrade v019
Project: MoC and RRC20
Networks: mocTestnet, mocTestnetAlpha, mocMainnet, rdocTestnet, rdocMainnet

This is script upgrade MoC Settlement Contract to version v019 Fix Partial Execution.

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
upgradeDelegator_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['upgradeDelegator'])
MoCHelperLib_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['MoCHelperLib'])
governor_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['governor'])

# fix of the link library
link_library = [('__MoCHelperLib__________________________', MoCHelperLib_address.replace('0x', ''))]

# Deploy new contract
print("Deploying new contract MoC Settlement version 019...")
path_to_json = os.path.join(path_build, "MoCSettlement_v019.json")
sc = connection_manager.load_bytecode_contract_file_json(path_to_json, link_library=link_library)
tx_hash = connection_manager.fnx_constructor(sc, gas_limit=6000000)
tx_receipt = connection_manager.wait_transaction_receipt(tx_hash)
print(tx_receipt)

new_contract_address = tx_receipt.contractAddress
print("Finish deploying contract!.")
print("New Deploy Contract Address: {address}".format(address=new_contract_address))

# Upgrade Contract
print("Upgrading proxy: {0} to new implementation {1}".format(moc_settlement_address, new_contract_address))
path_to_json = os.path.join(path_build, "MoCSettlement_v019_Updater.json")
sc = connection_manager.load_bytecode_contract_file_json(path_to_json, link_library=link_library)
tx_hash = connection_manager.fnx_constructor(sc, moc_settlement_address, upgradeDelegator_address, new_contract_address)
tx_receipt = connection_manager.wait_transaction_receipt(tx_hash)
print(tx_receipt)
print("Finish upgrading contract!.")

upgrade_contract_address = tx_receipt.contractAddress
print("Contract address to execute change: {0}".format(upgrade_contract_address))

# print("Making governor changes...")
# moc_governor = connection_manager.load_json_contract(os.path.join(path_build, "Governor.json"),
#                                                      deploy_address=governor_address)
# tx_hash = connection_manager.fnx_transaction(moc_governor, 'executeChange', upgrade_contract_address)
# tx_receipt = connection_manager.wait_transaction_receipt(tx_hash)
# print(tx_receipt)
# print("Governor changes done!")


"""

Connecting to mocTestnetAlpha...
Connected: True
Deploying new contract MoC Settlement version 019...
AttributeDict({'transactionHash': HexBytes('0x1da884c73febf8e1b1444e7228ddbd23e3b775c3accb5736f40025716f10f820'), 'transactionIndex': 0, 'blockHash': HexBytes('0xc8909f32d2e2ab120a2061ba38fa9ee1bd55cbeddd4d4dcf8dc458909bc576c0'), 'blockNumber': 805151, 'cumulativeGasUsed': 2869223, 'gasUsed': 2869223, 'contractAddress': '0xA303b8d210a5C439aa3BE0022d52Af394A9D32a4', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0xA303b8d210a5C439aa3BE0022d52Af394A9D32a4
Upgrading proxy: 0xa0dA80B5E5bdf96F9e99630Fa333821fB741A308 to new implementation 0xA303b8d210a5C439aa3BE0022d52Af394A9D32a4
AttributeDict({'transactionHash': HexBytes('0x95e088f2f96532c9c5a45daface54a09c5df06676b1cec2c09ff62cb9e672313'), 'transactionIndex': 2, 'blockHash': HexBytes('0xe62c15cce3c33d68871a7cccd536879272517ec91b008142fd10b1c30422c363'), 'blockNumber': 805153, 'cumulativeGasUsed': 408532, 'gasUsed': 225963, 'contractAddress': '0xd175c1B65f3896e76F3F4A5DbF3d5b90c33ca198', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address to execute change: 0xd175c1B65f3896e76F3F4A5DbF3d5b90c33ca198
Making governor changes...
AttributeDict({'transactionHash': HexBytes('0xc8696c119560f1b86c422b7162217163de0a852b47512bbac34d84f81d5fcd64'), 'transactionIndex': 0, 'blockHash': HexBytes('0x65c0008a2f6aa343b693a1030fdf76a7ea97f9890f8c84e95d870b85f5e68acc'), 'blockNumber': 805155, 'cumulativeGasUsed': 62989, 'gasUsed': 62989, 'contractAddress': None, 'logs': [AttributeDict({'logIndex': 0, 'blockNumber': 805155, 'blockHash': HexBytes('0x65c0008a2f6aa343b693a1030fdf76a7ea97f9890f8c84e95d870b85f5e68acc'), 'transactionHash': HexBytes('0xc8696c119560f1b86c422b7162217163de0a852b47512bbac34d84f81d5fcd64'), 'transactionIndex': 0, 'address': '0xa0dA80B5E5bdf96F9e99630Fa333821fB741A308', 'data': '0x', 'topics': [HexBytes('0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b'), HexBytes('0x000000000000000000000000a303b8d210a5c439aa3be0022d52af394a9d32a4')]})], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': '0x9258531274B945eB628656F4b30e8216938A619C', 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000200000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000004022000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Governor changes done!

Connecting to mocTestnet...
Connected: True
Deploying new contract MoC Settlement version 019...
AttributeDict({'transactionHash': HexBytes('0x387bf89706d39b24dd97ab75d0d61bc97e14a7dc6f267e15574ff6ab1242d134'), 'transactionIndex': 5, 'blockHash': HexBytes('0x57da5670235ef1a9a4a0682bef1c4234479d95c45315bbae85668552910bea27'), 'blockNumber': 834196, 'cumulativeGasUsed': 3152204, 'gasUsed': 2869223, 'contractAddress': '0x1471832Cc155e68039fdddd3b47B7db4732adD84', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0x1471832Cc155e68039fdddd3b47B7db4732adD84
Upgrading proxy: 0x367D283c53f8F10e47424e2AeB102F45eCC49FEa to new implementation 0x1471832Cc155e68039fdddd3b47B7db4732adD84
AttributeDict({'transactionHash': HexBytes('0x8ae01107e3cd7babf5b2b63a3d8617f49b14f54016dc176a5389ac8540974ddb'), 'transactionIndex': 3, 'blockHash': HexBytes('0x71b6e4ccb094bb562e24bc4475c036a1e7af854f59acd1b94d96c3b2e787dc37'), 'blockNumber': 834198, 'cumulativeGasUsed': 669789, 'gasUsed': 225963, 'contractAddress': '0x059032c480Ed8292b08FaF323Dc9130aABAa42C0', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address to execute change: 0x059032c480Ed8292b08FaF323Dc9130aABAa42C0


Connecting to mocMainnet2...
Connected: True
Deploying new contract MoC Settlement version 019...
AttributeDict({'transactionHash': HexBytes('0x2b8bcabd96ed945f84833b5a2cadc3cdb72717eb7c1ce1958f41973b15176e1e'), 'transactionIndex': 0, 'blockHash': HexBytes('0xe1946d4cb41b004f0e5a8359e94b3f5b6b007a2ce5842f21320cbdd4f98244f5'), 'blockNumber': 2348441, 'cumulativeGasUsed': 2869223, 'gasUsed': 2869223, 'contractAddress': '0x7bb3d3686BfF86C39F215a5F9b9dF47B6c80757D', 'logs': [], 'from': '0xEA14c08764c9e5F212c916E11a5c47Eaf92571e4', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0x7bb3d3686BfF86C39F215a5F9b9dF47B6c80757D
Upgrading proxy: 0x609dF03D8a85eAffE376189CA7834D4C35e32F22 to new implementation 0x7bb3d3686BfF86C39F215a5F9b9dF47B6c80757D
AttributeDict({'transactionHash': HexBytes('0x2f7795763e7b5bbaa84433c46bcbf02cde49bdbb9915dcb12b6656845320ee1c'), 'transactionIndex': 3, 'blockHash': HexBytes('0xa486fc16d209d2fe8719bbde038db82b51b85ef2768b9f3b56cbcae426b51731'), 'blockNumber': 2348442, 'cumulativeGasUsed': 398194, 'gasUsed': 226027, 'contractAddress': '0xDFF4132228270842Bd8374a3f09fa720eB855b37', 'logs': [], 'from': '0xEA14c08764c9e5F212c916E11a5c47Eaf92571e4', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address to execute change: 0xDFF4132228270842Bd8374a3f09fa720eB855b37

"""