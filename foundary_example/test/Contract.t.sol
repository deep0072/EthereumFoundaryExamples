// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Counter.sol";

contract ContractTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter(20);
    }

    function testGetCount() public {
        counter.incrementCount();
        int256 value = counter.getCount();
        assertEq(value, 21);
    }
}
