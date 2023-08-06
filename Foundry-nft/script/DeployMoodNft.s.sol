// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNftDeployScript is Script {
    MoodNft moodNft;

    function run() external returns (MoodNft) {
        string memory happySvg = vm.readFile("./img/HAPPY.svg");
        string memory crySvg = vm.readFile("./img/cry.svg");

        string memory happySvgUri = svgToImageUri(happySvg);
        string memory crySvgUri = svgToImageUri(crySvg);

        vm.startBroadcast();
        moodNft = new MoodNft(happySvgUri, crySvgUri);
        vm.stopBroadcast();

        return moodNft;
    }

    /*
     * svgToImageUri==> convert svg to base64 format
     * first get svg as string convert it into bytes using encodePacked
     *then convert it into base64 format
     * then get baseuri and concatenate with base64 format with help of encodePacked
     * then convert the concatenated into string
     */
    function svgToImageUri(
        string memory _svg
    ) public pure returns (string memory) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory base64EncodedUri = Base64.encode(abi.encodePacked(_svg));

        return string(abi.encodePacked(baseUrl, base64EncodedUri));
    }
}
