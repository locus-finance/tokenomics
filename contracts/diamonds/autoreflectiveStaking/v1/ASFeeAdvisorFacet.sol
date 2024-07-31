// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/IASFeeAdvisorFacet.sol";

/// @title A facet that implements the fee calculation logic. 
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
contract ASFeeAdvisorFacet is BaseFacet, IASFeeAdvisorFacet {
    /// @inheritdoc IASFeeAdvisorFacet
    function advise(uint256) external override pure returns (uint256) {
        return 0;
    }
}
