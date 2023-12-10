// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LiquidityPool} from "../src/LiquidityPool.sol";
import {ERC20} from "../src/ERC20.sol";

contract LiquidityPoolTest is Test {
    LiquidityPool pool;
    ERC20 tokenA;
    ERC20 tokenB;

    /**
     @notice Cette fonction est appelée avant chaque test, elle permet de
            mettre en place l'environnement.
     */
    function setUp() public {
        // Crée deux tokens ERC20 et mint le maximum de tokens possible pour l'adresse du test
        tokenA = new ERC20("TokenA", "TKA");
        tokenB = new ERC20("TokenB", "TKB");

        // Deploy the liquidity pool
        pool = new LiquidityPool(
            "TokenA-TokenB Liquidity Pool",
            "TKA-TKB-LP",
            address(tokenA),
            address(tokenB)
        );
    }
}

contract LiquidityPoolAddLiquidityTest is LiquidityPoolTest {
    error InvalidToken();

    /**
     @notice Cette fonction teste le cas où le token n'est pas tokenA ou tokenB
     */
    function test_addLiquidity_shouldRevertIfNotTokenAOrTokenB() external {
        address anotherToken = address(0x99);
        // Avec cette fonction, on s'attend à ce que le contrat revert avec l'erreur InvalidToken
        vm.expectRevert(InvalidToken.selector);
        pool.addLiquidity(anotherToken, 1e18);
    }

    /**
     @notice Cette fonction teste le cas nominal de la fonction addLiquidity pour le tokenA
     */
    function test_addLiquidity_nominalCase_tokenA() external {
        uint256 amount = 1e18;
        // On approuve le contrat à dépenser les tokens
        tokenA.approve(address(pool), amount);

        // On s'attend à ce que le contrat appelle la fonction transferFrom de tokenA
        vm.expectCall(
            address(tokenA),
            abi.encodeCall(
                tokenA.transferFrom,
                (address(this), address(pool), amount)
            ),
            1
        );

        // On ajoute de la liquidité
        pool.addLiquidity(address(tokenA), amount);

        // On vérifie que le contrat a bien mis à jour la variable aLiquidity
        assertEq(pool.aLiquidity(), amount);
        assertEq(pool.bLiquidity(), uint256(0));
    }

    /**
     @notice Cette fonction teste le cas nominal de la fonction addLiquidity pour le tokenB
     */
    function test_addLiquidity_nominalCase_tokenB() external {
        uint256 amount = 1e18;
        // On approuve le contrat à dépenser les tokens
        tokenB.approve(address(pool), amount);

        // On s'attend à ce que le contrat appelle la fonction transferFrom de tokenB
        vm.expectCall(
            address(tokenB),
            abi.encodeCall(
                tokenB.transferFrom,
                (address(this), address(pool), amount)
            ),
            1
        );

        // On ajoute de la liquidité
        pool.addLiquidity(address(tokenB), amount);

        // On vérifie que le contrat a bien mis à jour la variable bLiquidity
        assertEq(pool.aLiquidity(), uint256(0));
        assertEq(pool.bLiquidity(), amount);
    }
}
