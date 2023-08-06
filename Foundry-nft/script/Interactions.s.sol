pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract MintBasicNft is Script {
    string constant TOKEN_URI =
        "https://ipfs.io/ipfs/QmTkuG616j9BhjB9cvNrGJaJ7kkrHn1ZgjLH3zac5yKdE7?filename=tokenUri.json";

    function run() external {
        address basicNftAddress = DevOpsTools.get_most_recent_deployment("BasicNft", block.chainid);
        mintNftOnContract(basicNftAddress);
    }

    function mintNftOnContract(address nftContract) public {
        vm.startBroadcast();
        BasicNft(nftContract).mintNft(TOKEN_URI);
        vm.stopBroadcast();
    }
}

contract MoodNftScript is Script {
    MoodNft moodNft;

    function run() external {
        address moodNftAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);

        mintMoodNft(moodNftAddress);
    }

    function mintMoodNft(address _moodNftAddress) public {
        vm.startBroadcast();
        MoodNft(_moodNftAddress).mintNft();
        vm.stopBroadcast();
    }
}
