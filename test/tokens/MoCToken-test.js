const { shouldBehaveLikeERC20Mintable } = require('./ERC20Mintable.behavior');
const { shouldBehaveLikeOwnerBurnableToken } = require('./OwnerBurnableToken.behaviour');

const MoCToken = artifacts.require('./contracts/MoCToken.sol');

contract('MoCToken', function([owner, anotherAccount, ...otherAccounts]) {
  const minter = owner;
  let token;
  const initialBalance = 1000;
  const otherAccountsToTest = otherAccounts.slice(0, 10);

  beforeEach(async function() {
    token = await MoCToken.new({ from: owner });
    await token.mint(anotherAccount, initialBalance, { from: owner });
    this.token = token;
  });

  shouldBehaveLikeERC20Mintable(minter, otherAccountsToTest);
  shouldBehaveLikeOwnerBurnableToken([owner, anotherAccount], initialBalance);
});
