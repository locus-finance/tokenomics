// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IASInitializerFacet.sol";
import "./interfaces/IASEip20Facet.sol";
import "./interfaces/IASReflectionFacet.sol";
import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../locusStaking/v2/manualWithdrawQueueFacets/libraries/DelayedSendingsQueueLib.sol";

/// @title A facet that implements all of the diamonds facets initialization. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract ASInitializerFacet is BaseFacet, IASInitializerFacet {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @inheritdoc IASInitializerFacet
    function initialize(
        address owner,
        address token
    ) external override {
        InitializerLib.initialize();
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);
        RolesManagementLib.grantRole(
            owner,
            ASLib.REWARD_DISTRIBUTOR_ROLE
        );
        RolesManagementLib.grantRole(
            owner,
            DelayedSendingsQueueLib.DELAYED_SENDINGS_QUEUE_PROCESSOR_ROLE
        );
        ASLib.Primitives storage p = ASLib.get().p;
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        
        p.token = token;
        p.name = string(
            abi.encodePacked(ASLib.NAME_PREFIX, " via autoreflection")
        );
        p.symbol = string(abi.encodePacked(ASLib.SYMBOL_PREFIX, "LOCUS"));
        p.decimals = 18;

        p.tTotal = 1_000_000_000_000_000 ether; // MAX RESERVE OF stLOCUS'
        p.rTotal = type(uint256).max - (type(uint256).max % p.tTotal);
        rt.excluded.add(address(this));
        rt.rOwned[address(this)] = p.rTotal; 
        rt.tOwned[address(this)] = p.tTotal;

        TDLib.get().undistributedAmountsReceiver = owner;
    }
}