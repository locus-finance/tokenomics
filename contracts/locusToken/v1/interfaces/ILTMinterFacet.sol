// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTMinterFacet {
    function mintFor(address entity, address user) external;
}
