// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721A, ERC721A} from "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NoBalance();
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) private listings;
    mapping(address => uint256) private balances;

    modifier notListed(
        address nftContractAddress,
        uint256 tokenId,
        address owner
    ) {
        Listing memory listing = listings[nftContractAddress][tokenId];
        if (listing.price > 0) {
            revert AlreadyListed(nftContractAddress, tokenId);
        }
        _;
    }

    modifier isListed(address nftContractAddress, uint256 tokenId) {
        Listing memory listing = listings[nftContractAddress][tokenId];
        if (listing.price <= 0) {
            revert NotListed(nftContractAddress, tokenId);
        }
        _;
    }

    modifier isOwner(
        address nftContractAddress,
        uint256 tokenId,
        address spender
    ) {
        IERC721A nft = IERC721A(nftContractAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NotOwner();
        }
        _;
    }

    event NFTListed(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event NFTListingCanceled(
        address indexed seller,
        address indexed nftAddress,
        uint256 tokenId
    );
    event NFTPurchased(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price
    );

    function listNFT(
        address nftContractAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        notListed(nftContractAddress, tokenId, msg.sender)
        isOwner(nftContractAddress, tokenId, msg.sender)
    {
        if (price <= 0) {
            revert PriceMustBeAboveZero();
        }

        IERC721A nft = IERC721A(nftContractAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        listings[nftContractAddress][tokenId] = Listing(msg.sender, price);
        emit NFTListed(nftContractAddress, tokenId, msg.sender, price);
    }

    function cancelListing(
        address nftContractAddress,
        uint256 tokenId
    )
        external
        isOwner(nftContractAddress, tokenId, msg.sender)
        isListed(nftContractAddress, tokenId)
    {
        delete (listings[nftContractAddress][tokenId]);
        emit NFTListingCanceled(msg.sender, nftContractAddress, tokenId);
    }

    function updateListing(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newPrice
    )
        external
        isListed(nftContractAddress, tokenId)
        nonReentrant
        isOwner(nftContractAddress, tokenId, msg.sender)
    {
        if (newPrice == 0) {
            revert PriceMustBeAboveZero();
        }

        listings[nftContractAddress][tokenId].price = newPrice;
        emit NFTListed(msg.sender, nftContractAddress, tokenId, newPrice);
    }

    function purchaseNft(
        address nftContractAddress,
        uint256 tokenId
    ) external payable isListed(nftContractAddress, tokenId) nonReentrant {
        Listing memory listedNft = listings[nftContractAddress][tokenId];
        if (msg.value < listedNft.price) {
            revert PriceNotMet(nftContractAddress, tokenId, listedNft.price);
        }

        balances[listedNft.seller] += msg.value;
        delete (listings[nftContractAddress][tokenId]);
        IERC721A(nftContractAddress).safeTransferFrom(
            listedNft.seller,
            msg.sender,
            tokenId
        );
        emit NFTPurchased(
            nftContractAddress,
            tokenId,
            msg.sender,
            listedNft.price
        );
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
        address nftContractAddress,
        uint256 tokenId
    ) external view returns (Listing memory) {
        return listings[nftContractAddress][tokenId];
    }

    function getBalances(address seller) external view returns (uint256) {
        return balances[seller];
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
