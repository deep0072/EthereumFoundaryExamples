// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurTokenScript} from "../script/DeployOurToken.s.sol";

contract CounterTest is Test {
    OurToken public ourToken;
    DeployOurTokenScript public deployer;
    address bob = makeAddr("bob");
    address deep = makeAddr("deep");
    uint256 constant INTIAL_BALANCE = 5 ether;

    function setUp() public {
        deployer = new DeployOurTokenScript();
        ourToken = deployer.run();
        vm.prank(msg.sender);
        ourToken.transfer(bob, INTIAL_BALANCE);
    }

    function testIntialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INTIAL_SUPPLY());
    }

    function bobBalnce() external {
        assertEq(INTIAL_BALANCE, ourToken.balanceOf(bob));
    }

    function testTransferAndCheckBalance() external {
        // create address
        // then send some token
        // then check balance

        uint256 amount = 900;
        address reciever = makeAddr("Deepak");
        console.log(ourToken.balanceOf(msg.sender), "before transfer");
        uint256 intialBalance = ourToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        ourToken.transfer(reciever, amount);
        assertEq(ourToken.balanceOf(reciever), amount);
        assertEq(ourToken.balanceOf(msg.sender), intialBalance - amount);
    }

    function testAllowanceWorking() external {
        uint256 intialAllowance = 1000;

        // first let the bob approve to spend the deep some amount
        vm.prank(bob);

        ourToken.approve(deep, intialAllowance);

        // after approval deep will call transferFrom and will get the desire amount
        //which will be less than equal to approved amount
        uint256 amount = 500;
        vm.prank(deep);
        ourToken.transferFrom(bob, deep, amount);
        assertEq(ourToken.balanceOf(deep), amount);
        assertEq(ourToken.balanceOf(bob), INTIAL_BALANCE - amount);
    }
}
