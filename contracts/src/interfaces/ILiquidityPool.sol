// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidityPool {
    /**
     * @dev Add liquidity to the pool
     */
    function addLiquidity(address token, uint256 amount) external;

    /**
     * @dev Get the amount of liquidity in the pool
     */
    function getLiquidity(address token) external view returns (uint256);

    /**
     * @dev Swap tokens
     */
    function swap(
        address fromToken,
        uint256 amountIn,
        uint256 slippageTolerance
    ) external returns (uint256);

    /**
     * @dev Get token A
     */
    function getTokenA() external view returns (address);

    /**
     * @dev Get token B
     */
    function getTokenB() external view returns (address);
}
