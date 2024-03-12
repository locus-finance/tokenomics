// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeMath.sol";

import "./interfaces/ILTIncidentLiquidatorFacet.sol";
import "../../LTLib.sol";
import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../autocracy/libraries/AutocracyLib.sol";
import "../autocracy/interfaces/ILTAutocracyFacet.sol";
import "../../../autoreflectiveStaking/v1/interfaces/IASDepositaryFacet.sol";
import "../../../locusStaking/v1/interfaces/ILSInitializerFacet.sol";

contract LTIncidentLiquidatorFacet is BaseFacet, ILTIncidentLiquidatorFacet {
    using SafeMath for IERC20;

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        address[] calldata users,
        uint256[] calldata amounts
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        
        ILTAutocracyFacet selfAutocracy = ILTAutocracyFacet(address(this));
        IERC20 selfToken = IERC20(address(this));
        ILSInitializerFacet oldStakingInitializer = ILSInitializerFacet(oldStaking);
        IASDepositaryFacet autoreflectiveStakingDepositary = IASDepositaryFacet(autoreflectiveStaking);
        IERC20 autoreflectiveStakingERC20 = IERC20(autoreflectiveStaking);

        uint256 oldStakingBalance = selfToken.balanceOf(oldStaking);

        uint256 amountsLength = amounts.length;
        if (users.length != amountsLength) {
            revert MustBeEqual(users.length, amounts.length);
        }

        uint256 i;
        uint256 amountsSum;
        for (i; i < amountsLength; i++) {
            amountsSum += amounts[i];
        }
        if (amountsSum > oldStakingBalance) {
            revert MustBeLessThanOrEqualTo(amountsSum, oldStakingBalance);
        }

        selfAutocracy.burn(oldStaking, oldStakingBalance);
        selfAutocracy.mint(address(this), oldStakingBalance);

        i = 0;
        for (i; i < amountsLength; i++) {
            uint256 amount = amounts[i];
            address user = users[i];
            oldStakingBalance -= amount;
            oldStakingInitializer.liquidateIncidentForUser(user);
            selfToken.approve(autoreflectiveStaking, amount);
            autoreflectiveStakingDepositary.stake(amount);
            autoreflectiveStakingERC20.safeTransfer(user, amount);
            emit IncidentLiquidatedFor(user, amount);
        }

        if (oldStakingBalance > 0) {
            selfToken.approve(autoreflectiveStaking, oldStakingBalance);
            autoreflectiveStakingDepositary.stake(oldStakingBalance);
            autoreflectiveStakingERC20.safeTransfer(msg.sender, oldStakingBalance);
            emit RemainderSent(oldStakingBalance);
        }
    }
}
