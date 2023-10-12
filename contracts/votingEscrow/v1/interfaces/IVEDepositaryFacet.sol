// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVEDepositaryFacet {
    function withdraw() external;

    function depositFor(address _addr, uint256 _value) external;

    function createLock(uint256 _value, uint256 _unlockTime) external;

    function createLockFor(
        address _for,
        uint256 _value,
        uint256 _unlockTime
    ) external;

    function increaseAmount(uint256 _value) external;

    function increaseUnlockTime(uint256 _unlockTime) external;

    function _initialize_VEDepositaryFacet() external;

    function createLockOrDepositFor(
        address _addr,
        uint256 _value,
        uint256 _unlockTime
    ) external;
}
