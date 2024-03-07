// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import "./autocracy/libraries/AutocracyLib.sol";
import "../LTLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILTERC20Facet.sol";

contract LTERC20Facet is
    BaseFacet,
    ILTERC20Facet,
    ERC20CappedUpgradeable,
    ERC20VotesUpgradeable
{
    function setupTokenInfo() external override initializer internalOnly {
        __ERC20_init(LTLib.originalName, LTLib.originalSymbol);
        __ERC20Capped_init(LTLib.INITIAL_SUPPLY);
        __ERC20Permit_init(LTLib.originalName);
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

    function _delegate(address account, address delegatee) internal override {
        if (AutocracyLib.get().isAutocracyEnabled) {
            RolesManagementLib.enforceRole(account, AutocracyLib.AUTOCRAT_ROLE);
            RolesManagementLib.enforceRole(
                delegatee,
                AutocracyLib.AUTOCRAT_ROLE
            );
        }
        super._delegate(account, delegatee);
    }

    function delegateTo(address delegatee) external override delegatedOnly {
        delegate(delegatee);
    }

    function getDelegatee(
        address account
    ) external view override delegatedOnly returns (address) {
        return delegates(account);
    }

    /// @inheritdoc ILTERC20Facet
    function enablePolitics() external override delegatedOnly {
        delegate(msg.sender);
    }

    function getVotingPower(
        address account
    ) external view override delegatedOnly returns (uint256) {
        return getVotes(account);
    }

    function getPastVotingPower(
        address account,
        uint256 timepoint
    ) external view override delegatedOnly returns (uint256) {
        return getPastVotes(account, timepoint);
    }

    function _mint(
        address account,
        uint256 amount
    )
        internal
        override(
            ERC20CappedUpgradeable,
            ERC20VotesUpgradeable
        )
    {
        super._mint(account, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
        require(false, "transfers stopped.");
    }
}
