// SPDX-License-Identifier: MIT License

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubcriptonIdScript, FundSubscription, AddConsumer} from "./CreateSubscriptionId.s.sol";

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
            address link,
            uint256 deployerPrivateKey
        ) = helperConfig.activateNetworkConfig();

        if (subscriptionId == 0) {
            // get subscription id
            // then fund the subscription with link
            // now add our raffle(consumer)
            CreateSubcriptonIdScript subscription = new CreateSubcriptonIdScript();
            subscriptionId = subscription.createSubId(
                vrfCordinator,
                deployerPrivateKey
            );
            FundSubscription fundsubscription = new FundSubscription();
            fundsubscription.fundSubscription(
                vrfCordinator,
                subscriptionId,
                link,
                deployerPrivateKey
            );
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

        // add consumer to  raffle
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            vrfCordinator,
            subscriptionId,
            address(raffle),
            deployerPrivateKey
        );

        return (raffle, helperConfig);
    }
}
