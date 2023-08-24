// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from
    "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*

* @title OracleLib
* @author Deepak 
* @notice this library is used to check the Chainlink Oracle for stale data (means that data which doesn't changes for perticular time of period)
* We want  DscEngine to Freeze when price become stale


 */

library OracleLib {
    error OracleLib__StalePrice();

    uint256 private constant TIMEOUT = 3 hours;

    function stalePriceCheck(AggregatorV3Interface priceFeed)
        public
        view
        returns (uint80, int256, uint256, uint256, uint80)
    {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        if (block.timestamp - updatedAt > TIMEOUT) {
            revert OracleLib__StalePrice();
        }

        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}
