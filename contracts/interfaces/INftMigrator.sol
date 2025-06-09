// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title INftMigrator
 * @dev This contract is used to migrate NFTs from Ethereum to Solana
 */
interface INftMigrator {
    event NftBurned(address indexed owner, uint256 indexed tokenId, bytes32 indexed solanaAddress);

    error NotNftContract();
    error NoNftToMigrate();

    /**
     * @dev Migrate NFTs from Ethereum to Solana
     * @param  tokenIds Array of token IDs to migrate
     * @param  solanaAddress Solana address to receive the NFTs
     */
    function migrate(uint256[] calldata tokenIds, bytes32 solanaAddress) external;
    /**
     * @dev Returns the address of the NFT contract
     */
    function nftAddress() external view returns (address);
}
