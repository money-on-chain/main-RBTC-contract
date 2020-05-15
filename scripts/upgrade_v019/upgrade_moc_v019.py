"""

Title: Upgrade v019
Project: MoC and RRC20
Networks: mocTestnet, mocTestnetAlpha, mocMainnet, rdocTestnet, rdocMainnet

This is script upgrade MoC Contract to version v019 Fix Evalbucketliquidation.
This fix consist in add modifier to the function eval bucket liquidation that
prevent to liquidate bucket when is settlement running.

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

moc_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['MoC'])
upgradeDelegator_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['upgradeDelegator'])
MoCHelperLib_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['MoCHelperLib'])
governor_address = Web3.toChecksumAddress(
    connection_manager.options['networks'][network]['addresses']['governor'])

# fix of the link library
link_library = [('__MoCHelperLib__________________________', MoCHelperLib_address.replace('0x', ''))]

# Deploy new contract
print("Deploying new contract MoC version 019...")
path_to_json = os.path.join(path_build, "MoC.json")
sc = connection_manager.load_bytecode_contract_file_json(path_to_json, link_library=link_library)
tx_hash = connection_manager.fnx_constructor(sc, gas_limit=6000000)
tx_receipt = connection_manager.wait_transaction_receipt(tx_hash)
print(tx_receipt)

new_contract_address = tx_receipt.contractAddress
print("Finish deploying contract!.")
print("New Deploy Contract Address: {address}".format(address=new_contract_address))

# Upgrade Contract
print("Upgrading proxy: {0} to new implementation {1}".format(moc_address, new_contract_address))
path_to_json = os.path.join(path_build, "MoC_v019_Updater.json")
sc = connection_manager.load_bytecode_contract_file_json(path_to_json, link_library=link_library)
tx_hash = connection_manager.fnx_constructor(sc, moc_address, upgradeDelegator_address, new_contract_address)
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
Deploying new contract MoC version 019...
AttributeDict({'transactionHash': HexBytes('0x79326c0b351d2db8e8b4025ee703642ab5fe89e0aff9246f9ff2e5d38b0e9e33'), 'transactionIndex': 2, 'blockHash': HexBytes('0x8d38c410bd7e5d6d12bcbd844d88355f55defa80ba728a48d4ceece1e48e287f'), 'blockNumber': 756780, 'cumulativeGasUsed': 5692721, 'gasUsed': 5581328, 'contractAddress': '0xEe319505F1BE7E05203E2dA5d2ecd79a127ceE6C', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0xEe319505F1BE7E05203E2dA5d2ecd79a127ceE6C
Upgrading old implementation: 0xE02f9AE8fe5Da307b6C7cd928AEa380392f5a395 to newone 0xEe319505F1BE7E05203E2dA5d2ecd79a127ceE6C
AttributeDict({'transactionHash': HexBytes('0x057dda9858f71d87a5d4eec3664a5b2d59042266f76de00ee9b80ac12977c612'), 'transactionIndex': 0, 'blockHash': HexBytes('0x275d3661a0b53dbb997cb47fd4e724442516f554e3c2ef72d815b72cad84e62e'), 'blockNumber': 756781, 'cumulativeGasUsed': 225963, 'gasUsed': 225963, 'contractAddress': '0x617aD9e49EB40B5c844fD02172bbFeF0e4A4a004', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address: 0x617aD9e49EB40B5c844fD02172bbFeF0e4A4a004
Making governor changes...
AttributeDict({'transactionHash': HexBytes('0x29f3b77403757f91b1278233999097752fdc4aa4b6a4ef8c889939770cd06286'), 'transactionIndex': 2, 'blockHash': HexBytes('0xe336801238533675f9891954f512bedc7d024e6b7fa676b2744a5f54965202cb'), 'blockNumber': 756782, 'cumulativeGasUsed': 172502, 'gasUsed': 62989, 'contractAddress': None, 'logs': [AttributeDict({'logIndex': 0, 'blockNumber': 756782, 'blockHash': HexBytes('0xe336801238533675f9891954f512bedc7d024e6b7fa676b2744a5f54965202cb'), 'transactionHash': HexBytes('0x29f3b77403757f91b1278233999097752fdc4aa4b6a4ef8c889939770cd06286'), 'transactionIndex': 2, 'address': '0xE02f9AE8fe5Da307b6C7cd928AEa380392f5a395', 'data': '0x', 'topics': [HexBytes('0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b'), HexBytes('0x000000000000000000000000ee319505f1be7e05203e2da5d2ecd79a127cee6c')]})], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': '0x9258531274B945eB628656F4b30e8216938A619C', 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000400000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000004000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000008000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000')})
Governor changes done!


Connecting to mocTestnet...
Connected: True
Deploying new contract MoC version 019...
AttributeDict({'transactionHash': HexBytes('0xc0d4c549fdf911538e3a229602b6c42b40725a1cc87accaf44e92e26df448d32'), 'transactionIndex': 0, 'blockHash': HexBytes('0xac5dc724d97d1a5385a460e655a2d02a7c7296bd45f43d268b168e75be1f4d38'), 'blockNumber': 757417, 'cumulativeGasUsed': 5581328, 'gasUsed': 5581328, 'contractAddress': '0xEDFbA0282cE52904139c93D98Fc8C5647fb73314', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0xEDFbA0282cE52904139c93D98Fc8C5647fb73314
Upgrading proxy: 0x2820f6d4D199B8D8838A4B26F9917754B86a0c1F to new implementation 0xEDFbA0282cE52904139c93D98Fc8C5647fb73314
AttributeDict({'transactionHash': HexBytes('0xf875550dd41769c4bd5615354ff70339802de1f9d5f4da45a1546c2d4ed7f1a7'), 'transactionIndex': 0, 'blockHash': HexBytes('0x1b96c0bd45a16ee95a5e24b0cd4913fe36318f1f9da9f6101e932ee8f3519ced'), 'blockNumber': 757418, 'cumulativeGasUsed': 225963, 'gasUsed': 225963, 'contractAddress': '0x8fE66Ea723F404007b7436b94317116160916505', 'logs': [], 'from': '0xaB242E50E95C2F539242763A4ed5DB1AEe5CE461', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address to execute change: 0x8fE66Ea723F404007b7436b94317116160916505

Connecting to mocMainnet2...
Connected: True
Deploying new contract MoC version 019...
AttributeDict({'transactionHash': HexBytes('0x7c3b759ad8344eda8ce0a06d464d5f6eb9c10f8a7d046176c279690376824785'), 'transactionIndex': 0, 'blockHash': HexBytes('0x862f9edeb8fd298f2489c720f0fa76a43ca9638ee19433923c43cd32a5ae3171'), 'blockNumber': 2270312, 'cumulativeGasUsed': 5581328, 'gasUsed': 5581328, 'contractAddress': '0xba5F92D00b932c3b57457AbCa7D2DAa625906054', 'logs': [], 'from': '0xEA14c08764c9e5F212c916E11a5c47Eaf92571e4', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish deploying contract!.
New Deploy Contract Address: 0xba5F92D00b932c3b57457AbCa7D2DAa625906054
Upgrading proxy: 0xf773B590aF754D597770937Fa8ea7AbDf2668370 to new implementation 0xba5F92D00b932c3b57457AbCa7D2DAa625906054
AttributeDict({'transactionHash': HexBytes('0x30bb6f2f65b977307d1716f85fa9d668a2a79f1789abe6a6eecd26f9d8f16d88'), 'transactionIndex': 0, 'blockHash': HexBytes('0x7535c7bcd10b9abe3b9818b9ce93307ab58cfcffd60c05d1fd463275998bff05'), 'blockNumber': 2270314, 'cumulativeGasUsed': 226027, 'gasUsed': 226027, 'contractAddress': '0xaC467d861c899e1De9b56a68e5C87a4C61e0f2c9', 'logs': [], 'from': '0xEA14c08764c9e5F212c916E11a5c47Eaf92571e4', 'to': None, 'root': '0x01', 'status': 1, 'logsBloom': HexBytes('0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')})
Finish upgrading contract!.
Contract address to execute change: 0xaC467d861c899e1De9b56a68e5C87a4C61e0f2c9

"""