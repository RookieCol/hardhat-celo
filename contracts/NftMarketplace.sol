// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IGreenGateNft.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

error PriceNotMet(address nftAddress, uint256 price);
error NotListed(address nftAddress);
error AlreadyListed(address nftAddress);
error NoBalance();
error PriceMustBeAboveZero();
error NoTokensRemaining(address nftAddress);

contract GreenGateNftMarketplace is ReentrancyGuard {
    using Math for uint256;

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

        listings[nftContractAddress] = Listing(msg.sender, price);

        emit NFTListed(nftContractAddress, msg.sender, price);
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

        IGreenGateNft nft = IGreenGateNft(nftContractAddress);
        uint256 remainingSupply = nft.remainingSupply();

        if (remainingSupply == uint256(0) || quantity > remainingSupply) {
            revert NoTokensRemaining(nftContractAddress);
        }

        (, uint256 requiredPrice) = quantity.tryMul(listedNft.price);
        (, uint256 amountOfPurchase) = quantity.tryMul(msg.value);

        if (amountOfPurchase != requiredPrice) {
            revert PriceNotMet(nftContractAddress, requiredPrice);
        }

        balances[listedNft.seller] += amountOfPurchase;

        nft.mint(quantity, msg.sender);

        emit NFTPurchased(nftContractAddress, msg.sender, requiredPrice);
    }

    function withdrawFunds() external {
        uint256 balance = balances[msg.sender];
        if (balance <= 0) {
            revert NoBalance();
        }

        (, uint256 sellerPercentage) = uint256(80).tryDiv(100);
        (, uint256 amountForSeller) = balance.tryMul(sellerPercentage);
        (, uint256 amountToStake) = balance.trySub(amountForSeller);

        balances[msg.sender] = 0;

        (bool success1, ) = payable(msg.sender).call{value: amountForSeller}(
            ""
        );
        require(success1, "Transfer 1 failed");

        // ! IMPORTANT: THIS CODE IS PROVITIONAL

        (bool success2, ) = payable(address(this)).call{value: amountToStake}(
            ""
        );
        require(success2, "Transfer failed");
    }

    function getListing(
        address nftContractAddress
    ) external view returns (Listing memory) {
        return listings[nftContractAddress];
    }

    function getBalances(address seller) external view returns (uint256) {
        return balances[seller];
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
