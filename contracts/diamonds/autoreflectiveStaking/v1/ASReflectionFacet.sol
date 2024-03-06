// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "./interfaces/IASReflectionFacet.sol";
import "./interfaces/IASReflectionLoupeFacet.sol";
import "./interfaces/IASEip20Facet.sol";
import "../ASLib.sol";

import "hardhat/console.sol";

contract ASReflectionFacet is IASReflectionFacet, BaseFacet {
    using EnumerableSet for EnumerableSet.AddressSet;

    function _mintTo(
        address who,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        ASLib.Primitives storage p = ASLib.get().p;


        // make it transfers 
        
        // if (who != ASLib.t) {
        //     console.log(IASEip20Facet(address(this)).balanceOf(ASLib.t));
        // }
        // p.tTotal += tAmount;
        // this._updateTotalReflection();
        // if (who != ASLib.t) {
        //     console.log(IASEip20Facet(address(this)).balanceOf(ASLib.t));
        // }
        
        if (p.tTotal == 0 && p.rTotal == 0) {
            rt.rOwned[who] = p.rTotal;
            IASEip20Facet(address(this))._emitTransferEvent(
                address(0),
                who,
                tAmount
            );
        } else {
            ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
                ._getValues(tAmount);
            if (rt.excluded.contains(who)) {
                rt.tOwned[who] += values.t.tTransferAmount;
                rt.rOwned[who] += values.r.rTransferAmount;
            } else {
                rt.rOwned[who] += values.r.rTransferAmount;
                // console.log(rt.rOwned[who], values.r.rTransferAmount, values.t.tTransferAmount);
            }
            _reflectFee(values.r.rFee, values.t.tFee);
            IASEip20Facet(address(this))._emitTransferEvent(
                address(0),
                who,
                values.t.tTransferAmount
            );
        }
    }

    function _burnFrom(
        address who,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
            ._getValues(tAmount);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        ASLib.get().p.tTotal -= tAmount;
        this._updateTotalReflection();
        if (rt.excluded.contains(who)) {
            rt.tOwned[who] -= tAmount;
            rt.rOwned[who] -= values.r.rAmount;
        } else {
            rt.rOwned[who] -= values.r.rTransferAmount;
        }
        _reflectFee(values.r.rFee, values.t.tFee);
        IASEip20Facet(address(this))._emitTransferEvent(
            who,
            address(0),
            values.t.tTransferAmount
        );
    }

    function _updateTotalReflection() external override internalOnly {
        ASLib.Primitives storage p = ASLib.get().p;
        p.rTotal = type(uint256).max - (type(uint256).max % p.tTotal);
    }

    function excludeAccount(address account) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        if (!rt.excluded.add(account)) revert ASLib.AlreadyExcluded(account);
        if (rt.rOwned[account] > 0) {
            rt.tOwned[account] = IASReflectionLoupeFacet(address(this))
                .tokenFromReflection(rt.rOwned[account]);
            emit AddressStatus(account, true);
        }
    }

    function includeAccount(address account) external override delegatedOnly {
        RolesManagementLib.enforceSenderRole(RolesManagementLib.OWNER_ROLE);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        if (!rt.excluded.remove(account)) revert ASLib.AlreadyIncluded(account);
        rt.tOwned[account] = 0;
        emit AddressStatus(account, false);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
            ._getValues(tAmount);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        rt.rOwned[sender] -= values.r.rAmount;
        rt.rOwned[recipient] += values.r.rTransferAmount;
        _reflectFee(values.r.rFee, values.t.tFee);
        IASEip20Facet(address(this))._emitTransferEvent(
            sender,
            recipient,
            values.t.tTransferAmount
        );
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
            ._getValues(tAmount);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        rt.rOwned[sender] -= values.r.rAmount;
        rt.tOwned[recipient] += values.t.tTransferAmount;
        rt.rOwned[recipient] += values.r.rTransferAmount;
        _reflectFee(values.r.rFee, values.t.tFee);
        IASEip20Facet(address(this))._emitTransferEvent(
            sender,
            recipient,
            values.t.tTransferAmount
        );
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
            ._getValues(tAmount);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        rt.tOwned[sender] -= tAmount;
        rt.rOwned[sender] -= values.r.rAmount;
        rt.rOwned[recipient] += values.r.rTransferAmount;
        _reflectFee(values.r.rFee, values.t.tFee);
        IASEip20Facet(address(this))._emitTransferEvent(
            sender,
            recipient,
            values.t.tTransferAmount
        );
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) external override internalOnly {
        ASLib.Values memory values = IASReflectionLoupeFacet(address(this))
            ._getValues(tAmount);
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        rt.tOwned[sender] -= tAmount;
        rt.rOwned[sender] -= values.r.rAmount;
        rt.tOwned[recipient] += values.t.tTransferAmount;
        rt.rOwned[recipient] += values.r.rTransferAmount;
        _reflectFee(values.r.rFee, values.t.tFee);
        IASEip20Facet(address(this))._emitTransferEvent(
            sender,
            recipient,
            values.t.tTransferAmount
        );
    }

    function _reflectFee(uint256 rFee, uint256 tFee) internal {
        ASLib.Primitives storage p = ASLib.get().p;
        p.rTotal -= rFee;
        p.tFeeTotal += tFee;
        emit FeeReflected(tFee);
    }
}
