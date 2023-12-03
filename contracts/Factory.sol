// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GreenGateNft.sol";

contract CollectionsFactory {
    uint256 public idEvent;

    mapping(uint256 => address) public seassons;

    event CollectionCreated(address indexed newCollection, uint256 idEvent);

    function createEvent(
        string memory name,
        string memory symbol,
        uint8 maxTickets,
        address beneficiary,
        address addressMarkert
    ) public returns (address) {
        GreenGate newCollection = new GreenGate(
            name,
            symbol,
            maxTickets,
            beneficiary,
            addressMarkert
        );
        seassons[idEvent] = address(newCollection);

        emit CollectionCreated(address(newCollection), idEvent);
        idEvent++;
        return address(newCollection);
    }
}
