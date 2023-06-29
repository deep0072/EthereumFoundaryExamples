// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundMeScript} from "../../script/Fundme.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = address(1); // create address
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        FundMeScript deployFundMe = new FundMeScript(); // initiate the instance of deploy script
        fundMe = deployFundMe.run(); //deploy the contract
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFund() public {
        FundFundMe fundFundme = new FundFundMe();

        fundFundme.fundfundMe(address(fundMe));

        WithdrawFundMe withdrawfundMe = new WithdrawFundMe();
        withdrawfundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
