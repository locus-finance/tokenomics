// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTAutocracyGovernmentFacet {
    event SelectorUsageStatusSet(
        address indexed entity,
        bytes4 indexed selector,
        bool indexed status
    );
    error IsNotAllowedByTheAutocract(bytes4 selector, address whoCalled);

    function enforceAutocracyGovernmentDelegatee(
        address who,
        bytes4 selector
    ) external view;

    function setStatusOfSelectorUsageTo(
        address who,
        bytes4 selector,
        bool status
    ) external;

    function setStatusOfMintingBurningSelectorsFor(
        address who,
        bool status
    ) external;
}
