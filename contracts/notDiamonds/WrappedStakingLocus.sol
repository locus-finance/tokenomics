// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "../diamonds/locusStaking/v1/interfaces/ILSLoupeFacet.sol";
import "./interfaces/IWrappedStakingLocus.sol";

contract WrappedStakingLocus is IWrappedStakingLocus, ERC20, ERC20Permit, ERC20Votes {
    event PoliticsEnabled(address indexed who);
    event PoliticsDisabled(address indexed who);

    error OnlyStakingDiamond();

    ILSLoupeFacet public locusStakingDiamond;
    IERC20Metadata public locusDiamond;

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

    function syncBalanceOnStake(address who) external override {
        if (_msgSender() == address(locusStakingDiamond)) {
            _syncBalanceOnStake(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    function syncBalanceOnWithdraw(address who) external override {
        if (_msgSender() == address(locusStakingDiamond)) {
            _syncBalanceOnWithdraw(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return string(abi.encodePacked(locusDiamond.name(), " with voting power"));
    }

    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return string(abi.encodePacked("st", locusDiamond.symbol()));
    }

    function decimals() public view override(ERC20, IERC20Metadata) returns (uint8) {
        return locusDiamond.decimals();
    }

    function _syncBalanceOnStake(address sender) internal {
        _mint(sender, locusStakingDiamond.balanceOf(sender) - balanceOf(sender));
        emit PoliticsEnabled(sender);
    }

    function _syncBalanceOnWithdraw(address sender) internal {
        _burn(sender, balanceOf(sender) - locusStakingDiamond.balanceOf(sender));
        emit PoliticsDisabled(sender);
    }

    function _mint(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
}