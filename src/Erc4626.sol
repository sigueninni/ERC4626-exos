// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Erc4626 is ERC20 {
    using SafeERC20 for ERC20;

    ERC20 private immutable _asset; //Asset,

    event Deposit(
        address indexed sender,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    error InvalidShares();
    error InvalidAssets();
    error InvalidReceiver();
    error InvalidOwner();

    constructor(ERC20 asset_) ERC20("Shares", "S") {
        _asset = asset_;
    }

    function asset() public view returns (address assetTokenAddress) {
        return address(_asset);
    }

    function totalAssets() public view returns (uint256 totalManagedAssets) {
        return _asset.balanceOf(address(this));
    }

    function convertToShares(
        uint256 assets
    ) public view returns (uint256 shares) {
        if (totalSupply() == 0) {
            return assets;
        } else {
            return ((assets * totalSupply()) / totalAssets());
        }
    }

    function convertToAssets(
        uint256 shares
    ) public view returns (uint256 assets) {
        /*     uint256 totalSupply = totalSupply();
        require(totalSupply > 0, "No shares minted yet");
        return ((shares * totalAssets()) / totalSupply); */

        uint256 supply = totalSupply();
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }

    function maxDeposit(
        address receiver
    ) public view returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    function previewDeposit(
        uint256 assets
    ) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    function deposit(
        address receiver,
        uint256 assets
    ) public returns (uint256 shares) {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        if (assets > maxDeposit(receiver)) {
            revert InvalidShares();
        }

        shares = convertToShares(assets);

        if (shares <= 0) {
            revert InvalidShares();
        }

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);

        return shares;
    }

    function maxMint(address receiver) public view returns (uint256 maxShares) {
        return type(uint256).max;
    }

    function previewMint(uint256 shares) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function mint(
        address receiver,
        uint256 shares
    ) public returns (uint256 assets) {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        if (shares > maxMint(receiver)) {
            revert InvalidShares();
        }

        assets = convertToAssets(shares);

        if (assets == 0) {
            revert InvalidAssets();
        }

        _asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
        return assets;
    }

    function maxWithdraw(
        address owner
    ) public view returns (uint256 maxAssets) {
        return convertToAssets(balanceOf(owner));
    }

    function previewWithdraw(
        uint256 assets
    ) public view returns (uint256 shares) {
        return convertToShares(assets);
    }

    function withdraw(
        address receiver,
        address owner,
        uint256 assets
    ) public returns (uint256 shares) {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        if (owner == address(0)) {
            revert InvalidOwner();
        }

        if (assets > maxWithdraw(receiver)) {
            revert InvalidShares();
        }

        shares = convertToShares(assets);

        if (shares <= 0) {
            revert InvalidShares();
        }

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _asset.safeTransfer(receiver, assets);
        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return shares;
    }

    function maxRedeem(address owner) public view returns (uint256 maxShares) {
        return balanceOf(owner);
    }

    function previewRedeem(
        uint256 shares
    ) public view returns (uint256 assets) {
        return convertToAssets(shares);
    }

    function redeem(
        address receiver,
        address owner,
        uint256 shares
    ) public returns (uint256 assets) {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        if (shares > maxRedeem(owner)) {
            revert InvalidShares();
        }

        assets = convertToAssets(shares);

        if (assets == 0) {
            revert InvalidAssets();
        }

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        return assets;
    }
}
