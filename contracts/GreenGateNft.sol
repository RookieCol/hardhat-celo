// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "erc721a/contracts/ERC721A.sol";

contract GreenGate is ERC721A {
    uint256 private maxSupply; 

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply     
        ) ERC721A(name, symbol) {
        maxSupply = _maxSupply;
    }

    function mint(uint256 quantity) external payable {
        require(totalSupply() + quantity <= maxSupply, "There is not tickets left");
        _mint(msg.sender, quantity);
    }

    function remainingSupply() external view returns (uint256) {
        return maxSupply - totalSupply();
    }

}
