// SPDX-License-Identifier: MIT License

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubcriptonIdScript} from "./CreateSubscriptionId.s.sol";

contract RaffleContractDeployScript is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCordinator,
            uint64 subscriptionId,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.activateNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubcriptonIdScript subscription = new CreateSubcriptonIdScript();
            subscriptionId = subscription.createSubId(vrfCordinator);
        }

        vm.startBroadcast();

        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCordinator,
            subscriptionId,
            gasLane,
            callbackGasLimit
        );
        vm.stopBroadcast();

        return (raffle, helperConfig);
    }
}
