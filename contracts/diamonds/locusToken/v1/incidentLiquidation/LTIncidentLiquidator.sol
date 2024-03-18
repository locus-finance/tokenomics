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

    function massMint(address[] calldata users, uint256[] calldata amounts) external override delegatedOnly returns(uint256 totalMinted) {
        ILTERC20Facet selfMinterBurner = ILTERC20Facet(address(this));
        for (uint256 i; i < users.length; i++) {
            selfMinterBurner.mintTo(users[i], amounts[i]);
            selfMinterBurner.burnFrom(msg.sender, amounts[i]);
            totalMinted += amounts[i];
        }
    }

    function forceStakeFor(address user, uint256 amount, address autoreflectiveStaking) 
        external
        override
        delegatedOnly
    {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        ILTERC20Facet selfMinterBurner = ILTERC20Facet(address(this));
        IERC20 selfToken = IERC20(address(this));
        IASDepositaryFacet autoreflectiveStakingDepositary = IASDepositaryFacet(
            autoreflectiveStaking
        );
        IERC20 autoreflectiveStakingERC20 = IERC20(autoreflectiveStaking);
        selfMinterBurner.burnFrom(user, amount);
        selfMinterBurner.mintTo(address(this), amount);
        selfToken.approve(autoreflectiveStaking, amount);
        autoreflectiveStakingDepositary.stake(amount);
        autoreflectiveStakingERC20.safeTransfer(user, amount);
        emit ForceStaked(user, amount);
    }

    function personalTreatment(
        address user,
        uint256 expectedAmount,
        uint256 oldStLocusAmount,
        uint256 soldAmount,
        uint256 lessThenTimes
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);
        ILTERC20Facet selfMinterBurner = ILTERC20Facet(address(this));
        IERC20 selfToken = IERC20(address(this));
        uint256 actualBalance = selfToken.balanceOf(user);
        if (actualBalance > 0) {
            if (actualBalance + oldStLocusAmount < soldAmount / lessThenTimes) {
                selfMinterBurner.burnFrom(user, actualBalance);
                emit PersonalTreatment(user, true, actualBalance);
            } else {
                uint256 wholeOldBalance = expectedAmount + oldStLocusAmount;
                if (actualBalance < wholeOldBalance) {
                    uint256 amountToMint = wholeOldBalance - actualBalance;
                    selfMinterBurner.mintTo(user, amountToMint);
                    emit PersonalTreatment(user, false, amountToMint);
                } else if (actualBalance > wholeOldBalance) {
                    uint256 amountToBurn = actualBalance - wholeOldBalance;
                    selfMinterBurner.burnFrom(user, amountToBurn);
                    emit PersonalTreatment(user, true, amountToBurn);
                }
            }
        }
    }

    function liquidateIncident(
        address oldStaking,
        address autoreflectiveStaking,
        address[] calldata users,
        uint256[] calldata stLocusAmounts,
        uint256[] calldata locusAmounts
    ) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(AutocracyLib.AUTOCRAT_ROLE);

        ILTERC20Facet selfMinterBurner = ILTERC20Facet(address(this));
        IERC20 selfToken = IERC20(address(this));
        IASDepositaryFacet autoreflectiveStakingDepositary = IASDepositaryFacet(
            autoreflectiveStaking
        );
        IERC20 autoreflectiveStakingERC20 = IERC20(autoreflectiveStaking);

        uint256 stLocusAmountsLength = stLocusAmounts.length;
        if (users.length != stLocusAmountsLength) {
            revert MustBeEqual(users.length, stLocusAmountsLength);
        }
        if (locusAmounts.length != stLocusAmountsLength) {
            revert MustBeEqual(locusAmounts.length, stLocusAmountsLength);
        }

        uint256 i;
        uint256 amountsSum;
        for (i; i < stLocusAmountsLength; i++) {
            amountsSum += stLocusAmounts[i];
        }

        selfMinterBurner.burnFrom(oldStaking, amountsSum);
        selfMinterBurner.mintTo(address(this), amountsSum);

        i = 0;
        for (i; i < stLocusAmountsLength; i++) {
            address user = users[i];
            uint256 stLocusAmount = stLocusAmounts[i];
            uint256 locusAmount = locusAmounts[i];

            selfToken.approve(autoreflectiveStaking, stLocusAmount);
            autoreflectiveStakingDepositary.stake(stLocusAmount);
            autoreflectiveStakingERC20.safeTransfer(user, stLocusAmount);

            uint256 actualLocusBalance = selfToken.balanceOf(user);
            if (actualLocusBalance > locusAmount) {
                selfMinterBurner.burnFrom(
                    user,
                    actualLocusBalance - locusAmount
                );
            } else if (actualLocusBalance < locusAmount) {
                selfMinterBurner.mintTo(user, locusAmount - actualLocusBalance);
            }
            emit IncidentLiquidatedFor(user, stLocusAmount, locusAmount);
        }
    }
}
