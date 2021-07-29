pragma solidity ^0.5.8;

contract Migrations {
  address public owner;
  uint public last_completed_migration; // solium-disable-line mixedcase

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  // solium-disable-next-line mixedcase
  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
