// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/*
* @title DecentralisedStableCoin
* @author Deepak
* Collateral: Exogenous (Eth & btc)
* Minting: Algortihmic
* Relative Stability: Pegged to Usd
* 
* this contract is meant to be governed by the DSCENGINE and the implementation of ERC20 token standard.



 */

contract DecentralisedStableCoin is ERC20Burnable, Ownable {
    error DecentralisedStableCoin__shouldBeMoreThanZero();
    error DecentralisedStableCoin__notEnoughBalance();
    error DecentralisedStableCoin__NotZeroAddress();

    constructor() ERC20("DecentralisedStableCoin", "DSC") {}

    function burn(uint256 _amount) public override onlyOwner {
        if (_amount <= 0) {
            revert DecentralisedStableCoin__shouldBeMoreThanZero();
        }
        if (_amount > balanceOf(msg.sender)) {
            revert DecentralisedStableCoin__notEnoughBalance();
        }

        super.burn(msg.sender, _amount); // super is used for to access the parent function that is "burn"
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralisedStableCoin__NotZeroAddress();
        }

        if (_amount <= 0) {
            revert DecentralisedStableCoin__shouldBeMoreThanZero();
        }

        _mint(_to, _amount);
        return true;
    }
}
