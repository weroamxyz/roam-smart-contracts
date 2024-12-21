/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.28;

import { INftMigrator } from "./interfaces/INftMigrator.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title NftMigrator
 * @dev NftMigrator is a contract for migrating NFTs from Ethereum to Solana.
 */
contract NftMigrator is INftMigrator, Pausable, Ownable {
    using Address for address;
    address public immutable override nftAddress;

    constructor(address nftAddress_) Ownable(_msgSender()) {
        if (!IERC165(nftAddress_).supportsInterface(type(IERC721).interfaceId)) {
            revert NotNftContract();
        }
        nftAddress = nftAddress_;
    }

    /**
     * @dev Migrate NFTs from Ethereum to Solana.
     * @param tokenIds Array of token IDs to migrate.
     * @param solanaAddress Solana address to receive the NFTs.
     * Emits a {NftBurned} event.
     */
    function migrate(uint256[] calldata tokenIds, bytes32 solanaAddress) external override whenNotPaused {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(nftAddress).safeTransferFrom(_msgSender(), address(0x0), tokenIds[i]);
            emit NftBurned(_msgSender(), tokenIds[i], solanaAddress);
        }
    }

    /**
     * @dev Pause the contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }
}
