// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './GreenGateNft.sol';


contract CollectionsFactory {

        mapping(string=>address) seassons; 

    function createEvent(string memory name, string memory symbol,uint8 maxTickets,string memory idEvent) public returns(address){

     GreenGate newCollection = new GreenGate(name,symbol,maxTickets);
      seassons[idEvent] = address(newCollection);
      return seassons[idEvent];
    }


}




