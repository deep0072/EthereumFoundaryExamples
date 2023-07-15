// SPDX-License-Identifier: MIT License

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubcriptonIdScript is Script {
    // first get the vrfCordinator address from helper config
    //  then get the interface vrfV2mock and using vrf cordinator address call createSubscription funtion

    function createSubscriptionId() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();

        (, , address vrfCordinator, , , ) = helperConfig
            .activateNetworkConfig();

        return createSubId(vrfCordinator);
    }

    function createSubId(address vrfCordinator) public returns (uint64) {
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCordinator).createSubscription();
        console.log("subscrition created: ", subId);
        vm.stopBroadcast();

        return subId;
    }

    function run() external returns (uint64) {
        createSubscriptionId();
    }
}
