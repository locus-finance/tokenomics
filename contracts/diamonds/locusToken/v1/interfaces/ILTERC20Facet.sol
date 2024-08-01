// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title This facet provides ERC20 functionality with additional features like capped supply, voting.
/// @author Oleg Bedrin <o.bedrin@locus.finance> - Locus Team
/// @notice The contract is meant to be utilized as a EIP2535 proxy facet. Hence it cannot be called directly and not through
/// the diamond proxy.
interface ILTERC20Facet {
    /// @notice Mints a specified amount of tokens to a given account.
    /// @dev Can only be called internally. This function calls OZ `_mint` function.
    /// @param account The address to which the minted tokens will be sent.
    /// @param amount The amount of tokens to mint.
    function mintTo(address account, uint256 amount) external;

    /// @notice Burns a specified amount of tokens from a given account.
    /// @dev Can only be called internally. This function calls OZ `_burn` function.
    /// @param account The address from which the tokens will be burned.
    /// @param amount The amount of tokens to burn.
    function burnFrom(address account, uint256 amount) external;

    /// @notice Allows a sender to delegate their votes to a specified delegatee.
    /// @dev Can only be called by DELEGATECALL.
    /// @param delegatee The address to delegate votes to.
    function delegateTo(address delegatee) external;

    /// @notice To be able to vote for something by themselves a holder must call it first to delegate
    /// all voting power they have to themselves.
    function enablePolitics() external;

    /// @notice Returns the current voting power of a specified account.
    /// @dev Can only be called by DELEGATECALL.
    /// @param account The address to query voting power for.
    /// @return The current voting power of the account.
    function getVotingPower(address account) external view returns (uint256);
    
    /// @notice Returns the past voting power of a specified account at a specific timepoint.
    /// @dev Can only be called by DELEGATECALL.
    /// @param account The address to query past voting power for.
    /// @param timepoint The block number at which to query the past voting power.
    /// @return The past voting power of the account at the specified timepoint.
    function getPastVotingPower(address account, uint256 timepoint) external view returns (uint256);

    /// @notice Gets the current delegatee of a specified account.
    /// @dev Can only be called by DELEGATECALL.
    /// @param account The address to query the delegatee for.
    /// @return The address currently delegated to by the account.
    function getDelegatee(address account) external view returns (address);

    /// @notice Sets up token information, including name, symbol, initial supply cap, and permit functionality.
    /// @dev This function can only be called once due to the initializer modifier.
    function setupTokenInfo() external;
}
