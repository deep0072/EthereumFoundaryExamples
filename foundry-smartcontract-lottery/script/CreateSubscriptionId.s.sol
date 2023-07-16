// SPDX-License-Identifier: MIT License

/*
 * @title Create Subscription
 * @author Deepak
 * @notice this contract is for to generat subscription id
 * @dev Implements chainlink vrfV2
 */

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubcriptonIdScript is Script {
    // first get the vrfCordinator address from helper config
    //  then get the interface vrfV2mock and using vrf cordinator address call createSubscription funtion

    function createSubscriptionId() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();

        (, , address vrfCordinator, , , , ) = helperConfig
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

/*
 * @title Fund Subscription
 * @author Deepak
 * @notice this contract is for to fund the Subscription
 * @dev Implements chainlink vrfV2 and used fundSubscription function to fund the subscription
 */
contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsinfConfig() public {
        // first get the vrf contract address which helps us to use the fundSubscription
        // get sub id
        // also get the chainLink token address to fund the link to subscription
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCordinator,
            uint64 subId,
            ,
            ,
            address link
        ) = helperConfig.activateNetworkConfig();

        fundSubscription(vrfCordinator, subId, link);
    }

    function fundSubscription(
        address vrfCordinator,
        uint64 subId,
        address link
    ) public {
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
        }
    }

    function run() external {
        fundSubscriptionUsinfConfig();
    }
}

/*
 * @title AddConsumer
 * @author Deepak
 * @notice this contract is to let us raffle contract to interact with chainlink vrf smartcontract
 * @dev Implements chainlink vrfV2 and used fundSubscription function to fund the subscription
 */

contract AddConsumer is Script {
    function addConsumer(
        address vrfAddress,
        uint64 subId,
        address raffle
    ) public {
        console.log("Adding consumer contract ", raffle);
        console.log("Using vrf cordinator ", vrfAddress);
        console.log("using subId ", subId);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfAddress).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCordinator, uint64 subId, , , ) = helperConfig
            .activateNetworkConfig();

        addConsumer(vrfCordinator, subId, raffle);
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}
