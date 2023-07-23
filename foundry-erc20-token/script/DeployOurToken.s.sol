// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurTokenScript is Script {
    uint256 public constant INTIAL_SUPPLY = 5000 ether;

    function run() external returns (OurToken) {
        vm.startBroadcast();
        OurToken ot = new OurToken(INTIAL_SUPPLY);
        vm.stopBroadcast();
        return ot;
    }
}
