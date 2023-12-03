// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGreenGateNft {
    function mint(uint256 quantity, address to) external;

    function totalSupply() external view returns (uint256);

    function remainingSupply() external view returns (uint256);

    function getBeneficiary() external view returns (address);
}
