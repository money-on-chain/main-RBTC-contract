module.exports = {
    norpc: true,
    testCommand: 'node --max-old-space-size=4096 ../node_modules/.bin/truffle test --network coverage',
    compileCommand: 'node --max-old-space-size=4096 ../node_modules/.bin/truffle compile --network coverage',
    copyPackages: ['openzeppelin-solidity'],
    skipFiles: [
        'Migrations.sol',
        'mocks',
        'interface',
        'contracts_updated',
        'changers/productive',
        'test-contracts',
        'PartialExecution.sol'
    ]
}