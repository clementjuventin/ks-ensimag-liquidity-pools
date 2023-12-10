// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILiquidityPool} from "./interfaces/ILiquidityPool.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract LiquidityPool is ILiquidityPool {
    address tokenA;
    address tokenB;

    uint256 public aLiquidity;
    uint256 public bLiquidity;

    string public name;
    string public symbol;

    mapping(address => uint256) private tokenABalance;
    mapping(address => uint256) private tokenBBalance;

    error InvalidToken();
    error SlippageTooHigh();

    constructor(
        string memory _name,
        string memory _symbol,
        address _tokenA,
        address _tokenB
    ) {
        tokenA = _tokenA;
        tokenB = _tokenB;

        name = _name;
        symbol = _symbol;
    }

    function rate(
        address _token,
        uint256 _amount
    ) external view returns (uint256) {
        if (_token != tokenA && _token != tokenB) {
            revert InvalidToken();
        }

        uint256 ratio = (aLiquidity * 1e18) / bLiquidity;
        uint256 next_ratio;
        if (_token == tokenA) {
            next_ratio = ((aLiquidity - _amount) * 1e18) / bLiquidity;
            return (ratio - next_ratio) / 2 + next_ratio;
        } else {
            next_ratio = (aLiquidity * 1e18) / (bLiquidity - _amount);
            return (next_ratio - ratio) / 2 + ratio;
        }
    }

    function getLiquidity(
        address _token
    ) external view override returns (uint256) {
        if (_token != tokenA && _token != tokenB) {
            revert InvalidToken();
        }

        if (_token == tokenA) {
            return aLiquidity;
        } else {
            return bLiquidity;
        }
    }

    function getTokenA() external view returns (address) {
        return tokenA;
    }

    function getTokenB() external view returns (address) {
        return tokenB;
    }

    function swap(
        address _fromToken,
        uint256 _amountIn,
        uint256 _slippageTolerance
    ) external returns (uint256) {
        if (_fromToken != tokenA && _fromToken != tokenB) {
            revert InvalidToken();
        }

        uint256 swapRate = this.rate(_fromToken, _amountIn);
        if (swapRate > _slippageTolerance) {
            revert SlippageTooHigh();
        }

        uint256 amountOut;
        if (_fromToken == tokenA) {
            amountOut = (_amountIn * swapRate) / 1e18;
            aLiquidity += _amountIn;
            bLiquidity -= amountOut;

            IERC20(tokenB).transfer(msg.sender, amountOut);
        } else {
            amountOut = (_amountIn * 1e18) / swapRate;
            aLiquidity -= amountOut;
            bLiquidity += _amountIn;

            IERC20(tokenA).transfer(msg.sender, amountOut);
        }
        return amountOut;
    }

    function addLiquidity(address _token, uint256 _amount) external {
        if (_token != tokenA && _token != tokenB) {
            revert InvalidToken();
        }

        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);

        if (_token == tokenA) {
            aLiquidity += _amount;
        } else {
            bLiquidity += _amount;
        }
    }
}
