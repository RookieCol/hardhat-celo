// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";

contract GreenGate is ERC721A {
    uint256 private maxSupply; 
    address addressMarket;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        address _addressMarket     
        ) ERC721A(name, symbol) {
        maxSupply = _maxSupply;
        addressMarket = _addressMarket;
    }

   function mint(uint256 quantity, address to ) external  {
        require(addressMarket == msg.sender, "Should call owner");
        require(totalSupply() + quantity <= maxSupply, "There is not tickets left");
        _mint(to, quantity);
    }

    function remainingSupply() external view returns (uint256) {
        return maxSupply - totalSupply();
    }
}
