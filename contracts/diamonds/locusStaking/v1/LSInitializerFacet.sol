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

contract LSInitializerFacet is BaseFacet, ILSInitializerFacet {
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

    function prepareDepositary() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        // WARNING: CONTAINS INITIALIZER CUSTOM MODIFIER, SO IT COULDN'T BE CALLED TWICE.
        ILSDepositaryFacet(address(this))._initialize_LSDepositaryFacet();
    }

    function setWrappedStakingLocus(
        address wrappedStLocusToken
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        LSLib.get().p.wrappedStLocusToken = wrappedStLocusToken;
    }

    function migrateBalances(
        address[] memory users,
        address autoreflectiveStaking,
        uint256 startOffset
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        LSLib.get().p.areDepositsShut = true;
        for (uint256 i = startOffset; i < users.length; i++) {
            _migrateUser(users[i], autoreflectiveStaking);
            emit LSLib.MigrationComplete(users[i], i);
        }
    }

    function _migrateUser(address user, address autoreflectiveStaking) internal {
        LSLib.ReferenceTypes storage rt = LSLib.get().rt;
        ILSGeneralDepositaryFacet(address(this)).updateReward(user);
        // calc amount to me sent: rewards + deposit
        uint256 amountToMigrate = rt.rewards[user] + rt.balanceOf[user];
        // zero deposit and rewards and the tail
        rt.rewards[user] = 0;
        rt.balanceOf[user] = 0;
        rt.userRewardPerTokenPaid[user] = 0;
        // stake in the new one
        IASInitializerFacet(autoreflectiveStaking).migrateBalance(
            user,
            amountToMigrate
        );
    }
}
