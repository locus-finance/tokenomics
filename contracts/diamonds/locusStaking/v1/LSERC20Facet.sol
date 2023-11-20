// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract LSERC20Facet is BaseFacet, IERC20Metadata {
    function totalSupply() external view override delegatedOnly returns (uint256) {
        return LSLib.get().p.totalSupply;
    }

    function balanceOf(
        address account
    ) external view override delegatedOnly returns (uint256) {
        return LSLib.get().rt.balanceOf[account];
    }

    function transfer(
        address to,
        uint256 value
    ) external override delegatedOnly returns (bool) {
        revert LSLib.NotImplemented();
    }

    function allowance(
        address owner,
        address spender
    ) external view override delegatedOnly returns (uint256) {
        revert LSLib.NotImplemented();
    }

    function approve(
        address spender,
        uint256 value
    ) external override delegatedOnly returns (bool) {
        revert LSLib.NotImplemented();
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override delegatedOnly returns (bool) {
        revert LSLib.NotImplemented();
    }

    function name() external view override delegatedOnly returns (string memory) {
        return string(abi.encodePacked("Staking ", LSLib.get().p.stakingToken.name()));
    }

    function symbol() external view override delegatedOnly returns (string memory) {
        return string(abi.encodePacked("st", LSLib.get().p.stakingToken.symbol()));
    }

    function decimals() external view override delegatedOnly returns (uint8) {
        return LSLib.get().p.stakingToken.decimals();
    }
}
