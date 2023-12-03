// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC721A, ERC721A} from "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error PriceNotMet(address nftAddress, uint256 price);
// error ItemNotForSale(address nftAddress);
error NotListed(address nftAddress);
error AlreadyListed(address nftAddress);
error NoBalance();
// error NotOwner();
// error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => Listing) private listings;
    mapping(address => uint256) private balances;

    modifier notListed(address nftContractAddress) {
        Listing memory listing = listings[nftContractAddress];
        if (listing.price > 0) {
            revert AlreadyListed(nftContractAddress);
        }
        _;
    }

    modifier isListed(address nftContractAddress) {
        Listing memory listing = listings[nftContractAddress];
        if (listing.price <= 0) {
            revert NotListed(nftContractAddress);
        }
        _;
    }

    event NFTListed(
        address indexed nftContract,
        address indexed seller,
        uint256 price
    );
    event NFTListingCanceled(
        address indexed seller,
        address indexed nftAddress
    );
    event NFTPurchased(
        address indexed nftContract,
        address indexed buyer,
        uint256 price
    );

    function listNFT(
        address nftContractAddress,
        uint256 price
    ) external notListed(nftContractAddress) {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }

        IERC721A nft = IERC721A(nftContractAddress);
        listings[nftContractAddress] = Listing(msg.sender, price);

        emit NFTListed(nftContractAddress, tokenId, msg.sender, price);
    }

    function cancelListing(
        address nftContractAddress
    ) external isListed(nftContractAddress) {
        delete (listings[nftContractAddress]);
        emit NFTListingCanceled(msg.sender, nftContractAddress);
    }

    function updateListing(
        address nftContractAddress,
        uint256 newPrice
    ) external isListed(nftContractAddress) nonReentrant {
        if (newPrice == 0) {
            revert PriceMustBeAboveZero();
        }

        listings[nftContractAddress].price = newPrice;
        emit NFTListed(nftContractAddress, msg.sender, newPrice);
    }

    function purchaseNft(
        address nftContractAddress,
        uint256 quantity
    ) external payable isListed(nftContractAddress) nonReentrant {
        Listing memory listedNft = listings[nftContractAddress];

        IERC721A nft = IERC721A(nftContractAddress);
        uint256 remainingSupply = nft.remainingSupply();

        if (remainingSupply == uint256(0)) {
            revert NoTokensRemaning(nfContractAddress);
        }

        if (quantity > remainingSupply) {
            revert NoTokensRemaining(nfContractAddress);
        }

        uint256 amountOfPurchase = uint256();

        if (msg.value < listedNft.price) {
            revert PriceNotMet(nftContractAddress, listedNft.price);
        }

        balances[listedNft.seller] += msg.value;

        nft.mint(quantity, msg.sender);

        emit NFTPurchased(nftContractAddress, msg.sender, listedNft.price);
    }

    function withdrawFunds() external {
        uint256 balance = balances[msg.sender];
        if (balance <= 0) {
            revert NoBalance();
        }

        balances[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");
    }

    function getListing(
        address nftContractAddress
    )
        external
        view
        returns (
            // uint256 tokenId
            Listing memory
        )
    {
        return listings[nftContractAddress];
    }

    function getBalances(address seller) external view returns (uint256) {
        return balances[seller];
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
