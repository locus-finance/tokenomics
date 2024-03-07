// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IASFeeAdvisorFacet {
    function advise(uint256 amount) external view returns (uint256);
}
