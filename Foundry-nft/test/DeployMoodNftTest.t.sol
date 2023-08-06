// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MoodNftDeployScript} from "../script/DeployMoodNft.s.sol";

/*
 * @title MoodNftDeployScript
 * @author Deepak
 * @notice this contract deploy mood nft
 * @dev Implements forge script
 */
contract DeployMoodNftScriptTest is Test {
    MoodNftDeployScript moodNftDeployScript;

    function setUp() external {
        moodNftDeployScript = new MoodNftDeployScript();
    }

    function testImageUri() public view {
        string
            memory expectedImageUri = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPg0KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSIxMDAiIGZpbGw9InllbGxvdyIgcj0iNzgiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMyIvPg0KICA8ZyBjbGFzcz0iZXllcyI+DQogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4NCiAgICA8Y2lyY2xlIGN4PSIxMjciIGN5PSI4MiIgcj0iMTIiLz4NCiAgPC9nPg0KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+DQo8L3N2Zz4=";

        string memory svgImage = vm.readFile("./img/HAPPY.svg");
        // '<!DOCTYPE html><html><head></head><body><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="500" height="500"><text x="0" y="15" fill="red">hi this is svg nft</text></svg></body></html>';

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
