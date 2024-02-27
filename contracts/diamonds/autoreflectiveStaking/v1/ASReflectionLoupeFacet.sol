// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IASReflectionLoupeFacet.sol";
import "../../facetsFramework/diamondBase/facets/BaseFacet.sol";
import "../ASLib.sol";

contract ASReflectionLoupeFacet is BaseFacet, IASReflectionLoupeFacet {
    using EnumerableSet for EnumerableSet.AddressSet;

    function isExcluded(
        address account
    ) external view override delegatedOnly returns (bool) {
        return ASLib.get().rt.excluded.contains(account);
    }

    function totalFees()
        external
        view
        override
        delegatedOnly
        returns (uint256)
    {
        return ASLib.get().p.tFeeTotal;
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool addTransferFee
    ) external view override delegatedOnly returns (uint256) {
        if (!addTransferFee) {
            return this._getValues(tAmount).r.rAmount;
        } else {
            return this._getValues(tAmount).r.rTransferAmount;
        }
    }

    function tokenFromReflection(
        uint256 rAmount
    ) external view override delegatedOnly returns (uint256) {
        return rAmount / this._getRate();
    }

    function _getValues(
        uint256 tAmount
    ) external view internalOnly returns (ASLib.Values memory) {
        ASLib.TValues memory tValues = this._getTValues(tAmount);
        uint256 currentRate = this._getRate();
        ASLib.RValues memory rValues = this._getRValues(
            tAmount,
            tValues.tFee,
            currentRate
        );
        return
            ASLib.Values({
                r: ASLib.RValues({
                    rAmount: rValues.rAmount,
                    rTransferAmount: rValues.rTransferAmount,
                    rFee: rValues.rFee
                }),
                t: ASLib.TValues({
                    tTransferAmount: tValues.tTransferAmount,
                    tFee: tValues.tFee
                })
            });
    }

    function _getTValues(
        uint256 tAmount
    ) external view override internalOnly returns (ASLib.TValues memory) {
        uint256 tFee = tAmount / 100; // TODO: make it time and totalReward dependant
        uint256 tTransferAmount = tAmount;
        return ASLib.TValues({tTransferAmount: tTransferAmount, tFee: tFee});
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 currentRate
    ) external view override internalOnly returns (ASLib.RValues memory) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferAmount = rAmount;
        return
            ASLib.RValues({
                rAmount: rAmount,
                rTransferAmount: rTransferAmount,
                rFee: rFee
            });
    }

    function _getRate() external view override delegatedOnly returns (uint256) {
        ASLib.Supply memory supply = this._getCurrentSupply();
        return supply.rSupply / supply.tSupply;
    }

    function _getCurrentSupply()
        external
        view
        override
        delegatedOnly
        returns (ASLib.Supply memory)
    {
        ASLib.Primitives storage p = ASLib.get().p;
        ASLib.ReferenceTypes storage rt = ASLib.get().rt;
        uint256 rSupply = p.rTotal;
        uint256 tSupply = p.tTotal;
        uint256 excludedSize = rt.excluded.length();
        for (uint256 i = 0; i < excludedSize; i++) {
            address excludedAddr = rt.excluded.at(i);
            if (
                rt.rOwned[excludedAddr] > rSupply ||
                rt.tOwned[excludedAddr] > tSupply
            ) {
                return ASLib.Supply({rSupply: p.rTotal, tSupply: p.tTotal});
            }
            rSupply -= rt.rOwned[excludedAddr];
            tSupply -= rt.tOwned[excludedAddr];
        }
        if (rSupply < p.rTotal / p.tTotal) {
            return ASLib.Supply({rSupply: p.rTotal, tSupply: p.tTotal});
        }
        return ASLib.Supply({rSupply: rSupply, tSupply: tSupply});
    }
}
