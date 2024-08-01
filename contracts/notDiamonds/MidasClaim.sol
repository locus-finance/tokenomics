// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../diamonds/locusStaking/v1/interfaces/ILSDepositaryFacet.sol";

/// @title The contract is ownable, allowing the owner to update contract settings such as the Merkle root, token address, and treasury address.
/// @notice This contract allows users to claim tokens based on a Merkle Tree proof.
contract MidasClaim is Ownable {
    using SafeERC20 for IERC20;

    /// @notice Thrown when an account has already claimed their maximum allowed amount.
    /// @param account The address of the account that has already claimed.
    error AlreadyClaimed(address account);

    /// @notice Thrown when a provided Merkle proof is invalid.
    /// @param account The address of the account that provided the invalid proof.
    /// @param leaf The leaf hash of the account and amount being claimed.
    error ProofIsNotValid(address account, bytes32 leaf);
    
    /// @notice Thrown when a zero bytes32 value is provided where it is not allowed.
    error CannotBeZeroBytes32();
    
    /// @notice Thrown when a zero address is provided where it is not allowed.
    error CannotBeZeroAddress();

    /// @notice Emits when the Merkle root is changed.
    /// @param oldRoot The previous Merkle root.
    /// @param newRoot The new Merkle root.
    event MerkleRootChanged(bytes32 indexed oldRoot, bytes32 indexed newRoot);

    /// @notice Emits when the claiming token is changed.
    /// @param oldToken The previous token address.
    /// @param newToken The new token address.
    event NewClaimingTokenSet(address indexed oldToken, address indexed newToken);

    /// @notice Emits when the treasury address is changed.
    /// @param oldTreasury The previous treasury address.
    /// @param newTreasury The new treasury address.
    event NewTreasurySet(address indexed oldTreasury, address indexed newTreasury);
    
    /// @notice Emitted when the emergency exit function is called.
    event EmergencyExitCalled();

    /// @notice The ERC20 token to be claimed.
    IERC20 public token;

    /// @notice The treasury address to which the remaining tokens will be sent in case of emergency.
    address public treasury;

    /// @notice The Merkle root for the claim verification.
    bytes32 public merkleRoot;

    /// @notice The staking contract where the claimed tokens are staked.
    ILSDepositaryFacet public stLocus;

    /// @dev Tracks the claimed amounts for each user.
    mapping(address => uint256) public claimed;

    /// @notice Constructor to initialize the contract with the necessary parameters.
    /// @param _token The address of the ERC20 token to be claimed.
    /// @param _stLocus The address of the staking contract.
    /// @param _merkleRoot The Merkle root for claim verification.
    /// @param _treasury The treasury address for emergency withdrawals.
    constructor(
        address _token,
        address _stLocus,
        bytes32 _merkleRoot,
        address _treasury
    ) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        stLocus = ILSDepositaryFacet(_stLocus);
        treasury = _treasury;
        token.approve(address(stLocus), type(uint256).max);
    }

    /// @notice Sets a new Merkle root for claim verification.
    /// @param _newRoot The new Merkle root.
    /// @dev Can only be called by the contract owner.
    function setNewMerkleRoot(bytes32 _newRoot) external onlyOwner {
        if (_newRoot == bytes32(0)) {
            revert CannotBeZeroBytes32();
        }
        emit MerkleRootChanged(merkleRoot, _newRoot);
        merkleRoot = _newRoot;
    }

    /// @notice Sets a new ERC20 token for claims.
    /// @param _newToken The address of the new ERC20 token.
    /// @dev Can only be called by the contract owner.
    function setNewToken(address _newToken) external onlyOwner {
        if (_newToken == address(0)) {
            revert CannotBeZeroAddress();
        }
        emit NewClaimingTokenSet(address(token), _newToken);
        token = IERC20(_newToken);
    }

    /// @notice Sets a new treasury address for emergency withdrawals.
    /// @param _newTreasury The address of the new treasury.
    /// @dev Can only be called by the contract owner.
    function setNewTreasury(address _newTreasury) external onlyOwner {
        if (_newTreasury == address(0)) {
            revert CannotBeZeroAddress();
        }
        emit NewTreasurySet(treasury, _newTreasury);
        treasury = _newTreasury;
    }

    /// @notice Allows users to claim tokens by providing a valid Merkle proof.
    /// @param account The address of the account claiming the tokens.
    /// @param amount The amount of tokens being claimed.
    /// @param merkleProof The Merkle proof to verify the claim.
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (claimed[account] >= amount) revert AlreadyClaimed(account);
        bytes32 leaf = keccak256(abi.encodePacked(keccak256(abi.encode(account, amount))));
        bool isValidProof = MerkleProof.verify(merkleProof, merkleRoot, leaf);
        if (!isValidProof) revert ProofIsNotValid(account, leaf);
        claimed[account] += amount;
        stLocus.stakeFor(account, amount);
    }

    /// @notice Allows the owner to withdraw all tokens in case of an emergency.
    /// @dev Transfers all tokens in the contract to the treasury address.
    function emergencyExit() external onlyOwner {
        token.safeTransfer(treasury, token.balanceOf(address(this)));
        emit EmergencyExitCalled();
    }
}
