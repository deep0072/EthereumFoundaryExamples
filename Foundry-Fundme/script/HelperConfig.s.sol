// SPDX-License-Identifier MIT License
pragma solidity ^0.8.18;

contract HelperConfig {
    address public ActivateConfig;
    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 1) {
            ActivateConfig = getMainnetConfig().priceFeedAddress;
        } else if (block.chainid == 11155111) {
            ActivateConfig = getSepoliaConfig().priceFeedAddress;
        } else {
            ActivateConfig = getAnvilConfig().priceFeedAddress;
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getAnvilConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
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
