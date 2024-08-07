// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ILTEmissionControlFacet.sol";
import "../LTLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../../facetsFramework/tokensDistributor/TDLib.sol";
import "../../facetsFramework/tokensDistributor/v1/interfaces/ITDLoupeFacet.sol";
import "../../facetsFramework/tokensDistributor/v1/interfaces/ITDProcessFacet.sol";

/// @title This contract handles the emission control for the system, particularly the minting of inflation.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract LTEmissionControlFacet is BaseFacet, ILTEmissionControlFacet {
    /// @inheritdoc ILTEmissionControlFacet
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
