// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './GreenGateNft.sol';


contract CollectionsFactory {

    mapping(string => address) public seassons; 

    function createEvent(
        string memory name, 
        string memory symbol,
        uint8 maxTickets,
        string memory idEvent,
        address addressMarkert
    ) public returns(address){
     GreenGate newCollection = new GreenGate(name, symbol, maxTickets, addressMarkert);
      seassons[idEvent] = address(newCollection);
      return address(newCollection);
    }
}
