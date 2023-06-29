// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../../src/FundMe.sol";
import {FundMeScript} from "../../script/Fundme.s.sol";

contract FundMeTest is Test {
    // public variable is fundMe contract
    FundMe public fundMe;
    // makeAddr function used to create random address

    address User = makeAddr("Deepak"); // User is the funder here
    uint256 constant SEND_VALUE = 1 ether; // amount to fund the contract
    uint256 constant STARTING_BALANCE = 10e18; // amount to fund the contract

    // setUp function runs always first and deploy contract.
    function setUp() external {
        // here this test file is the deployer of the fundMe contract
        // fundMe = new FundMe(address(this));

        // if run this then msg.sender is us not the this test file
        FundMeScript deployFundMe = new FundMeScript();
        fundMe = deployFundMe.run();
        vm.deal(User, STARTING_BALANCE); // deal method set address to new balance
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.s_owner());
        console.log(address(this));
        assertEq(fundMe.s_owner(), msg.sender);
    }

    function testPriceFeedversionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        // this test supposed to be passed when we don't have enough eth to
        vm.expectRevert(); // the next line should revert

        fundMe.fund(); // here we are trying to send the zero eth to
    }

    function testFundUpdatesDataStructure() public {
        console.log(User.balance, "balance");

        vm.prank(User); // set the msg.sender means the code below will be executed by "User"
        fundMe.fund{value: SEND_VALUE}();
        console.log(address(fundMe).balance, "balance");

        uint256 amount = fundMe.getAddressAmountToFunded(User);
        assertEq(amount, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunder() public {
        vm.prank(User); // set the msg.sender means the code below will be executed
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunderWithIndex(0);
        assertEq(funder, User);
    }

    modifier funded() {
        vm.prank(User); // set the msg.sender or caller of function that is given below
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerWithdraw() public funded {
        vm.prank(User); //here we are trying to set the User will call the withdraw function
        vm.expectRevert();
        fundMe.withDraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withDraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawlWithMultipleFunders() public {
        uint160 numberOfFounders = 10; // uin160 easy to convert to address type. but uint256 not possible
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFounders; i++) {
            hoax(address(i), SEND_VALUE); //it works as vm.prank and vm.deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withDraw();
        vm.stopPrank();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(endingFundMeBalance, 0);
    }
}
