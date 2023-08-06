// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MoodNft} from "../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;
    string constant s_HappySvgUri =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPg0KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSIxMDAiIGZpbGw9InllbGxvdyIgcj0iNzgiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMyIvPg0KICA8ZyBjbGFzcz0iZXllcyI+DQogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4NCiAgICA8Y2lyY2xlIGN4PSIxMjciIGN5PSI4MiIgcj0iMTIiLz4NCiAgPC9nPg0KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+DQo8L3N2Zz4=";
    string constant s_CrySvgUri =
        "data:image/svg+xml;base64,PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KIA0KPC9oZWFkPg0KPGJvZHk+Im5vbmUiIC8+IC8+DQogIDxjaXJjbGUgY3g9IjMyMCIgY3k9IjI0MCIgcj0iMTAiIGZpbGw9ImJsdWUiIC8+Cjwvc3ZnPg0KDQo8L2JvZHk+DQo8L2h0bWw+";
    address immutable i_User = makeAddr("Deepak");

    function setUp() public {
        moodNft = new MoodNft(s_HappySvgUri, s_CrySvgUri);
    }

    function testViewTokenUri() external {
        vm.prank(i_User);
        moodNft.mintNft();
        console.log(moodNft.tokenUri(0));
    }
}
