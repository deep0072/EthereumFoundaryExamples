// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/FundMe.sol";

contract FundMeTest is Test {
    // public variable is fundMe contract
    FundMe public fundMe;

    // setUp function runs always first and deploy contract.
    function setUp() external {
        // here this test file is the deployer of the fundMe contract
        fundMe = new FundMe(address(this));
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.owner());
        console.log(address(this));
        assertEq(fundMe.owner(), address(this));
    }
}
