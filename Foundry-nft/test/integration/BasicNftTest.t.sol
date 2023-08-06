// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {DeployNftScript} from "../../script/DeployNft.s.sol";
import {BasicNft} from "../../src/BasicNft.sol";

contract BasicNftTest is Test {
    BasicNft basicNft;
    address private User = makeAddr("Deepak");

    string constant TOKEN_URI =
        "https://ipfs.io/ipfs/QmTkuG616j9BhjB9cvNrGJaJ7kkrHn1ZgjLH3zac5yKdE7?filename=tokenUri.json";

    function setUp() public {
        DeployNftScript deployNft = new DeployNftScript();
        basicNft = deployNft.run();
    }

    function testNameIsCorrect() public view {
        string memory nameOfNft = basicNft.name();
        console.log(nameOfNft, "nameOfNft: ");
        assert(keccak256(abi.encodePacked(nameOfNft)) == keccak256(abi.encodePacked("mark52")));
    }

    function testCanMintAndHaveBalance() public {
        vm.prank(User);

        // here we are minting nft
        // then check balance of user
        // nad then compare token uri after miniting

        basicNft.mintNft(TOKEN_URI);
        assert(basicNft.balanceOf(User) == 1);
        // here we are tyring to compare string
        // first we are converting string to bytes format and then
        // converting intot hash foramt using keccak256 algo
        assert(keccak256(abi.encodePacked(TOKEN_URI)) == keccak256(abi.encodePacked(basicNft.tokenURI(0))));
    }
}
