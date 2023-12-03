// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GreenGateNft.sol";

contract CollectionsFactory {
    uint256 public idEvent;

    mapping(uint256 => address) public seassons;

    function createEvent(
        string memory name,
        string memory symbol,
        uint8 maxTickets,
        address addressMarkert
    ) public returns (address) {
        GreenGate newCollection = new GreenGate(
            name,
            symbol,
            maxTickets,
            addressMarkert
        );
        seassons[idEvent] = address(newCollection);
        idEvent++;
        return address(newCollection);
    }
}
