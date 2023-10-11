// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "../VELib.sol";
import "../../diamondBase/facets/BaseFacet.sol";
import "./interfaces/IVELoupeFacet.sol";

contract VELoupeFacet is BaseFacet, IVELoupeFacet {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view override delegatedOnly returns (string memory) {
        return VELib.name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view override delegatedOnly returns (string memory) {
        return VELib.symbol;
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view override delegatedOnly returns (uint8) {
        return VELib.decimals;
    }

    /// @notice Get the current voting power for `msg.sender`
    /// @param addr User wallet address
    /// @return User voting power
    function balanceOf(
        address addr
    ) external view override delegatedOnly returns (uint256) {
        return balanceOf(addr, block.timestamp);
    }

    function balanceOf(
        address addr,
        uint256 _t
    ) public view override delegatedOnly returns (uint256) {
        uint256 _epoch = VELib.get().rt.userPointEpoch[addr];
        if (_epoch == 0) {
            return 0;
        } else {
            VELib.Point memory lastPoint = VELib.get().rt.userPointHistory[
                addr
            ][_epoch];
            lastPoint.bias -=
                lastPoint.slope *
                SafeCast.toInt128(SafeCast.toInt256(_t - lastPoint.ts));
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
            // Upcasting is performed without safe checks cause the downcasting was with them.
            return uint128(lastPoint.bias);
        }
    }

    // @notice Measure voting power of `addr` at block height `_block`
    // @param addr User's wallet address
    // @param _block Block to calculate the voting power at
    // @return Voting power
    function balanceOfAt(
        address addr,
        uint256 _block
    ) external view override delegatedOnly returns (uint256) {
        // # Copying and pasting totalSupply code because Vyper cannot pass by
        // # reference yet
        if (_block > block.number) revert VELib.CanOnlyLookIntoPastBlocks();

        VELib.Primitives storage p = VELib.get().p;
        VELib.ReferenceTypes storage rt = VELib.get().rt;

        // Binary search of user point's block
        uint256 foundUserPointBlock = VELib.binarySearch(
            _block,
            rt.userPointEpoch[addr],
            abi.encodePacked(addr), // for the user to be passed to getBlockUserPointHistory
            getUserPointBlockFromHistory
        );

        VELib.Point memory upoint = rt.userPointHistory[addr][
            foundUserPointBlock
        ];

        uint256 maxEpoch = p.epoch;

        /// Binary search to estimate timestamp for block number
        uint256 _epoch = VELib.binarySearch(
            _block,
            maxEpoch,
            abi.encodePacked(uint8(0)), // nothing to be passed to the getBlockFromPointHistory
            getApproximateTimestampForBlock
        );

        VELib.Point memory point0 = rt.pointHistory[_epoch];
        uint256 dBlock = 0;
        uint256 dT = 0;
        if (_epoch < maxEpoch) {
            VELib.Point memory point1 = rt.pointHistory[_epoch + 1];
            dBlock = point1.blk - point0.blk;
            dT = point1.ts - point0.ts;
        } else {
            dBlock = block.number - point0.blk;
            dT = block.timestamp - point0.ts;
        }
        uint256 blockTime = point0.ts;
        if (dBlock != 0) {
            blockTime += (dT * (_block - point0.blk)) / dBlock;
        }

        upoint.bias -=
            upoint.slope *
            SafeCast.toInt128(SafeCast.toInt256(blockTime - upoint.ts));
        if (upoint.bias >= 0) {
            // Upcasting is performed without safe checks because downcasting was performed with them.
            return uint128(upoint.bias);
        } else {
            return 0;
        }
    }

    // """
    // @notice Calculate total voting power at some point in the past
    // @param point The point (bias/slope) to start search from
    // @param t Time to calculate the total voting power at
    // @return Total voting power at that time
    // """
    function supplyAt(
        VELib.Point memory point,
        uint256 t
    ) public view override delegatedOnly returns (uint256) {
        VELib.Point memory lastPoint = point;
        uint256 tI = (lastPoint.ts / 1 weeks) * 1 weeks;
        for (uint256 i = 0; i < 255; i++) {
            tI += 1 weeks;
            int128 dSlope = 0;
            if (tI > t) {
                tI = t;
            } else {
                dSlope = VELib.get().rt.slopeChanges[tI];
            }
            lastPoint.bias -=
                lastPoint.slope *
                SafeCast.toInt128(SafeCast.toInt256(tI - lastPoint.ts));
            if (tI == t) {
                break;
            }
            lastPoint.slope += dSlope;
            lastPoint.ts = tI;
        }

        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        // Upcasting is performed without safety checks because the downcasting was with them.
        return uint128(lastPoint.bias);
    }

    // """
    // @notice Calculate total voting power
    // @dev Adheres to the IERC20Metadata `totalSupply` interface for Aragon compatibility
    // @return Total voting power
    // """
    function totalSupply()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return totalSupply(block.timestamp);
    }

    // returns supply of locked tokens
    function lockedSupply()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return VELib.get().p.supply;
    }

    function totalSupply(
        uint256 atTimestamp
    ) public view override delegatedOnly returns (uint256) {
        VELib.Point memory lastPoint = VELib.get().rt.pointHistory[
            VELib.get().p.epoch
        ];
        return supplyAt(lastPoint, atTimestamp);
    }

    // """
    // @notice Calculate total voting power at some point in the past
    // @param _block Block to calculate the total voting power at
    // @return Total voting power at `_block`
    // """
    function totalSupplyAt(
        uint256 _block
    ) external view override delegatedOnly returns (uint256) {
        if (_block > block.number) revert VELib.CanOnlyLookIntoPastBlocks();

        VELib.Primitives storage p = VELib.get().p;
        VELib.ReferenceTypes storage rt = VELib.get().rt;

        uint256 _epoch = p.epoch;
        uint256 targetEpoch = VELib.binarySearch(
            _block,
            _epoch,
            abi.encode(uint8(0)),
            getApproximateTimestampForBlock
        );

        VELib.Point memory point = rt.pointHistory[targetEpoch];

        uint256 dt = 0; // difference in total voting power between _epoch and targetEpoch

        if (targetEpoch < _epoch) {
            VELib.Point storage pointNext = rt.pointHistory[targetEpoch + 1];
            if (point.blk != pointNext.blk) {
                dt =
                    ((_block - point.blk) * (pointNext.ts - point.ts)) /
                    (pointNext.blk - point.blk);
            }
        } else {
            if (point.blk != block.number) {
                dt =
                    ((_block - point.blk) * (block.timestamp - point.ts)) /
                    (block.number - point.blk);
            }
        }

        // # Now dt contains info on how far are we beyond point
        return supplyAt(point, point.ts + dt);
    }

    // Map functions for the binary search are below.

    function getUserPointBlockFromHistory(
        uint256 blockNumber,
        bytes memory metainfo
    ) internal view returns (uint256) {
        address user = abi.decode(metainfo, (address));
        return VELib.get().rt.userPointHistory[user][blockNumber].blk;
    }

    function getApproximateTimestampForBlock(
        uint256 blockNumber,
        bytes memory
    ) internal view returns (uint256) {
        return VELib.get().rt.pointHistory[blockNumber].blk;
    }
}
