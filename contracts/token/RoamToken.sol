// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { INttToken } from "../interfaces/INttToken.sol";

/**
 * @title RoamToken
 * @dev Implementation of the Roam Token
 *
 * This contract implements a standard ERC20 token with additional features:
 * - Fixed maximum supply cap of 1 billion tokens (with 6 decimals)
 * - Minting restricted to a designated minter address
 * - Burning capability through ERC20Burnable
 * - Gasless approvals through ERC20Permit
 * - Ownership control through Ownable
 */
contract RoamToken is ERC20, ERC20Permit, ERC20Burnable, Ownable, INttToken {
    /**
     * @dev Maximum supply cap of 1 billion tokens (with 6 decimals)
     */
    uint256 public constant MAX_SUPPLY = 1_000_000_000e6;

    /**
     * @dev Address authorized to mint new tokens
     */
    address public minter;

    /**
     * @dev Error thrown when an attempt is made to exceed the maximum token supply
     * @param increasedSupply The supply that would result from the attempted operation
     * @param cap The maximum allowed supply
     */
    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);

    /**
     * @dev Modifier to restrict function access to the designated minter
     */
    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert CallerNotMinter(msg.sender);
        }
        _;
    }

    /**
     * @dev Constructor that initializes the token with name "Roam Token" and symbol "ROAM"
     * The deployer is set as the owner of the contract and initial minter
     */
    constructor() ERC20("Roam Token", "ROAM") ERC20Permit("Roam Token") Ownable(msg.sender) {}

    /**
     * @dev Returns the number of decimals used for token representation
     * @return The number of decimals (6 instead of the default 18)
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    /**
     * @dev Mints new tokens to the specified address
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     *
     * Requirements:
     * - The caller must be the designated minter
     * - The total supply after minting must not exceed MAX_SUPPLY
     */
    function mint(address to, uint256 amount) public onlyMinter {
        uint256 supply = totalSupply() + amount;
        if (supply > MAX_SUPPLY) {
            revert ERC20ExceededCap(supply, MAX_SUPPLY);
        }
        _mint(to, amount);
    }

    /**
     * @dev Changes the designated minter address
     * @param newMinter The address of the new minter
     *
     * Requirements:
     * - The caller must be the owner of the contract
     * - The new minter address cannot be the zero address
     *
     * Emits a {NewMinter} event
     */
    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) {
            revert InvalidMinterZeroAddress();
        }
        address oldMinter = minter;
        minter = newMinter;
        emit NewMinter(oldMinter, newMinter);
    }

    /**
     * @dev Burns a specific amount of the caller's tokens
     * @param value The amount of tokens to burn
     *
     * This function overrides both INttToken and ERC20Burnable implementations
     */
    function burn(uint256 value) public override(ERC20Burnable, INttToken) {
        super.burn(value);
    }
}
