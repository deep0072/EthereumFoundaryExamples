// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 intialSupply) ERC20("DeepCoin", "DC") {
        _mint(msg.sender, intialSupply);
    }
}
