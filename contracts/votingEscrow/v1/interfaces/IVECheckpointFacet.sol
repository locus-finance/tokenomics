// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../VELib.sol";

interface IVECheckpointFacet {
    function localCheckpoint(
        address addr,
        VELib.LockedBalance memory oldLocked,
        VELib.LockedBalance memory newLocked
    ) external;

    function checkpoint() external;
}