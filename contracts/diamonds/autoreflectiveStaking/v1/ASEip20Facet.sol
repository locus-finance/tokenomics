// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/IASReflectionFacet.sol";
import "./interfaces/IASEip20Facet.sol";
import "../ASLib.sol";

contract ASEip20Facet is BaseFacet, IASEip20Facet {
    using EnumerableSet for EnumerableSet.AddressSet;

    function totalSupply() external view override returns (uint256) {}

    function balanceOf(
        address account
    ) external view override returns (uint256) {}

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {}

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {}

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {}

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {}

    function name() external view override returns (string memory) {
        return ASLib.get().p.name;
    }

    function symbol() external view override returns (string memory) {
        return ASLib.get().p.symbol;
    }

    function decimals() external view override returns (uint8) {
        return ASLib.get().p.decimals;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, ASLib.get().rt.allowance[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, ASLib.get().rt.allowance[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _emitTransferEvent(address from, address to, uint256 amount) external internalOnly {
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert ASLib.CannotApproveFromZeroAddress();
        if (spender == address(0)) revert ASLib.CannotApproveToZeroAddress();
        ASLib.get().rt.allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (sender == address(0)) revert ASLib.CannotTransferFromZeroAddress();
        if (recipient == address(0)) revert ASLib.CannotTransferToZeroAddress();
        if (amount == 0) revert ASLib.AmountCannotBeZero();

        ASLib.ReferenceTypes storage rt = ASLib.get().rt;

        if (rt.excluded.contains(sender) && !rt.excluded.contains(recipient)) {
            IASReflectionFacet(address(this))._transferFromExcluded(sender, recipient, amount);
        } else if (!rt.excluded.contains(sender) && rt.excluded.contains(recipient)) {
            IASReflectionFacet(address(this))._transferToExcluded(sender, recipient, amount);
        } else if (!rt.excluded.contains(sender) && !rt.excluded.contains(recipient)) {
            IASReflectionFacet(address(this))._transferStandard(sender, recipient, amount);
        } else if (rt.excluded.contains(sender) && rt.excluded.contains(recipient)) {
            IASReflectionFacet(address(this))._transferBothExcluded(sender, recipient, amount);
        } else {
            revert ASLib.CannotRecognizeAddressesInExcludedList(sender, recipient);
        }
    }
}
