// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    // create struct  which will contain
    // address of wETH, address of wBTC
    // priceFeed address of wETH, wBTC
    struct NetworkConfig {
        address wETH;
        address wBTC;
        address wEthPriceFeed;
        address wBtcPriceFeed;
        address deployerKey;
    }

    NetworkConfig public ActiveNetworkConfig;

    uint8 constant DECIMALS = 8;
    int256 constant ETH_USD_PRICE = 2000e8;
    int256 constant BTC_USD_PRICE = 1000e8;

    constructor() {
        if (bock.chainid == 11155111){
            ActiveNetworkConfig = sepoliaChainEthConfig();
        }else {
            ActiveNetworkConfig = anvilChainEthConfig();

        }
    }

    function sepoliaChainEthConfig() external pure returns (NetworkConfig memory) {
        NetworkConfig memory activeNetworkConfig = NetworkConfig({
            wETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            wBTC: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
            wEthPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wBtcPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            deployerKey: vm.envUint("PRIVATE_KEY");
        });

        return activeNetworkConfig;
    }

    function anvilChainEthConfig() external returns (NetworkConfig memory) {
        /*
        * first check priceFeed address exist or not
        * if not exists then first deploy priceFeed contract that give us the address give us price of weth

        * also create weth token using er20 contract               
        
        */

        vm.startBroadcast();
        MockV3Aggregator wethPriceFeed = new MockV3Aggregator(DECIMALS,ETH_USD_PRICE);
        ERC20Mock wethMock = new ERC20Mock("WETH","WETH",msg.sender, 1000e8);

        MockV3Aggregator wbtcPriceFeed = new MockV3Aggregator(DECIMALS,BTC_USD_PRICE);
        ERC20Mock wbtcMock = new ERC20Mock("WBTC", "WBTC",msg.sender, 1000e8);

        vm.stopBroadcast();

        NetworkConfig memory activeNetworkConfig = NetworkConfig({
            wETH: address(wethMock),
            wBTC: address(wbtcMock),
            wEthPriceFeed: address(wethPriceFeed),
            wBtcPriceFeed: address(wethPriceFeed)
            deployerKey: vm.envUint("ANVIL_PRIVATE_KEY");
        });

        return activeNetworkConfig;
    }
}
