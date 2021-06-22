pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./OwnerBurnableToken.sol";

contract MoCToken is ERC20Detailed, OwnerBurnableToken {

  string private _name = "MoC";
  string private _symbol = "MOC";
  uint8 private _decimals = 18;

  /**
    @dev Constructor
  */
  constructor() Ownable() ERC20Detailed(_name, _symbol, _decimals) public {

  }

  /**
    @dev Fallback function
  */
  function() external {
  }
}
