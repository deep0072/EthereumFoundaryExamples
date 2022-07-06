// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    int256 private count;

    constructor(int256 _count) {
        count = _count;
    }

    function incrementCount() public {
        count += 1;
    }

    function decerementCount() public {
        count -= 1;
    }

    function getCount() public view returns (int256) {
        return count;
    }
}
