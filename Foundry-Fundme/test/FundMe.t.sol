// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/FundMe.sol";
import {FundMeScript} from "../script/Fundme.s.sol";

contract FundMeTest is Test {
    // public variable is fundMe contract
    FundMe public fundMe;

    // setUp function runs always first and deploy contract.
    function setUp() external {
        // here this test file is the deployer of the fundMe contract
        // fundMe = new FundMe(address(this));

        // if run this then msg.sender is us not the this test file
        FundMeScript deployFundMe = new FundMeScript();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.owner());
        console.log(address(this));
        assertEq(fundMe.owner(), msg.sender);
    }

    function testPriceFeedversionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
