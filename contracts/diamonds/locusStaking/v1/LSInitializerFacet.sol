// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../LSLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../autoreflectiveStaking/v1/interfaces/IASInitializerFacet.sol";

import "./interfaces/ILSInitializerFacet.sol";
import "./interfaces/ILSDepositaryFacet.sol";
import "./interfaces/ILSGeneralDepositaryFacet.sol";

/// @title A facet that implements the diamond initalization.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LSInitializerFacet is BaseFacet, ILSInitializerFacet {
    /// @inheritdoc ILSInitializerFacet
    function initialize(
        address owner,
        address rewardDistributor,
        address rewardsToken,
        address stakingToken
    ) external override {
        InitializerLib.initialize();

        TDLib.Storage storage s = TDLib.get();
        s.undistributedAmountsReceiver = owner;

        RolesManagementLib.grantRole(
            rewardDistributor,
            LSLib.REWARD_DISTRIBUTOR_ROLE
        );
        RolesManagementLib.grantRole(owner, RolesManagementLib.OWNER_ROLE);

        LSLib.Primitives storage p = LSLib.get().p;
        p.rewardsToken = IERC20Metadata(rewardsToken);
        p.stakingToken = IERC20Metadata(stakingToken);
        p.rewardsDuration = 4 weeks;
    }

    /// @inheritdoc ILSInitializerFacet
    function prepareDepositary() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        // WARNING: CONTAINS INITIALIZER CUSTOM MODIFIER, SO IT COULDN'T BE CALLED TWICE.
        ILSDepositaryFacet(address(this))._initialize_LSDepositaryFacet();
    }

    /// @inheritdoc ILSInitializerFacet
    function setWrappedStakingLocus(
        address wrappedStLocusToken
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        LSLib.get().p.wrappedStLocusToken = wrappedStLocusToken;
    }
}
