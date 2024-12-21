// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721Burnable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

contract RoamNFT is ERC721Enumerable, ERC721Burnable, Pausable, Ownable {
    using Address for address;

    uint256 public immutable maxSupply;
    uint256 private _tokenIdOffset = 0;
    string private _metaBaseURI;

    error MintingExceedsMaxSupply();

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 maxSupply_
    ) ERC721(name_, symbol_) Ownable(_msgSender()) {
        _metaBaseURI = baseURI_;
        maxSupply = maxSupply_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMintBatch(address to, uint256 amount) public onlyOwner {
        if (_tokenIdOffset + amount > maxSupply) {
            revert MintingExceedsMaxSupply();
        }
        for (uint256 i = 0; i < amount; i++) {
            _tokenIdOffset++;
            super._safeMint(to, _tokenIdOffset);
        }
    }

    function changeBaseURI(string calldata newBaseURI) public onlyOwner {
        _metaBaseURI = newBaseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _metaBaseURI;
    }
}
