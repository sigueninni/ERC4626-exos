// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Erc4626.sol";

// Simple ERC20 for testing
contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract Erc4626Test is Test {
    Erc4626 vault;
    MockERC20 token;
    address alice;
    address bob;

    function setUp() public {
        alice = address(1);
        bob = address(2);

        token = new MockERC20();
        vault = new Erc4626(token);

        // Distribute tokens
        token.mint(alice, 1000 ether);
        token.mint(bob, 1000 ether);

        // Approve vault
        vm.prank(alice);
        token.approve(address(vault), type(uint256).max);

        vm.prank(bob);
        token.approve(address(vault), type(uint256).max);
    }

    function testDepositAndWithdraw() public {
        vm.startPrank(alice);

        // Deposit 100 assets
        uint256 shares = vault.deposit(alice, 100 ether);
        assertEq(vault.balanceOf(alice), shares);
        assertEq(token.balanceOf(address(vault)), 100 ether);

        // Withdraw 50 assets
        uint256 sharesBurned = vault.withdraw(alice, alice, 50 ether);
        assertGt(sharesBurned, 0);
        assertEq(token.balanceOf(alice), 1000 ether - 100 ether + 50 ether);

        vm.stopPrank();
    }

    function testMintAndRedeem() public {
        vm.startPrank(bob);

        // Mint 100 shares
        uint256 assetsSpent = vault.mint(bob, 100 ether);
        assertEq(vault.balanceOf(bob), 100 ether);
        assertEq(token.balanceOf(address(vault)), assetsSpent);

        // Redeem 50 shares
        uint256 assetsReturned = vault.redeem(bob, bob, 50 ether);
        assertEq(vault.balanceOf(bob), 50 ether);
        assertGt(assetsReturned, 0);

        vm.stopPrank();
    }

    function testPreviewFunctions() public {
        vm.prank(alice);
        vault.deposit(alice, 100 ether);

        uint256 expectedShares = vault.previewDeposit(50 ether);
        uint256 expectedAssets = vault.previewRedeem(50 ether);

        assertGt(expectedShares, 0);
        assertGt(expectedAssets, 0);
    }

    /*     function testDepositAttackVulnerability() public {
        // Bob dépose 1 wei
        vm.prank(bob);
        uint256 bobShares = vault.deposit(bob, 1);
        assertEq(bobShares, 1);

        // Bob fait une donation directe de 100 ether au vault
        token.transfer(address(vault), 100 ether);
        assertEq(vault.totalAssets(), 100 ether + 1);

        // Alice dépose 100 ether
        vm.prank(alice);
        uint256 aliceShares = vault.deposit(alice, 100 ether);

        emit log_named_uint("Alice received shares", aliceShares);
        emit log_named_uint("Total shares", vault.totalSupply());

        // Bob retire ses parts
        vm.prank(bob);
        uint256 assetsOut = vault.redeem(bob, bob, bobShares);

        emit log_named_uint("Bob withdrew", assetsOut);
        assertGt(
            assetsOut,
            100 ether,
            unicode"Bob a vole des assets grace à la donation !"
        );
    }

    function testInflationAttack() public {
        // Bob fait un petit dépôt initial
        vm.prank(bob);
        uint256 bobShares = vault.deposit(bob, 1); // 1 wei d'asset => 1 share
        assertEq(bobShares, 1);

        // Bob fait une donation directe de 100 ether au vault (sans mint)
        ERC20(vault.asset()).transfer(address(vault), 100 ether);
        assertEq(vault.totalAssets(), 100 ether + 1);

        // Alice pense déposer 100 ether normalement
        vm.prank(alice);
        uint256 aliceShares = vault.deposit(alice, 100 ether);

        emit log_named_uint("Alice received shares", aliceShares);
        emit log_named_uint("Total shares", vault.totalSupply());

        // Attaque : Bob retire ses parts
        vm.prank(bob);
        uint256 assetsOut = vault.redeem(bob, bob, bobShares);

        emit log_named_uint("Bob withdrew", assetsOut);
        assertGt(assetsOut, 100 ether); // Bob vole l'argent d'Alice !
    } */

    function testDepositFailsAfterDonation() public {
        // Bob dépose 1 wei
        vm.prank(bob);
        vault.deposit(bob, 1);

        // Bob fait une donation directe de 100 ether au vault
        token.transfer(address(vault), 100 ether);

        // Alice tente de déposer 100 ether, mais le vault revert
        vm.prank(alice);
        vm.expectRevert(Erc4626.InvalidShares.selector);
        vault.deposit(alice, 100 ether);
    }
}
