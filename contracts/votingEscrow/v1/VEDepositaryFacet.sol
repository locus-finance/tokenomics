// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./interfaces/IVEDepositaryFacet.sol";
import "./interfaces/IVECheckpointFacet.sol";
import "../VELib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract VEDepositaryFacet is BaseFacet, ReentrancyGuardUpgradeable, IVEDepositaryFacet {
    using SafeERC20 for IERC20;

    function _initialize_VEDepositaryFacet() external override internalOnly {
        __ReentrancyGuard_init();
    }

    /// @notice Withdraw all tokens for `msg.sender`
    /// @dev Only possible if the lock has expired
    function withdraw() external override nonReentrant {
        VELib.LockedBalance storage _locked = VELib.get().rt.locked[msg.sender];
        if (block.timestamp < _locked.end) revert VELib.LockHasToBeExpired();
        // Upcasting is done without checks because the downcasting was with safe checks.
        uint256 value = uint128(_locked.amount);

        VELib.LockedBalance memory oldLocked = _locked;
        _locked.end = 0;
        _locked.amount = 0;
        VELib.get().rt.locked[msg.sender] = _locked;
        uint256 supplyBefore = VELib.get().p.supply;
        VELib.get().p.supply = supplyBefore - value;

        // # old_locked can have either expired <= timestamp or zero end
        // # _locked has only 0 end
        // # Both can have >= 0 amount
        IVECheckpointFacet(address(this)).localCheckpoint(
            msg.sender,
            oldLocked,
            _locked
        );

        IERC20(VELib.get().p.locusToken).safeTransfer(msg.sender, value);

        emit VELib.Withdraw(msg.sender, value, block.timestamp);
        emit VELib.Supply(supplyBefore, supplyBefore - value);
    }

    /// @notice Deposit and lock tokens for a user
    /// @param _addr User's wallet address
    /// @param _value Amount to deposit
    /// @param unlockTime New time when to unlock the tokens, or 0 if unchanged
    /// @param lockedBalance Previous locked amount / timestamp
    function _depositFor(
        address _addr,
        uint256 _value,
        uint256 unlockTime,
        VELib.LockedBalance storage lockedBalance,
        int128 _type
    ) internal {
        VELib.Primitives storage p = VELib.get().p;
        VELib.ReferenceTypes storage rt = VELib.get().rt;

        uint256 supplyBefore = p.supply;

        p.supply = supplyBefore + _value;
        VELib.LockedBalance memory oldLocked = lockedBalance;
        // # Adding to existing lock, or if a lock is expired - creating a new one

        lockedBalance.amount += SafeCast.toInt128(SafeCast.toInt256(_value));
        if (unlockTime != 0) {
            lockedBalance.end = unlockTime;
        }
        rt.locked[_addr] = lockedBalance;

        // # Possibilities:
        // # Both old_locked.end could be current or expired (>/< block.timestamp)
        // # value == 0 (extend lock) or value > 0 (add to lock or extend lock)
        // # _locked.end > block.timestamp (always)
        IVECheckpointFacet(address(this)).localCheckpoint(
            _addr,
            oldLocked,
            lockedBalance
        );

        if (_value > 0) {
            IERC20(p.locusToken).safeTransferFrom(
                msg.sender,
                address(this),
                _value
            );
        }

        emit VELib.Deposit(
            _addr,
            _value,
            lockedBalance.end,
            _type,
            block.timestamp
        );
        emit VELib.Supply(supplyBefore, supplyBefore + _value);
    }

    function createLockOrDepositFor(
        address _addr,
        uint256 _value,
        uint256 _unlockTime
    ) external override delegatedOnly {
        int128 lockedAmount = VELib.get().rt.locked[_addr].amount;
        if (lockedAmount > 0) {
            depositFor(_addr, _value);
        } else {
            createLockFor(_addr, _value, _unlockTime);
        }
    }

    // """
    // @notice Deposit `_value` tokens for `_addr` and add to the lock
    // @dev Anyone (even a smart contract) can deposit for someone else, but
    //      cannot extend their locktime and deposit for a brand new user
    // @param _addr User's wallet address
    // @param _value Amount to add to user's lock
    // """
    function depositFor(
        address _addr,
        uint256 _value
    ) public override nonReentrant delegatedOnly {
        VELib.LockedBalance storage _locked = VELib.get().rt.locked[_addr];
        if (_value == 0) revert VELib.CannotLockZero();
        if (_locked.amount == 0) revert VELib.CannotAddToLockWithZeroBalance();
        if (_locked.end <= block.timestamp) revert VELib.LockExpired();
        _depositFor(_addr, _value, 0, _locked, VELib.DEPOSIT_FOR_TYPE);
    }

    /// @notice Deposit `_value` tokens for `msg.sender` and lock until `_unlock_time`
    /// @param _value Amount to deposit
    /// @param _unlockTime Epoch time when tokens unlock, rounded down to whole weeks
    function createLock(
        uint256 _value,
        uint256 _unlockTime
    ) external override nonReentrant delegatedOnly {
        createLockFor(msg.sender, _value, _unlockTime);
    }

    function createLockFor(
        address _for,
        uint256 _value,
        uint256 _unlockTime
    ) public override delegatedOnly {
        if (_for != msg.sender) {
            RolesManagementLib.enforceSenderRole(VELib.CREATE_LOCK_FOR_AUTHORIZED_ROLE);
        }

        uint256 unlockTime = (_unlockTime / 1 weeks) * 1 weeks; // # Locktime is rounded down to weeks
        VELib.LockedBalance storage _locked = VELib.get().rt.locked[_for];

        if (_value == 0) revert VELib.CannotLockZero();
        if (_locked.amount > 0) revert VELib.LockHasNotYetBeenCreated();
        if (unlockTime <= block.timestamp)
            revert VELib.CannotCreateLockInPastTime();
        if (unlockTime < VELib.get().p.minLockDuration + block.timestamp)
            revert VELib.CannotCreateLockForLessThenMinLock();
        if (unlockTime > block.timestamp + VELib.MAXTIME)
            revert VELib.MaxTimeHit();

        _locked.start = block.timestamp;

        _depositFor(_for, _value, unlockTime, _locked, VELib.CREATE_LOCK_TYPE);
    }

    /// @notice Deposit `_value` additional tokens for `msg.sender`
    ///         without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    function increaseAmount(
        uint256 _value
    ) external override delegatedOnly nonReentrant {
        VELib.LockedBalance storage _locked = VELib.get().rt.locked[msg.sender];
        if (_value == 0) revert VELib.CannotLockZero();
        if (_locked.amount == 0) revert VELib.CannotAddToLockWithZeroBalance();
        if (_locked.end <= block.timestamp) revert VELib.LockExpired();
        _depositFor(msg.sender, _value, 0, _locked, VELib.INCREASE_LOCK_AMOUNT);
    }

    /// @notice Extend the unlock time for `msg.sender` to `_unlockTime`
    /// @param _unlockTime New epoch time for unlocking
    function increaseUnlockTime(
        uint256 _unlockTime
    ) external override delegatedOnly nonReentrant {
        VELib.LockedBalance storage _locked = VELib.get().rt.locked[msg.sender];
        uint256 unlockTimeNearestWeek = (_unlockTime / 1 weeks) * 1 weeks; // Locktime is rounded down to weeks

        if (_locked.end <= block.timestamp) revert VELib.LockExpired();
        if (_locked.amount == 0) revert VELib.CannotAddToLockWithZeroBalance();
        if (unlockTimeNearestWeek <= _locked.end)
            revert VELib.CanOnlyModifyLockDuration();
        if (unlockTimeNearestWeek > block.timestamp + VELib.MAXTIME)
            revert VELib.MaxTimeHit();

        _depositFor(
            msg.sender,
            0,
            unlockTimeNearestWeek,
            _locked,
            VELib.INCREASE_UNLOCK_TIME
        );
    }
}
