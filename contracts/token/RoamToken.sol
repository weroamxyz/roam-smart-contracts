// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { INttToken } from "../interfaces/INttToken.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract RoamToken is ERC20, ERC20Burnable, ERC20Permit, INttToken, Ownable {
    uint256 public constant MAX_SUPPLY = 1_000_000_000e6;
    address public minter;
    /**
     * @dev Total supply cap has been exceeded.
     */
    error ERC20ExceededCap(uint256 increasedSupply, uint256 cap);

    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert CallerNotMinter(msg.sender);
        }
        _;
    }
    constructor() ERC20("Roam Token", "ROAM") ERC20Permit("Roam Token") Ownable(msg.sender) {}

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * Override to return 6 instead of the default 18
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        uint256 supply = totalSupply() + amount;
        if (supply > MAX_SUPPLY) {
            revert ERC20ExceededCap(supply, MAX_SUPPLY);
        }
        _mint(to, amount);
    }

    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) {
            revert InvalidMinterZeroAddress();
        }
        address oldMinter = minter;
        minter = newMinter;
        emit NewMinter(oldMinter, newMinter);
    }

    function burn(uint256 value) public override(INttToken, ERC20Burnable) {
        super.burn(value);
    }
}
