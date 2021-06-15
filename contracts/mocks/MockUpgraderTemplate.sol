pragma solidity ^0.5.8;

import "moc-governance/contracts/ChangersTemplates/UpgraderTemplate.sol";

// TODO Think of a better way to
// force solidity to compile the UpgraderTemplate so we can require it

contract MockUpgraderTemplate is UpgraderTemplate {

}

