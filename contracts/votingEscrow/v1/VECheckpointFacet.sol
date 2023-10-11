// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "./interfaces/IVECheckpointFacet.sol";
import "../VELib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract VECheckpointFacet is BaseFacet, IVECheckpointFacet {
    /// @notice Record global data to checkpoint
    function checkpoint() external override delegatedOnly {
        VELib.LockedBalance memory _emptyBalance;
        localCheckpoint(address(0), _emptyBalance, _emptyBalance);
    }
    
    /// @notice Record global and per-user data to checkpoint
    /// @param addr User's wallet address. No user checkpoint if 0x0
    /// @param oldLocked Pevious locked amount / end lock time for the user
    /// @param newLocked New locked amount / end lock time for the user
    function localCheckpoint(
        address addr,
        VELib.LockedBalance memory oldLocked,
        VELib.LockedBalance memory newLocked
    ) public override internalOnly {
        VELib.Point memory uOld;
        VELib.Point memory uNew;
        int128 oldDSlope = 0;
        int128 newDSlope = 0;
        // uint256 _epoch = epoch;

        int128 signedMaxTime = SafeCast.toInt128(SafeCast.toInt256(VELib.MAXTIME));

        VELib.Primitives storage p = VELib.get().p;
        VELib.ReferenceTypes storage rt = VELib.get().rt;
        

        if (addr != address(0)) {
            // # Calculate slopes and biases
            // # Kept at zero when they have to
            if (
                oldLocked.end > block.timestamp && oldLocked.amount > int128(0)
            ) {
                uOld.slope = oldLocked.amount / signedMaxTime;
                uOld.bias =
                    uOld.slope *
                    SafeCast.toInt128(
                        SafeCast.toInt256(oldLocked.end - block.timestamp)
                    );
            }
            if (newLocked.end > block.timestamp && newLocked.amount > 0) {
                uNew.slope = newLocked.amount / signedMaxTime;
                uNew.bias =
                    uNew.slope *
                    SafeCast.toInt128(
                        SafeCast.toInt256(newLocked.end - block.timestamp)
                    );
            }

            // # Read values of scheduled changes in the slope
            // # old_locked.end can be in the past and in the future
            // # new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
            oldDSlope = rt.slopeChanges[oldLocked.end];
            if (newLocked.end != 0) {
                if (newLocked.end == oldLocked.end) {
                    newDSlope = oldDSlope;
                } else {
                    newDSlope = rt.slopeChanges[newLocked.end];
                }
            }
        }
        VELib.Point memory lastPoint = VELib.Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (p.epoch > 0 /*_epoch*/) {
            lastPoint = rt.pointHistory[p.epoch /*_epoch*/];
        }
        // uint256 lastCheckpoint = lastPoint.ts;

        // # initial_last_point is used for extrapolation to calculate block number
        // # (approximately, for *At methods) and save them
        // # as we cannot figure that out exactly from inside the contract

        VELib.Point memory initialLastPoint = lastPoint;
        uint256 blockSlope = 0;
        if (block.timestamp > lastPoint.ts) {
            blockSlope =
                (VELib.MULTIPLIER * (block.number - lastPoint.blk)) /
                (block.timestamp - lastPoint.ts);
        }

        // # If last point is already recorded in this block, slope=0
        // # But that's ok b/c we know the block in such case
        //
        // # Go over weeks to fill history and calculate what the current point is
        uint256 tI = (lastPoint.ts / 1 weeks) * 1 weeks; /*lastCheckpoint*/

        for (uint256 i = 0; i < 255; i++) {
            // # Hopefully it won't happen that this won't get used in 5 years!
            // # If it does, users will be able to withdraw but vote weight will be broken
            tI += 1 weeks;
            int128 dSlope = 0;

            if (tI > block.timestamp) {
                tI = block.timestamp;
            } else {
                dSlope = rt.slopeChanges[tI];
            }

            lastPoint.bias -=
                lastPoint.slope *
                SafeCast.toInt128(
                    SafeCast.toInt256(tI - lastPoint.ts /*lastCheckpoint*/)
                );

            lastPoint.slope += dSlope;

            if (lastPoint.bias < 0) {
                // # This can happen
                lastPoint.bias = 0;
            }

            if (lastPoint.slope < 0) {
                // # This cannot happen - just in case
                lastPoint.slope = 0;
            }

            // lastCheckpoint = tI;
            lastPoint.ts = tI;
            lastPoint.blk =
                initialLastPoint.blk +
                (blockSlope * (tI - initialLastPoint.ts)) /
                VELib.MULTIPLIER;
            p.epoch += 1; /*_epoch*/

            if (tI == block.timestamp) {
                lastPoint.blk = block.number;
                break;
            } else {
                rt.pointHistory[p.epoch /*_epoch*/] = lastPoint;
            }
        }

        // epoch = _epoch;
        // # Now point_history is filled until t=now

        if (addr != address(0)) {
            // # If last point was in this block, the slope change has been applied already
            // # But in such case we have 0 slope(s)
            lastPoint.slope += (uNew.slope - uOld.slope);
            lastPoint.bias += (uNew.bias - uOld.bias);
            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
        }

        // # Record the changed point into history
        rt.pointHistory[p.epoch /*_epoch*/] = lastPoint;

        if (addr != address(0)) {
            // # Schedule the slope changes (slope is going down)
            // # We subtract new_user_slope from [new_locked.end]
            // # and add old_user_slope to [old_locked.end]
            if (oldLocked.end > block.timestamp) {
                // # old_dslope was <something> - u_old.slope, so we cancel that
                oldDSlope += uOld.slope;
                if (newLocked.end == oldLocked.end) {
                    oldDSlope -= uNew.slope;
                }
                rt.slopeChanges[oldLocked.end] = oldDSlope;
            }
            if (newLocked.end > block.timestamp) {
                if (newLocked.end > oldLocked.end) {
                    newDSlope -= uNew.slope;
                    rt.slopeChanges[newLocked.end] = newDSlope;
                }
                // else: we recorded it already in old_dslope
            }

            // Now handle user history
            // uint256 userEpoch = userPointEpoch[addr] + 1;

            rt.userPointEpoch[addr] += 1; //= userPointEpoch[addr] + 1/*userEpoch*/;
            uNew.ts = block.timestamp;
            uNew.blk = block.number;
            rt.userPointHistory[addr][rt.userPointEpoch[addr] /*userEpoch*/] = uNew;
        }
    }
}