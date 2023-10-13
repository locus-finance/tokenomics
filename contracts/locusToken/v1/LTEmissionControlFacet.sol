// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./interfaces/ILTEmissionControlFacet.sol";
import "../LTLib.sol";
import "../../diamondBase/facets/BaseFacet.sol";

contract LTEmissionControlFacet is BaseFacet, ILTEmissionControlFacet {
    /// @dev Update mining rate and supply at the start of the epoch.
    /// Any modifying mining call must also call this.
    function updateMiningParameters() public override internalOnly {
        LTLib.Primitives storage p = LTLib.get().p;
        p.startEpochTime += LTLib.RATE_REDUCTION_TIME;
        p.miningEpoch++;

        uint256 rate = p.rate;
        if (rate == 0) {
            rate = LTLib.INITIAL_RATE;
        } else {
            p.startEpochSupply += rate * LTLib.RATE_REDUCTION_TIME;
            rate *= LTLib.RATE_DENOMINATOR / LTLib.RATE_REDUCTION_COEFFICIENT;
        }
        p.rate = rate;
        emit LTLib.UpdateMiningParameters(
            block.timestamp,
            rate,
            p.startEpochSupply
        );
    }

    function globalUpdateMiningParameters() external override delegatedOnly {
        if (
            block.timestamp <
            LTLib.get().p.startEpochTime + LTLib.RATE_REDUCTION_TIME
        ) {
            revert LTLib.CannotUpdateGlobalMiningParametersTooSoon();
        }
        updateMiningParameters();
    }

    /// @notice Get timestamp of the current mining epoch start
    /// while simultaneously updating mining parameters.
    /// @return Timestamp of the epoch
    function startEpochTimeWrite()
        public
        override
        delegatedOnly
        returns (uint256)
    {
        uint256 startEpochTime = LTLib.get().p.startEpochTime;
        if (block.timestamp >= startEpochTime + LTLib.RATE_REDUCTION_TIME) {
            updateMiningParameters();
            return LTLib.get().p.startEpochTime;
        } else {
            return startEpochTime;
        }
    }

    /// @notice Get timestamp of the next mining epoch start
    /// while simultaneously updating mining parameters.
    /// @return Timestamp of the next epoch
    function futureEpochTimeWrite()
        external
        override
        delegatedOnly
        returns (uint256)
    {
        return startEpochTimeWrite() + LTLib.RATE_REDUCTION_TIME;
    }

    /// @notice Current number of tokens in existence (claimed or unclaimed).
    function availableSupply()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return
            LTLib.get().p.startEpochSupply +
            (block.timestamp - LTLib.get().p.startEpochTime) *
            LTLib.get().p.rate;
    }

    /// @notice How much supply is mintable from start timestamp till end timestamp.
    /// @param start Start of the time interval (timestamp)
    /// @param end End of the time interval (timestamp)
    /// @return Tokens mintable from `start` till `end`
    function mintableInTimeframe(
        uint256 start,
        uint256 end
    ) external view override delegatedOnly returns (uint256) {
        if (start > end) {
            revert LTLib.InvalidTimeframe(start, end);
        }
        uint256 toMint = 0;
        uint256 currentEpochTime = LTLib.get().p.startEpochTime;
        uint256 currentRate = LTLib.get().p.rate;
        // # Special case if end is in future (not yet minted) epoch
        if (end > currentEpochTime + LTLib.RATE_REDUCTION_TIME) {
            currentEpochTime += LTLib.RATE_REDUCTION_TIME;
            currentRate *=
                LTLib.RATE_DENOMINATOR /
                LTLib.RATE_REDUCTION_COEFFICIENT;
        }
        if (end > currentEpochTime + LTLib.RATE_REDUCTION_TIME) {
            revert LTLib.TooFarIntoFuture(end);
        }

        for (uint256 i; i < 999; i++) {
            // # Locus will not work in 1000 years. Darn!
            if (end >= currentEpochTime) {
                uint256 currentEnd = end;
                if (currentEnd > currentEpochTime + LTLib.RATE_REDUCTION_TIME) {
                    currentEnd = currentEpochTime + LTLib.RATE_REDUCTION_TIME;
                }
                uint256 currentStart = start;
                if (
                    currentStart >= currentEpochTime + LTLib.RATE_REDUCTION_TIME
                ) {
                    break; // # We should never get here but what if...
                } else if (currentStart < currentEpochTime) {
                    currentStart = currentEpochTime;
                }

                toMint += currentRate * (currentEnd - currentStart);

                if (start >= currentEpochTime) {
                    break;
                }
            }
            currentEpochTime -= LTLib.RATE_REDUCTION_TIME;
            currentRate *=
                LTLib.RATE_REDUCTION_COEFFICIENT /
                LTLib.RATE_DENOMINATOR; // # double-division with rounding made rate a bit less => good;
            if (currentRate >= LTLib.INITIAL_RATE) {
                revert LTLib.InvalidRate(currentRate);
            }
        }
        return toMint;
    }
}
