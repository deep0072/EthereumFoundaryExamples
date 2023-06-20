// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";

import "../src/FundMe.sol";

contract FundmeScript is Script {
    function run() public returns (FundMe) {
        vm.startBroadcast();
        FundMe fundme = new FundMe(msg.sender);
        vm.stopBroadcast();
        return fundme;
    }
}
