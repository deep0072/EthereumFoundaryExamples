// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";

import "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract FundMeScript is Script {
    function run() public returns (FundMe) {
        // before startBroadcasting so that it will not cost any gas
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.ActivateConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
