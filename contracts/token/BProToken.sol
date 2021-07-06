pragma solidity ^0.5.8;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "./OwnerBurnableToken.sol";

contract BProToken is ERC20Detailed, ERC20Pausable, OwnerBurnableToken {

  string private _name = "BitPRO";
  string private _symbol = "BITP";
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
