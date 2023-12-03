// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PingPong
/// @notice Sends a LayerZero message back and forth between chains a predetermined number of times.
contract PingPongSwap {

    uint256 public suma;

    constructor(){
        suma = 0;
    }

    function swap(uint256 num) public{
        suma += num;
    }

}