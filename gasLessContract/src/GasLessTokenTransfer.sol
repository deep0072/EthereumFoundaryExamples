// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../interface/IERC20PERMIT.sol";
import "forge-std/console.sol";

// get interface of permit function
// permit function helps to approve the this contract to spend the eth on behalf of sender
// then receiver and whoever calling this contract will get the their respective amount

contract GasLessTokenTransfer {
    function send(
        address token,
        address sender,
        address receiver,
        uint amount,
        uint fee,
        uint256 deadline, // validity of signed msg
        uint8 v, //The v, r, and s parameters
        bytes32 r, //are the result of the cryptographic
        bytes32 s // signature performed when a message is signed
    ) external {
        // need permit function  -- sender approve this contract to spend amount  + fee
        IERC20PERMIT(token).permit(
            sender,
            address(this),
            amount + fee,
            deadline,
            v,
            r,
            s
        );

        // transferFrom(sender,receiver,amount) ==> send the amount to reciever
        IERC20PERMIT(token).transferFrom(sender, receiver, amount);

        /*send the amount to third person who will helps us to send transaction by spending his eth.
         this function send the fee to third person
        */
        IERC20PERMIT(token).transferFrom(sender, msg.sender, fee);
    }
}
