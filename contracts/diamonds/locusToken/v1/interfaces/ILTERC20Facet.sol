// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILTERC20Facet {
    function mintTo(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function delegateTo(address delegatee) external;

    /// @notice To be able to vote for something by themselves a holder must call it first to delegate
    /// all voting power they have to themselves.
    function enablePolitics() external;

    function getVotingPower(address account) external view returns (uint256);
    
    function getPastVotingPower(address account, uint256 timepoint) external view returns (uint256);

    function getDelegatee(address account) external view returns (address);

    function setupTokenInfo() external;
}
