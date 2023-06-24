// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        (, int256 priceFeed, , , ) = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        ).latestRoundData();

        return uint256(priceFeed * 1e10);
    }

    function conversionRate(uint256 amountOfEth)
        internal
        view
        returns (uint256)
    {
        uint256 price = getPrice();

        uint256 ethPriceUsd = (price * amountOfEth) / 1e18;
        return ethPriceUsd;
    }
}
