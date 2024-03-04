// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IASInitializerFacet.sol";
import "./interfaces/IASEip20Facet.sol";
import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract ASInitializerFacet is BaseFacet, IASInitializerFacet {
    using SafeERC20 for IERC20;

    function initialize(
        address owner,
        address stakingToken,
        address rewardToken
    ) external override {
        InitializerLib.initialize();
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        ASLib.Primitives storage p = ASLib.get().p;
        p.rewardToken = rewardToken;
        p.stakingToken = stakingToken;
        p.name = string(
            abi.encodePacked(ASLib.NAME_PREFIX, " via autoreflection")
        );
        p.symbol = string(abi.encodePacked(ASLib.SYMBOL_PREFIX, "LOCUS"));
        p.decimals = 18;
    }
}
