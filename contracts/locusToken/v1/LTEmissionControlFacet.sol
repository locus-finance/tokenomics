// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ILTEmissionControlFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "../../tokensDistributor/TDLib.sol";
import "../../tokensDistributor/v1/interfaces/ITDLoupeFacet.sol";
import "../../tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

contract LTEmissionControlFacet is BaseFacet, ILTEmissionControlFacet {
    function mintInflation() external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        (uint256 amountToDistributeInThisEpoch, uint256 epochNumber) = TDLib
            .getAmountToDistribute(address(0));
        if (amountToDistributeInThisEpoch == 0) {
            emit LTLib.EpochAmountIsEmptyOrInflationHasntStarted();
            return;
        }
        if (LTLib.get().isEpochsInflationDistributed[epochNumber]) {
            revert LTLib.EpochIsDistributed(epochNumber);
        }
        ITDProcessFacet(address(this)).distribute(
            amountToDistributeInThisEpoch,
            IERC20(address(this))
        );
        LTLib.get().isEpochsInflationDistributed[epochNumber] = true;
    }
}
