// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "../diamonds/locusStaking/v1/interfaces/ILSLoupeFacet.sol";

contract WrappedStakingLocus is ERC20, ERC20Permit, ERC20Votes {
    event PoliticsEnabled(address indexed who);
    event PoliticsDisabled(address indexed who);

    error OnlyStakingDiamond();

    ILSLoupeFacet public locusStakingDiamond;
    IERC20Metadata public locusDiamond;

    constructor(
        ILSLoupeFacet _locusStakingDiamond,
        IERC20Metadata _locusDiamond
    ) 
        ERC20("", "") 
        ERC20Permit("vstLOCUSDomainSeparator") 
    {
        locusStakingDiamond = _locusStakingDiamond;
        locusDiamond = _locusDiamond;
    }

    function enableOrRefreshPoliticsFor(address who) external {
        if (_msgSender() == address(locusStakingDiamond)) {
            _enableOrRefreshPolitics(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    function disablePoliticsFor(address who) external {
        if (_msgSender() == address(locusStakingDiamond)) {
            _disablePolitics(who);
        } else {
            revert OnlyStakingDiamond();
        }
    }

    function enableOrRefreshPolitics() external {
        address sender = _msgSender();
        _enableOrRefreshPolitics(sender);
    }

    function disablePolitics() external {
        address sender = _msgSender();
        _disablePolitics(sender);
    }

    function name() public view override returns (string memory) {
        return string(abi.encodePacked(locusDiamond.name(), " with voting power"));
    }

    function symbol() public view override returns (string memory) {
        return string(abi.encodePacked("st", locusDiamond.symbol()));
    }

    function decimals() public view override returns (uint8) {
        return locusDiamond.decimals();
    }

    function _enableOrRefreshPolitics(address sender) internal {
        _mint(sender, locusStakingDiamond.balanceOf(sender) - balanceOf(sender));
        emit PoliticsEnabled(sender);
    }

    /// @dev It has been rejected to implement partial disabling of politics because
    /// of unnecessary complexations for possible boost systems.
    function _disablePolitics(address sender) internal {
        _burn(sender, locusStakingDiamond.balanceOf(sender));
        emit PoliticsDisabled(sender);
    }

    function _mint(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
}