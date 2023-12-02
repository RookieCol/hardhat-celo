// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "erc721a/contracts/ERC721A.sol";

contract GreenGate is ERC721A {
    constructor() ERC721A("GreenGate", "GGT") {}

    function mint(uint256 quantity) external payable {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(msg.sender, quantity);
    }
}
