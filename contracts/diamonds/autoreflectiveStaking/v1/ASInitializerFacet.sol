// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./interfaces/IASInitializerFacet.sol";
import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";

contract ASInitializerFacet is BaseFacet, IASInitializerFacet {
    function initialize(address owner) external override {
        InitializerLib.initialize();
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);

        ASLib.Primitives storage p = ASLib.get().p;
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
    }
}