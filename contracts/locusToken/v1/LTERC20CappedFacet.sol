// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";

import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILTERC20CappedFacet.sol";

contract LTERC20CappedFacet is
    BaseFacet,
    ERC20CappedUpgradeable,
    ILTERC20CappedFacet
{
    function _init_ERC20CappedFacet() external override internalOnly {
        __ERC20_init(LTLib.name, LTLib.symbol);
        __ERC20Capped_init(LTLib.INITIAL_SUPPLY);
    }

    function mintTo(
        address account,
        uint256 amount
    ) external override internalOnly {
        _mint(account, amount);
    }

    function burnFrom(
        address account,
        uint256 amount
    ) external override internalOnly {
        _burn(account, amount);
    }

    /// @inheritdoc ERC20Upgradeable
    function _spendAllowance(address owner, address spender, uint256 value) internal override {
        if (!RolesManagementLib.hasRole(spender, LTLib.ALLOWANCE_FREE_ROLE)) {
            super._spendAllowance(owner, spender, value);
        } 
    }

    /// @inheritdoc ERC20Upgradeable
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        enforceDelegatedOnly();
        super._update(from, to, value);
    }
}
