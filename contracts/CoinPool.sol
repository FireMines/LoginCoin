// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract CoinPool is OwnableUpgradeable {
    IERC20Upgradeable public loginCoin;

    function initialize(address _loginCoinAddress, address _owner) public initializer {
        __Ownable_init(_owner);
        loginCoin = IERC20Upgradeable(_loginCoinAddress);
    }

    function distributeCoins(address recipient, uint256 amount) public onlyOwner {
        require(loginCoin.balanceOf(address(this)) >= amount, "Insufficient coins in the pool");
        loginCoin.transfer(recipient, amount);
    }

    function collectCoins(address sender, uint256 amount) public onlyOwner {
        require(loginCoin.allowance(sender, address(this)) >= amount, "Insufficient allowance");
        loginCoin.transferFrom(sender, address(this), amount);
    }
}
