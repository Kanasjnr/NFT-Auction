// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTAuction is ReentrancyGuard {
    using SafeMath for uint256;

    struct Auction {
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 minBid;
        uint256 highestBid;
        address payable highestBidder;
        uint256 startTime;
        uint256 endTime;
        bool ended;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) public bids;
    uint256 public auctionCounter;

    event AuctionCreated(uint256 auctionId, address nftContract, uint256 tokenId, uint256 minBid, uint256 startTime, uint256 endTime);
    event BidPlaced(uint256 auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);
    event Withdrawal(address bidder, uint256 amount);

    modifier onlySeller(uint256 _auctionId) {
        require(msg.sender == auctions[_auctionId].seller, "Only the seller can call this function");
        _;
    }

    modifier auctionExists(uint256 _auctionId) {
        require(_auctionId < auctionCounter, "Auction does not exist");
        _;
    }

    modifier auctionActive(uint256 _auctionId) {
        require(block.timestamp >= auctions[_auctionId].startTime, "Auction has not started yet");
        require(block.timestamp < auctions[_auctionId].endTime, "Auction has ended");
        require(!auctions[_auctionId].ended, "Auction has already been ended");
        _;
    }

    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _minBid,
        uint256 _startTime,
        uint256 _endTime
    ) external {
        require(_startTime > block.timestamp, "Start time must be in the future");
        require(_endTime > _startTime, "End time must be after start time");
        require(_minBid > 0, "Minimum bid must be greater than zero");

        IERC721 nftContract = IERC721(_nftContract);
        require(nftContract.ownerOf(_tokenId) == msg.sender, "You must own the NFT to auction it");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Contract must be approved to transfer the NFT");

        uint256 auctionId = auctionCounter;
        auctions[auctionId] = Auction({
            nftContract: _nftContract,
            tokenId: _tokenId,
            seller: payable(msg.sender),
            minBid: _minBid,
            highestBid: 0,
            highestBidder: payable(address(0)),
            startTime: _startTime,
            endTime: _endTime,
            ended: false
        });

        auctionCounter = auctionCounter.add(1);

        nftContract.transferFrom(msg.sender, address(this), _tokenId);

        emit AuctionCreated(auctionId, _nftContract, _tokenId, _minBid, _startTime, _endTime);
    }

    function placeBid(uint256 _auctionId) external payable nonReentrant auctionExists(_auctionId) auctionActive(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(msg.value >= auction.minBid, "Bid must be at least the minimum bid amount");
        require(msg.value > auction.highestBid, "Bid must be higher than the current highest bid");

        address payable previousHighestBidder = auction.highestBidder;
        uint256 previousHighestBid = auction.highestBid;

        auction.highestBidder = payable(msg.sender);
        auction.highestBid = msg.value;

        bids[_auctionId][msg.sender] = bids[_auctionId][msg.sender].add(msg.value);

        if (previousHighestBidder != address(0)) {
            bids[_auctionId][previousHighestBidder] = bids[_auctionId][previousHighestBidder].add(previousHighestBid);
        }

        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    function endAuction(uint256 _auctionId) external nonReentrant auctionExists(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.endTime || msg.sender == auction.seller, "Auction cannot be ended yet");
        require(!auction.ended, "Auction has already ended");

        auction.ended = true;

        if (auction.highestBidder != address(0)) {
            IERC721(auction.nftContract).transferFrom(address(this), auction.highestBidder, auction.tokenId);
            auction.seller.transfer(auction.highestBid);
        } else {
            IERC721(auction.nftContract).transferFrom(address(this), auction.seller, auction.tokenId);
        }

        emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
    }

    function withdraw(uint256 _auctionId) external nonReentrant auctionExists(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(auction.ended, "Auction has not ended yet");
        require(msg.sender != auction.highestBidder, "Winner cannot withdraw");

        uint256 amount = bids[_auctionId][msg.sender];
        require(amount > 0, "No funds to withdraw");

        bids[_auctionId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getAuctionDetails(uint256 _auctionId) external view auctionExists(_auctionId) returns (
        address nftContract,
        uint256 tokenId,
        address seller,
        uint256 minBid,
        uint256 highestBid,
        address highestBidder,
        uint256 startTime,
        uint256 endTime,
        bool ended
    ) {
        Auction storage auction = auctions[_auctionId];
        return (
            auction.nftContract,
            auction.tokenId,
            auction.seller,
            auction.minBid,
            auction.highestBid,
            auction.highestBidder,
            auction.startTime,
            auction.endTime,
            auction.ended
        );
    }
}