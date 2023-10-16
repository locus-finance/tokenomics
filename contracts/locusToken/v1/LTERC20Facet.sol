// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";


import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILTERC20Facet.sol";

contract LTERC20Facet is
    BaseFacet,
    ERC20CappedUpgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    ILTERC20Facet
{
    function _init_LTERC20Facet() external override internalOnly {
        __ERC20_init(LTLib.name, LTLib.symbol);
        __ERC20Capped_init(LTLib.INITIAL_SUPPLY);
        __ERC20Permit_init(LTLib.name);
        __ERC20Votes_init();
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
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal override {
        if (!RolesManagementLib.hasRole(spender, LTLib.ALLOWANCE_FREE_ROLE)) {
            super._spendAllowance(owner, spender, value);
        }
    }

    /// @inheritdoc ERC20Upgradeable
    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        virtual
        override(
            ERC20Upgradeable,
            ERC20CappedUpgradeable,
            ERC20VotesUpgradeable
        )
    {
        enforceDelegatedOnly();
        super._update(from, to, value);
    }

    /// @inheritdoc ERC20PermitUpgradeable
    function nonces(
        address owner
    )
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function delegateTo(address delegatee) external override {
        delegate(delegatee);
    }

    function getDelegatee(address account) external override view returns (address) {
        return delegates(account);
    }

    function enablePolitics() external override {
        delegate(msg.sender);
    }

    function getVotingPower(
        address account
    ) external view override returns (uint256) {
        return getVotes(account);
    }

    function getPastVotingPower(
        address account,
        uint256 timepoint
    ) external view override returns (uint256) {
        return getPastVotes(account, timepoint);
    }
}
