// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Erc4626 is IERC20 {
    /*   address public asset;
    address public shares; */

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

    function asset() public view returns (address assetTokenAddress) {}

    function totalAssets() public view returns (uint256 totalManagedAssets) {}

    function convertToShares(
        uint256 assets
    ) public view returns (uint256 shares) {}

    function convertToAssets(
        uint256 shares
    ) public view returns (uint256 assets) {}

    function maxDeposit(
        address receiver
    ) public view returns (uint256 maxAssets) {
        return type(uint256).max;
    }

    function previewDeposit(
        uint256 assets
    ) public view returns (uint256 shares) {}

    function deposit(
        address receiver,
        uint256 assets
    ) public returns (uint256 shares) {
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function maxMint(address receiver) public view returns (uint256 maxShares) {
        return type(uint256).max;
    }

    function previewMint(uint256 shares) public view returns (uint256 assets) {}

    function mint(
        address receiver,
        uint256 shares
    ) public returns (uint256 assets) {
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function maxWithdraw(
        address owner
    ) public view returns (uint256 maxAssets) {}

    function previewWithdraw(
        uint256 assets
    ) public view returns (uint256 shares) {}

    function withdraw(
        address receiver,
        address owner,
        uint256 assets
    ) public returns (uint256 shares) {
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function maxRedeem(address owner) public view returns (uint256 maxShares) {}

    function previewRedeem(
        uint256 shares
    ) public view returns (uint256 assets) {}

    function Redeem(
        address receiver,
        address owner,
        uint256 shares
    ) public returns (uint256 assets) {
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
}
