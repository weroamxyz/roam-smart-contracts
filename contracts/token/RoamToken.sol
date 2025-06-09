// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { INttToken } from "../interfaces/INttToken.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Nonces } from "@openzeppelin/contracts/utils/Nonces.sol";

/// @custom:security-contact xxxx@gmail.com
contract RoamToken is ERC20, ERC20Burnable, ERC20Permit, ERC20Votes, INttToken, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000_000e6;
    address public minter;

    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert CallerNotMinter(msg.sender);
        }
        _;
    }
    constructor(
        string memory name_,
        string memory symbol_,
        address owner_,
        address minter_
    ) ERC20(name_, symbol_) ERC20Permit(name_) Ownable(owner_) {
        minter = minter_;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * Override to return 6 instead of the default 18
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) public onlyMinter {
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

    function _update(address _from, address _to, uint256 _value) internal override(ERC20, ERC20Votes) {
        return ERC20Votes._update(_from, _to, _value);
    }

    function nonces(address _owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return Nonces.nonces(_owner);
    }
}
