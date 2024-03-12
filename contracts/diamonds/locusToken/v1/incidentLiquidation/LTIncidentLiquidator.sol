// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILTIncidentLiquidatorFacet.sol";
import "../../LTLib.sol";
import "../../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../autocracy/libraries/AutocracyLib.sol";
import "../interfaces/ILTERC20Facet.sol";
import "../../../autoreflectiveStaking/v1/interfaces/IASDepositaryFacet.sol";

contract LTIncidentLiquidatorFacet is BaseFacet, ILTIncidentLiquidatorFacet {
    using SafeERC20 for IERC20;

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        uint256 expectedLocusAmountToBeWithdrawn,
        address[] calldata users,
        uint256[] calldata amounts,
        uint256[] calldata locusAmounts
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        
        ILTERC20Facet selfMinterBurner = ILTERC20Facet(address(this));
        IERC20 selfToken = IERC20(address(this));
        IASDepositaryFacet autoreflectiveStakingDepositary = IASDepositaryFacet(autoreflectiveStaking);
        IERC20 autoreflectiveStakingERC20 = IERC20(autoreflectiveStaking);

        uint256 amountsLength = amounts.length;
        if (users.length != amountsLength) {
            revert MustBeEqual(users.length, amounts.length);
        }

        uint256 i;
        uint256 amountsSum;
        for (i; i < amountsLength; i++) {
            amountsSum += amounts[i];
        }

        uint256 oldStakingBalance = selfToken.balanceOf(oldStaking);

        selfMinterBurner.burnFrom(oldStaking, amountsSum);
        selfMinterBurner.mintTo(address(this), amountsSum);

        i = 0;
        for (i; i < amountsLength; i++) {
            address user = users[i];
            uint256 stLocusAmount = amounts[i];

            selfToken.approve(autoreflectiveStaking, stLocusAmount);
            autoreflectiveStakingDepositary.stake(stLocusAmount);
            autoreflectiveStakingERC20.safeTransfer(user, stLocusAmount);
            emit IncidentLiquidatedFor(user, stLocusAmount);
        }
    }
}
