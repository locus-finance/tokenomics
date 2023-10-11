// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";

import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/IERC20CappedFacet.sol";

contract ERC20CappedFacet is
    BaseFacet,
    ERC20CappedUpgradeable,
    IERC20CappedFacet
{
    function _init_ERC20CappedFacet() external override internalOnly {
        __ERC20_init(LTLib.name, LTLib.symbol);
        __ERC20Capped_init(LTLib.CAP);
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
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        enforceDelegatedOnly();
        super._update(from, to, value);
    }
}
