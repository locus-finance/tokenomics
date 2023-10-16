// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ILTERC20Facet {
    function mintTo(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function delegateTo(address delegatee) external;

    function enablePolitics() external;

    function getVotingPower(address account) external view returns (uint256);
    
    function getPastVotingPower(address account, uint256 timepoint) external view returns (uint256);

    function getDelegatee(address account) external view returns (address);

    function _init_LTERC20Facet() external;
}
