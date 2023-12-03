// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "erc721a/contracts/ERC721A.sol";

contract GreenGate is ERC721A {
    uint256 private maxSupply;
    address private beneficiary;
    address addressMarket;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        address _beneficiary,
        address _addressMarket
    ) ERC721A(name, symbol) {
        maxSupply = _maxSupply;
        beneficiary = _beneficiary;
        addressMarket = _addressMarket;
    }

    function mint(uint256 quantity, address to) external {
        require(addressMarket == msg.sender, "Should call owner");
        require(
            totalSupply() + quantity <= maxSupply,
            "There is not tickets left"
        );
        _mint(to, quantity);
    }

    function remainingSupply() public view returns (uint256) {
        return maxSupply - totalSupply();
    }

    function getBeneficiary() public view returns (address) {
        return address(beneficiary);
    }
}
