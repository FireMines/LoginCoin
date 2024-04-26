// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./EventRewards.sol";

contract LoginCoin is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    mapping(address => uint256) private lastActiveTime;
    mapping(address => uint256) public lifetimeEarnings;
    EventRewards public eventRewards;
    
    function initialize(address initialOwner) initializer public {
        __ERC20_init("LoginCoin", "DLC");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("LoginCoin");
        __UUPSUpgradeable_init();

        transferOwnership(initialOwner);  // Transfer ownership to initialOwner
        _mint(initialOwner, 1337420 * (10 ** uint256(decimals()))); 
        _disableInitializers();

         // Setup the EventRewards contract
        eventRewards = new EventRewards(address(this), 50 * (10 ** uint256(decimals())));
    }

    function fundEventRewards(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) >= amount, "Insufficient balance in reservoir");
        _transfer(address(this), address(eventRewards), amount);
    }

    function rewardAttendance(address attendee) public onlyOwner {
        eventRewards.rewardAttendance(attendee);
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        lifetimeEarnings[to] += amount;  // Update the lifetime earnings whenever new coins are minted
    }

    // UUPS upgrade function
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    // Function to update activity manually
    function updateActivity() public {
        lastActiveTime[msg.sender] = block.timestamp;
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
        require(!paused(), "ERC20Pausable: token transfer while paused");
        lastActiveTime[from] = block.timestamp;
        lastActiveTime[to] = block.timestamp;
    }
}
