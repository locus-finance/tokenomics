// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "../diamonds/locusStaking/v1/interfaces/ILSLoupeFacet.sol";
import "./interfaces/IWrappedStakingLocus.sol";

/// @title This contract wraps deposit of `locusStaking` and provides voting power using the ERC20Votes extension.
/// @notice A wrapper token for deposit of `locusStaking` with voting power.
contract WrappedStakingLocus is IWrappedStakingLocus, ERC20, ERC20Permit, ERC20Votes {
    /// @notice Emits when voting power is enabled for an address.
    /// @param who The address for which voting power is enabled.
    event PoliticsEnabled(address indexed who);

    /// @notice Emits when voting power is disabled for an address.
    /// @param who The address for which voting power is disabled.
    event PoliticsDisabled(address indexed who);

    /// @notice Emits when the voting power remains unchanged for an address.
    /// @param who The address for which the voting power remains unchanged.
    event PoliticsRemainedUnchanged(address indexed who);

    /// @notice Thrown when a function is called by an unauthorized address.
    error OnlyStakingDiamond();

    /// @notice The Locus staking diamond contract.
    ILSLoupeFacet public locusStakingDiamond;

    /// @notice The underlying ERC20 token for the Locus diamond.
    IERC20Metadata public locusDiamond;

    /// @notice Initializes the WrappedStakingLocus contract.
    /// @param _locusStakingDiamond The address of the Locus staking diamond contract.
    /// @param _locusDiamond The address of the Locus diamond token contract.
    constructor(
        ILSLoupeFacet _locusStakingDiamond,
        IERC20Metadata _locusDiamond
    ) 
        ERC20("", "") 
        ERC20Permit("vstLOCUSDomainSeparator") 
    {
        locusStakingDiamond = _locusStakingDiamond;
        locusDiamond = _locusDiamond;
    }

    /// @inheritdoc IWrappedStakingLocus
    function syncBalanceOnStake(address who) external override {
        if (_msgSender() == address(locusStakingDiamond)) {
            _syncBalanceOnStake(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    /// @inheritdoc IWrappedStakingLocus
    function syncBalanceOnWithdraw(address who) external override {
        if (_msgSender() == address(locusStakingDiamond)) {
            _syncBalanceOnWithdraw(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    /// @inheritdoc IERC20Metadata
    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return string(abi.encodePacked(locusDiamond.name(), " with voting power"));
    }

    /// @inheritdoc IERC20Metadata
    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return string(abi.encodePacked("st", locusDiamond.symbol()));
    }

    /// @inheritdoc IERC20Metadata
    function decimals() public view override(ERC20, IERC20Metadata) returns (uint8) {
        return locusDiamond.decimals();
    }

    /// @notice Internal function to sync the wrapped token balance on stake.
    /// @param sender The address of the user.
    function _syncBalanceOnStake(address sender) internal {
        uint256 locusStakingBalance = locusStakingDiamond.balanceOf(sender);
        uint256 wrappedBalance = balanceOf(sender);  
        if (locusStakingBalance > wrappedBalance) {
            _mint(sender, locusStakingBalance - wrappedBalance);
            emit PoliticsEnabled(sender);
        } else {
            emit PoliticsRemainedUnchanged(sender);
        }
    }

    /// @notice Internal function to sync the wrapped token balance on withdraw.
    /// @param sender The address of the user.
    function _syncBalanceOnWithdraw(address sender) internal {
        uint256 wrappedBalance = balanceOf(sender);
        uint256 locusStakingBalance = locusStakingDiamond.balanceOf(sender);
        if (wrappedBalance > locusStakingBalance) {
            _burn(sender, wrappedBalance - locusStakingBalance);
            emit PoliticsDisabled(sender);
        } else {
            emit PoliticsRemainedUnchanged(sender);
        }
    }

    /// @notice Internal function to mint wrapped tokens.
    /// @param account The address of the account to receive the tokens.
    /// @param amount The amount of tokens to mint.
    function _mint(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(account, amount);
    }

    /// @notice Internal function to burn wrapped tokens.
    /// @param account The address of the account whose tokens are to be burned.
    /// @param amount The amount of tokens to burn.
    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    /// @notice Internal function to handle token transfers.
    /// @param from The address of the sender.
    /// @param to The address of the recipient.
    /// @param amount The amount of tokens to transfer.
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
}