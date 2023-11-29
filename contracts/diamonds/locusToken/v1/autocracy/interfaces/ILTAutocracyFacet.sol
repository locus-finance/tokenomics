// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTAutocracyFacet {
    function establishAutocracy() external;

    function defeatAutocracyForever() external;

    function burn(uint256 amount) external;

    function mint(address who, uint256 amount) external;

    function areAutocratsReign() external view returns (bool);
}
