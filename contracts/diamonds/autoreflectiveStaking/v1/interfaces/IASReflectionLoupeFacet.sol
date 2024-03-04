// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../../ASLib.sol";

interface IASReflectionLoupeFacet {
    function isExcluded(address account) external view returns (bool);

    function reflectionFromToken(
        uint256 tAmount,
        bool addTransferFee
    ) external view returns (uint256);

    function tokenFromReflection(
        uint256 rAmount
    ) external view returns (uint256);

    function _getValues(
        uint256 tAmount
    ) external view returns (ASLib.Values memory);

    function _getTValues(
        uint256 tAmount
    ) external view returns (ASLib.TValues memory);

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 currentRate
    ) external view returns (ASLib.RValues memory);

    function _getRate() external view returns (uint256);

    function _getCurrentSupply() external view returns (ASLib.Supply memory);

    function getPrimitives() external view returns (ASLib.Primitives memory);
}
