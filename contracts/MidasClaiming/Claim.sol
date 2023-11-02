// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../locusStaking/v1/interfaces/ILSDepositaryFacet.sol";

error Claim__AlreadyClaimed(address);
error Claim__ProofIsNotValid(address, bytes32);

contract Claim is Ownable {
    IERC20 public token;
    address public treasury;
    bytes32 public merkleRoot;
    ILSDepositaryFacet public stLocus;

    using SafeERC20 for IERC20;

    mapping(address user => uint256 claimed) claimed;

    constructor(
        address _token,
        address _stLocus,
        bytes32 _merkleRoot,
        address _treasury
    ) Ownable(msg.sender) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        stLocus = ILSDepositaryFacet(_stLocus);
        treasury = _treasury;
        token.approve(address(stLocus), type(uint256).max);
    }

    function setNewMerkleRoot(bytes32 _newRoot) external onlyOwner {
        merkleRoot = _newRoot;
    }

    function setNewToken(address _newToken) external onlyOwner {
        token = IERC20(_newToken);
    }

    function setNewTreasury(address _newTreasury) external onlyOwner {
        treasury = _newTreasury;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        if (claimed[account] > 0) revert Claim__AlreadyClaimed(account);
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        bool isValidProof = MerkleProof.verify(merkleProof, merkleRoot, leaf);
        if (!isValidProof) revert Claim__ProofIsNotValid(account, leaf);
        claimed[account] += amount;
        stLocus.stakeFor(account, amount);
    }

    function emergencyExit() external onlyOwner {
        token.safeTransfer(treasury, token.balanceOf(address(this)));
    }
}
