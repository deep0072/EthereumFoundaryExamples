// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {MoodNftDeployScript} from "../script/DeployMoodNft.s.sol";

/*
 * @title MoodNft
 * @author Deepak
 * @notice this contract create mood nft
 * @dev Implements openzappelin library
 */
contract DeployMoodNftScriptTest is Test {
    MoodNftDeployScript moodNftDeployScript;

    function setUp() external {
        moodNftDeployScript = new MoodNftDeployScript();
    }

    function testImageUri() public view {
        string
            memory expectedImageUri = "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+PGh0bWw+PGhlYWQ+PC9oZWFkPjxib2R5PjxzdmcgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgd2lkdGg9IjUwMCIgaGVpZ2h0PSI1MDAiPjx0ZXh0IHg9IjAiIHk9IjE1IiBmaWxsPSJyZWQiPmhpIHRoaXMgaXMgc3ZnIG5mdDwvdGV4dD48L3N2Zz48L2JvZHk+PC9odG1sPg==";

        string
            memory svgImage = '<!DOCTYPE html><html><head></head><body><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="500" height="500"><text x="0" y="15" fill="red">hi this is svg nft</text></svg></body></html>';

        string memory actualImageUri = moodNftDeployScript.svgToImageUri(
            svgImage
        );

        console.log(actualImageUri, "actualImageUri");
        console.log(expectedImageUri, "expectedImageUri");
        assert(
            keccak256(abi.encodePacked(actualImageUri)) ==
                keccak256(abi.encodePacked(expectedImageUri))
        );
    }
}
