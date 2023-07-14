// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/*
 * @title Raffle
 * @author Deepak
 * @notice this contract is for creating a sample raffle
 * @dev Implements chainlink vrfV2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle_notEnoughEth();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle_UpkeepNotNeeded(
        uint256 RaffleBalance,
        uint256 RaffleState,
        uint256 numberOfPlayers
    );
    /*
     type declaration
    */

    enum RaffleState {
        OPEN, //0
        CALCULATING //1
    }

    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 public immutable i_entrancefee;
    // @dev Duration of lottery in  seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCordinator;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint64 private immutable s_subscriptionId;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    address payable[] s_players;
    uint256 s_lastTimeStamp;

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCordinator,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCordinator) {
        i_entrancefee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCordinator = VRFCoordinatorV2Interface(vrfCordinator);
        i_gasLane = gasLane;
        s_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entrancefee) {
            revert Raffle_notEnoughEth();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    /*
     * @title checkUpKeep function that contains the logic that
     * will be executed off-chain to see performUpkeep should be executed
     * the following should be true for this to return true
     * 1. time should passed to interval we set during the deployment of contract
     * 2. raffle should be in open state
     * 3. contract has eth or players
     * 4. subscription should be funded with link
     */

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool timePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (isOpen && timePassed && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    // get random number
    // use the random number to pick a random winner
    // Be automatically called this pickWinner function
    function performUpkeep(bytes calldata /* performData */) external {
        (bool upKeepNeeded, ) = checkUpkeep("");

        if (!upKeepNeeded) {
            revert Raffle_UpkeepNotNeeded(
                uint256(s_raffleState),
                address(this).balance,
                s_players.length
            );
        }

        s_raffleState = RaffleState.CALCULATING; // raffle is closed now

        /* 
        *to get the random number and  pick the winner two txn will be done
        
        *1 first request the chainLink vrf
        *then get the random number and pick the winner
        */

        /*
         * i_vrfCordinator is the VrfCordinatorinterface
         * this will make request to chainlink node to get the random number
         * then node going to call the fullFllRandmWords function which provides us
         * random number
         */
        uint256 requestId = i_vrfCordinator.requestRandomWords(
            i_gasLane, // here minimum gas price
            s_subscriptionId,
            REQUEST_CONFIRMATIONS, // confirmations from node to verify the random number
            i_callbackGasLimit, // gas limit for the response
            NUM_WORDS
        );
    }

    // get the random word
    function fulfillRandomWords(
        uint256,
        /*_requestId*/
        uint256[] memory _randomWords
    ) internal override {
        uint256 indexOfWinner = _randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN; // Raffle is open now
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = winner.call{value: address(this).balance}("");

        if (!success) {
            revert Raffle__TransferFailed();
        }

        emit PickedWinner(winner);
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entrancefee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }
}
