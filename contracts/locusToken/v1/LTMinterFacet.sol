// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/ILTEmissionControlFacet.sol";
import "./interfaces/ILTERC20CappedFacet.sol";
import "./interfaces/ILTMinterFacet.sol";
import "../../locusGauge/v1/interfaces/ILGCheckointFacet.sol";

contract LTMinterFacet is BaseFacet, ILTMinterFacet {
    // @notice Mint `_value` tokens and assign them to `_to`
    // @dev Emits a Transfer event originating from 0x00
    // @param _to The account that will receive the created tokens
    // @param _value The amount that will be created
    // @return bool success
    function _mint(address to, uint256 value) internal {
        LTLib.Primitives storage p = LTLib.get().p;
        ILTEmissionControlFacet self = ILTEmissionControlFacet(address(this));
        if (block.timestamp >= p.startEpochTime + LTLib.RATE_REDUCTION_TIME) {
            self.updateMiningParameters();
        }
        if (IERC20(address(this)).totalSupply() + value > self.availableSupply()) {
            revert LTLib.CannotMintMoreThenAvailableSupply();
        }
        ILTERC20CappedFacet(address(this)).mintTo(to, value);
    }

    function mintFor(address entity, address user) external override delegatedOnly {
        if (RolesManagementLib.hasRole(entity, LTLib.GAUGE_CONTRACT_ROLE)) {
            ILGCheckpointFacet gauge = ILGCheckpointFacet(entity);
            gauge.userCheckpoint(user);
            uint256 totalMintForUser = gauge.integrateFraction(user);
            uint256 toMint = totalMintForUser - LTLib.get().rt.mintedForUser[user][entity];
            if (toMint > 0) {
                _mint(user, toMint);
                LTLib.get().rt.mintedForUser[user][entity] = totalMintForUser;
                emit LTLib.MintedForGauge(user, entity, totalMintForUser);
            }
        }
        if (RolesManagementLib.hasRole(entity, LTLib.STAKING_CONTRACT_ROLE)) {
            revert InitializerLib.NotImplemented();
        }
        bytes32[] memory roles = new bytes32[](2);
        roles[0] = LTLib.STAKING_CONTRACT_ROLE;
        roles[1] = LTLib.GAUGE_CONTRACT_ROLE;
        revert RolesManagementLib.HasNoRoles(entity, roles);
    }
}