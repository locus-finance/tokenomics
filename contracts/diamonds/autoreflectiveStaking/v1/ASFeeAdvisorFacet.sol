// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../ASLib.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/IASFeeAdvisorFacet.sol";

contract ASFeeAdvisorFacet is BaseFacet, IASFeeAdvisorFacet {
    /// @notice Returns the amount of fee based on who and what amount be transferred and placed fee upon. For now returns constantly zero.
    /// @param amount An amount of tokens of an entity which the advise about fees be based on.
    function advise(uint256 amount) external override pure returns (uint256) {
        return 0;
    }
}
