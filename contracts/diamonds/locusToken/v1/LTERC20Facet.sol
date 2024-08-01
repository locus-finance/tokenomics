// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import "./autocracy/libraries/AutocracyLib.sol";
import "../LTLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILTERC20Facet.sol";

/// @title This contract provides ERC20 functionality with additional features like capped supply, voting.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LTERC20Facet is
    BaseFacet,
    ILTERC20Facet,
    ERC20CappedUpgradeable,
    ERC20VotesUpgradeable
{
    /// @inheritdoc ILTERC20Facet
    function setupTokenInfo() external override initializer internalOnly {
        __ERC20_init(LTLib.originalName, LTLib.originalSymbol);
        __ERC20Capped_init(LTLib.INITIAL_SUPPLY);
        __ERC20Permit_init(LTLib.originalName);
        __ERC20Votes_init();
    }

    /// @inheritdoc ILTERC20Facet
    function mintTo(
        address account,
        uint256 amount
    ) external override internalOnly {
        _mint(account, amount);
    }

    /// @inheritdoc ILTERC20Facet
    function burnFrom(
        address account,
        uint256 amount
    ) external override internalOnly {
        _burn(account, amount);
    }

    /// @inheritdoc ERC20Upgradeable
    /// @notice Spends the allowance of an owner for a spender.
    /// @dev If the spender has the `ALLOWANCE_FREE_ROLE`, the allowance is not spent.
    /// @param owner The address of the token owner.
    /// @param spender The address of the spender.
    /// @param value The amount of tokens to spend.
    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal override {
        if (!RolesManagementLib.hasRole(spender, LTLib.ALLOWANCE_FREE_ROLE)) {
            super._spendAllowance(owner, spender, value);
        }
    }

    /// @notice Delegates votes from the sender to a delegatee.
    /// @dev Checks autocracy status and enforces the `AUTOCRAT_ROLE` for both the account and the delegatee if autocracy is enabled.
    /// @param account The address delegating votes.
    /// @param delegatee The address receiving the delegated votes.
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

    /// @inheritdoc ILTERC20Facet
    function delegateTo(address delegatee) external override delegatedOnly {
        delegate(delegatee);
    }

    /// @inheritdoc ILTERC20Facet
    function getDelegatee(
        address account
    ) external view override delegatedOnly returns (address) {
        return delegates(account);
    }

    /// @inheritdoc ILTERC20Facet
    function enablePolitics() external override delegatedOnly {
        delegate(msg.sender);
    }

    /// @inheritdoc ILTERC20Facet
    function getVotingPower(
        address account
    ) external view override delegatedOnly returns (uint256) {
        return getVotes(account);
    }

    /// @inheritdoc ILTERC20Facet
    function getPastVotingPower(
        address account,
        uint256 timepoint
    ) external view override delegatedOnly returns (uint256) {
        return getPastVotes(account, timepoint);
    }

    /// @inheritdoc ERC20CappedUpgradeable
    /// @notice Mints new tokens to a specified account, respecting the capped supply limit.
    /// @param account The address to receive the minted tokens.
    /// @param amount The amount of tokens to mint.
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

    /// @inheritdoc ERC20VotesUpgradeable
    /// @notice Burns tokens from a specified account.
    /// @param account The address from which tokens will be burned.
    /// @param amount The amount of tokens to burn.
    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._burn(account, amount);
    }

    /// @inheritdoc ERC20VotesUpgradeable
    /// @notice Handles actions after token transfers, including updating vote counts.
    /// @param from The address tokens are transferred from.
    /// @param to The address tokens are transferred to.
    /// @param amount The amount of tokens transferred.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        super._afterTokenTransfer(from, to, amount);
    }
}
