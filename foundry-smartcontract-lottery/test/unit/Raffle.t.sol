pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {RaffleContractDeployScript} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCordinator;
    uint64 subscriptionId;
    bytes32 gasLane;
    uint32 callbackGasLimit;

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
            callbackGasLimit
        ) = helperConfig.activateNetworkConfig();
    }

    function testRaffleIntializesINOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }
}
