// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Test, console} from "forge-std/Test.sol";

import "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract FundMeScript is Script, Test {
    function run() public returns (FundMe) {
        // declaring "helperConfig" before startBroadcasting so that it will not cost any gas
        // this instance let us to ge the priceFedd address based on chainId
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.ActivateConfig();
        console.log(ethUsdPriceFeed, "eth price usd");
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // this will deploy the contract
        vm.stopBroadcast();
        return fundMe;
    }
}
