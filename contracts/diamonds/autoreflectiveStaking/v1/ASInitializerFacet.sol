// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IASInitializerFacet.sol";
import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract ASInitializerFacet is BaseFacet, IASInitializerFacet {
    function initialize(address owner, uint256 initialRewardAmount) external override {
        InitializerLib.initialize();
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);

        ASLib.Primitives storage p = ASLib.get().p;
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;

        p.tTotal = initialRewardAmount;
        p.rTotal = type(uint256).max - (type(uint256).max % initialRewardAmount);

        p.name = string(abi.encodePacked(ASLib.NAME_PREFIX, " via autoreflection"));
        p.symbol = string(abi.encodePacked(ASLib.SYMBOL_PREFIX, "LOCUS"));
        p.decimals = 18;

        rt.rOwned[address(this)] = p.rTotal;
    }
}
