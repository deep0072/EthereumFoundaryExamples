// SPDX-License-Identifier: MIT License

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCordinator;
        uint64 subscriptionId;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        address link;
    }

    NetworkConfig public activateNetworkConfig;

    constructor() {
        if (block.chainid != 31337) {
            activateNetworkConfig = getSepoliaConfig();
        } else {
            activateNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                subscriptionId: 3664,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                callbackGasLimit: 2500000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        uint96 _baseFee = 0.23 ether;
        uint96 _gasPriceLink = 1e9;

        vm.startBroadcast();

        // import mock vrfcordinator and deploy
        VRFCoordinatorV2Mock vrfCordinator = new VRFCoordinatorV2Mock(
            _baseFee, // base Fee required to call fullFill RandomWords
            _gasPriceLink // gas price link required to get the response form FullFillRandom words
        );
        LinkToken linkToken = new LinkToken();

        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCordinator: address(vrfCordinator),
                subscriptionId: 0,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                callbackGasLimit: 2500000,
                link: address(linkToken)
            });
    }
}
