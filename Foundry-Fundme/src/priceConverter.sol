// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 1e10);
    }

    function conversionRate(
        uint256 amountOfEth,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 price = getPrice(priceFeed);

        uint256 ethPriceUsd = (price * amountOfEth) / 1e18;
        return ethPriceUsd;
    }
}
