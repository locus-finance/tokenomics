// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/IASFeeAdvisorFacet.sol";

contract ASFeeAdvisorFacet is BaseFacet, IASFeeAdvisorFacet {
    /// @inheritdoc IASFeeAdvisorFacet
    function advise(uint256) external override pure returns (uint256) {
        return 0;
    }
}
