# NFTAuction Smart Contract

## Description

NFTAuction is a Solidity smart contract that enables decentralized auctions for ERC721 Non-Fungible Tokens (NFTs). This contract allows NFT owners to create auctions, users to place bids, and automatically handles the transfer of NFTs and ETH upon auction completion.


## Features

- Create auctions for ERC721 NFTs
- Place bids with ETH
- Automatic refunds for outbid participants
- Secure auction closure and NFT transfer
- Withdrawal mechanism for losing bidders
- Reentrancy protection
- Auction management (start time, end time, minimum bid)

## Prerequisites

- Solidity ^0.8.20
- OpenZeppelin Contracts library
- Ethereum development environment (e.g., Hardhat, Truffle, or Remix)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/nft-auction.git
   cd nft-auction
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Compile the contract:
   ```bash
   npx hardhat compile
   ```

## Usage

1. Deploy the NFTAuction contract to an Ethereum network (local, testnet, or mainnet).
2. Interact with the contract using a web3 library like ethers.js or web3.js, or through a frontend application.

## Contract Functions

1. `createAuction(address _nftContract, uint256 _tokenId, uint256 _minBid, uint256 _startTime, uint256 _endTime)`
   - Creates a new auction for an NFT.

2. `placeBid(uint256 _auctionId)`
   - Places a bid on an active auction.

3. `endAuction(uint256 _auctionId)`
   - Ends an auction, transferring the NFT to the highest bidder and ETH to the seller.

4. `withdraw(uint256 _auctionId)`
   - Allows losing bidders to withdraw their bid amounts after the auction ends.

5. `getAuctionDetails(uint256 _auctionId)`
   - Returns the details of a specific auction.

## Events

- `AuctionCreated(uint256 auctionId, address nftContract, uint256 tokenId, uint256 minBid, uint256 startTime, uint256 endTime)`
- `BidPlaced(uint256 auctionId, address bidder, uint256 amount)`
- `AuctionEnded(uint256 auctionId, address winner, uint256 amount)`
- `Withdrawal(address bidder, uint256 amount)`

## Security Considerations

- The contract uses OpenZeppelin's `ReentrancyGuard` to protect against reentrancy attacks.
- Ensure that the ERC721 contract approves this auction contract before creating an auction.
- Always interact with this contract using a secure Ethereum wallet and on a network you trust.

## Testing

To run the test suite:

```bash
npx hardhat test
```

Ensure you have a comprehensive test suite covering all contract functions and edge cases.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

Your Name - [Kanas Jnr](https://x.com/KanasJnr) - nasihudeen04@gmail.com



