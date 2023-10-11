// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../VELib.sol";

interface IVELoupeFacet {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
    
    function balanceOf(address addr) external view returns (uint256);

    function balanceOf(
        address addr,
        uint256 _t
    ) external view returns (uint256);

    function balanceOfAt(
        address addr,
        uint256 _block
    ) external view returns (uint256);

    function supplyAt(
        VELib.Point memory point,
        uint256 t
    ) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function lockedSupply() external view returns (uint256);

    function totalSupply(uint256 atTimestamp) external view returns (uint256);

    function totalSupplyAt(uint256 _block) external view returns (uint256);
}
