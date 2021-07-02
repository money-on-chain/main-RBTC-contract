## How-to

In the following sections we will give some code on how this can be done through a Smart Contract or directly, with a console or with an app.
​

### Smart Contract​

To create a new Smart Contract that uses the Money On Chain platform, you can use any language and IDE you want. In this tutorial, we will show you how to do it using [Solidity language](https://solidity.readthedocs.io/en/v0.5.8/), [Truffle Framework](https://www.trufflesuite.com/) and [NPM](https://www.npmjs.com/).
Truffle framework offers some template projects that you can use to develop applications that use smart contracts. You can get more information [here](https://www.trufflesuite.com/boxes).
Assuming you already have your project up and running (if you don't, please follow [this link](../rationale/getting-started.md)) the only extra thing you need to do is to install our repo as a dependency in your NPM project. In order you need to do this you just need to run the following command.
​

```
npm install --save -E git+https://git@github.com/money-on-chain/main-RBTC-contract.git
```

Having done that lets you use our contract as a dependency to your contract. For this let's suppose you are doing some kind of contract that when executing a certain task charges a fixed commission. Now let's suppose that the commission is sent in RBTCs because it is easier for the user but actually you want some DOCs. The good news is that you can do this instantly just by redeeming them. The code necessary to do this is actually pretty simple.
​
You just have to import the contract
​

```js
import 'money-on-chain/contracts/MoC.sol';
```

Receive the address in the constructor in order to be able to interact with it later, and the vendorAccount address needed to do the operation

```js
constructor (MoC _mocContract, address vendorAccount, rest of your params...) {
//....rest of your constructor....
}
```

```js
//Create a new redeem request
uint256 docAmount = 90;
moc.redeemDocRequest(docAmount);
```

```js
//Add 10 docs to a redeem request.
moc.alterRedeemRequestAmount(true, 10);
//Sustract 5 docs to a redeem request.
moc.alterRedeemRequestAmount(true, 5);
```

```js
//Trying to redeem All Docs.
uint256 docBalance = docToken.balanceOf(userAddress);
moc.redeemFreeDocVendors(docBalance, vendorAccount);
```

You can send it immediately to you so you can start using it right away. In order to do this you should add a few more lines similar to the ones before, only that you will have to use the bpro token.
​
This will leave you with a contract similar to the following
​​

```js
pragma solidity ^0.5.8;
import "money-on-chain/contracts/MoC.sol";
import "money-on-chain/contracts/token/DocToken.sol";
// Here you will import your own dependencies

contract YourRedeemingDocContract {
    // Address of the MoC contract
    MoC public moc;
    // Address of the bitpro token
    DocToken public doc;
    // DOC Amount
    uint256 docAmount;
    // Address that will receive the markup
    address public vendorAccount;
    // rest of your variables

    constructor (MoC _moc, DocToken _doc, uint256 _docAmount, address _vendorAccount) public {
        moc = _moc;
        doc = _doc;
        docAmount = _docAmount;
        vendorAccount = _vendorAccount;
        // You could have more variables to initialize here
    }
​
    function createRedeemRequest() public {
        uint256 previousBalance = doc.balanceOf(msg.sender);
        moc.redeemDocRequest(docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function addToRedeemRequest(uint256 _addValue) public {
        moc.alterRedeemRequestAmount(true, docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function sustractToRedeemRequest(uint256 _addValue) public {
        moc.alterRedeemRequestAmount(false, docAmount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }

    function redeemFreeDoc(uint256 _docAmount) public {
        uint256 previousBalance = doc.balanceOf(msg.sender);
        moc.redeemFreeDocVendors(_docAmount, vendorAccount);
        uint256 newBalance = doc.balanceOf(msg.sender);
    }
    // rest of your contract
}​
```

And that is it, the only thing left to do is to add in the [Truffle migrations](https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations) scripts the address to MoC and BPro when deploying YourRedeemingDocContract and you are done.
