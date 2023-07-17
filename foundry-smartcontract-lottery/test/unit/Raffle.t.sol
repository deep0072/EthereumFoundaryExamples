pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {RaffleContractDeployScript} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCordinator;
    uint64 subscriptionId;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    address link;

    address Player = makeAddr("Deepak");

    uint256 public intialBalance = 10 ether;

    function setUp() public {
        RaffleContractDeployScript raffleDeployScript = new RaffleContractDeployScript();
        (raffle, helperConfig) = raffleDeployScript.run();

        (
            entranceFee,
            interval,
            vrfCordinator,
            subscriptionId,
            gasLane,
            callbackGasLimit,
            link
        ) = helperConfig.activateNetworkConfig();
        vm.deal(Player, intialBalance); // giving eth to player
    }

    function testRaffleIntializesINOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    ////////////////////////////////
    // enter Raffle ////////////////
    ////////////////////////////////

    function testRaffleRevertWhenYouDontPayEnough() public {
        vm.prank(Player);

        vm.expectRevert(Raffle.Raffle_notEnoughEth.selector);
        raffle.enterRaffle();
    }

    function testRafflePlayerWhenRaffleEnter() public {
        vm.prank(Player);
        raffle.enterRaffle{value: 0.03 ether}();
        address playerRecord = raffle.getPlayer(0);
        assert(playerRecord == Player);
    }

    function testEmitEventOnRaffleEnter() public {
        vm.prank(Player);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(Player);

        raffle.enterRaffle{value: 0.03 ether}();
    }

    function testCantEnterWhenRaffleCalculating() public {
        vm.prank(Player);

        raffle.enterRaffle{value: 0.34 ether}();
        // vm.warp == is used to advance the block time
        vm.warp(block.timestamp + interval + 1);

        //vm.roll == is used to advnace the block in blockchain
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);

        raffle.enterRaffle{value: 0.34 ether}();
    }

    ////////////////////////////////
    // test Upkeep ////////////////
    ////////////////////////////////
    function testcheckUpkeepReturnsFalseIfItHasNoBalance() public {
        // first advance the time of block using vm.warp
        // then check upKeep function
        vm.warp(block.timestamp + interval + 1);

        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upKeepNeeded);
    }

    function testcheckUpkeepReturnsFalseIfRaffleNotOpen() public {
        vm.prank(Player);
        raffle.enterRaffle{value: 0.02 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");

        assert(!upKeepNeeded);
    }

    function testcheckUpKeepReturnsFalseIfEnoughTimeHasNotPassed() public {
        vm.prank(Player);
        raffle.enterRaffle{value: 0.02 ether}();
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        console.log(upKeepNeeded, "upKeepNeeded");
        assert(!upKeepNeeded);
    }

    function testcheckUpKeepReturnsTrueIfParametersAreGood() public {
        vm.prank(Player);
        raffle.enterRaffle{value: 0.02 ether}();
        vm.warp(block.timestamp + interval + 1);
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        assert(upKeepNeeded == true);
    }
    
}
