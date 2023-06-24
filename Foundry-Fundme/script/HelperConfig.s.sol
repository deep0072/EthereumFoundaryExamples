// SPDX-License-Identifier MIT License

// this script is used to get get price feed address on the basis of chain id

// if chain id on mainnet.then we will get the address of mainnet chainlink priceFeed

pragma solidity ^0.8.18;

import {MockV3Aggregator} from "test/mock/MockV3Aggregator.sol";

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    uint8 constant DECIMAL = 8;
    int256 constant INTIAL_PRICE = 2e8;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    NetworkConfig public ActivateConfig;

    constructor() {
        if (block.chainid == 1) {
            ActivateConfig = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            ActivateConfig = getSepoliaConfig();
        } else {
            ActivateConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (ActivateConfig.priceFeedAddress != address(0)) {
            return ActivateConfig;
        }
        vm.startBroadcast();
        // here we are tryint to get the price feed address on
        //local chain by deploying chainlink aggregator on anvil local chain

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMAL,
            INTIAL_PRICE
        );

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: address(mockPriceFeed)
        });

        return anvilConfig;
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return mainnetConfig;
    }
}
