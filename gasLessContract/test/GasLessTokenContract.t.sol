// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC20PERMIT.sol";
import "../src/GasLessTokenTransfer.sol";

contract GasLessTokenTransferTest is Test {
    ERC20Permit private token;
    GasLessTokenTransfer private gasLess;

    address sender;
    address receiver;
    uint constant AMOUNT = 1000; // 10K DAI TOKEN WE WILL TRANSFER
    uint constant FEE = 10; // 10 DAI TOKEN WILL BE PAID AS FEE

    uint256 constant SENDER_PRIVATE_KEY = 111;

    function setUp() public {
        sender = vm.addr(SENDER_PRIVATE_KEY);
        receiver = address(2); // this is local address of foundry that will be act as receiver address
        token = new ERC20Permit("test", "test", 18);

        //
        token.mint(sender, AMOUNT + FEE); // here we are givng amount to sender.
        gasLess = new GasLessTokenTransfer();
    }

    // this test gonna let sender sign up the permit message and this contract will call GasLessTokenTransfer contract
    // and token will be transfer from sender to reciever address  amd this contract will recieve some of fee
    function testValidSig() public {
        uint deadline = block.timestamp + 60;
        // prepare the permit hash
        bytes32 permitHash = _getPermitHash(
            sender,
            address(gasLess),
            AMOUNT + FEE,
            token.nonces(sender),
            deadline
        );

        // after getting the hash, sign the hash with the help of sender
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            SENDER_PRIVATE_KEY,
            permitHash
        ); // v ,r ,s part of signed message

        // Execute send
        gasLess.send(
            address(token),
            sender,
            receiver,
            AMOUNT,
            FEE,
            deadline,
            v,
            r,
            s
        );

        // // check token balance
        assertEq(
            token.balanceOf(sender),
            0,
            "sender balance after sending token"
        );
        assertEq(
            token.balanceOf(receiver),
            AMOUNT,
            "reciever balance after sending token"
        );
        assertEq(
            token.balanceOf(address(this)),
            FEE,
            "contract balance after sending token"
        );
    }

    // this will return permit hash of signed message
    function _getPermitHash(
        address owner,
        address spender,
        uint value,
        uint nonce,
        uint deadline
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }
}

//0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266

//   0xb4c79dab8f259c7aee6e5b2aa729821864227e84
