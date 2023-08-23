// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract HandlerContract is Test {
    DecentralisedStableCoin dscCoin;
    DscEngine dscEngine;
    ERC20Mock wETH;
    ERC20Mock wBTC;

    constructor(DecentralisedStableCoin _dscCoin, DscEngine _dscEngine) {
        dscCoin = _dscCoin;
        dscEngine = _dscEngine;

        address[] memory collaterals = dscEngine.getCollateralTokens();
        wETH = ERC20Mock(collaterals[0]);
        wBTC = ERC20Mock(collaterals[1]);
    }

    function depositCollateral(uint256 collateralSeed, uint256 collateralAmount)
        external
    {
        // collateralSeed ==> is the random number which let us chose the different collateral seed
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        dscEngine.depositCollateral(address(collateral), collateralAmount);
    }

    function _getCollateralFromSeed(uint256 collateralSeed)
        private
        view
        returns (ERC20Mock)
    {
        // if random number is even then return weth address other wise wBTC
        if (collateralSeed % 2 == 0) {
            return wETH;
        } else {
            return wBTC;
        }
    }
}
