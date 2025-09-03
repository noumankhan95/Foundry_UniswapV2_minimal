//SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;
import "./Engine.sol";
import "./Factory.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

contract Router {
    Factory public factory;

    constructor(Factory _factory) {
        factory = _factory;
    }

    function AddLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _reserveA,
        uint256 _reserveB
    ) public {
        address pair = factory.getPair(_tokenA, _tokenB);
        if (pair == address(0)) {
            console.log("Pair is zero");
            (address token0, address token1) = sortTokens(_tokenA, _tokenB);
            pair = factory.createPair(token0, token1, _reserveA, _reserveB);
        }

        IERC20(_tokenA).transferFrom(msg.sender, pair, _reserveA);
        IERC20(_tokenB).transferFrom(msg.sender, pair, _reserveB);
        Engine(pair).mint(msg.sender);
    }

    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint liquidity
    ) public {
        address pair = factory.getPair(_tokenA, _tokenB);
        IERC20(pair).transferFrom(msg.sender, address(pair), liquidity);
        (uint amount0, uint amount1) = Engine(pair).burn(msg.sender);
    }

    function swapExactTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutmin,
        address _to
    ) public {
        address pair = factory.getPair(_tokenIn, _tokenOut);
        require(pair != address(0), "Pool does not exist");
        IERC20(_tokenIn).transferFrom(msg.sender, pair, _amountIn);

        (address token0, ) = sortTokens(_tokenIn, _tokenOut);
        (uint reserve0, uint reserve1) = Engine(pair).getReserves();

        uint amountOut;
        if (_tokenIn == token0) {
            amountOut = getAmountOut(_amountIn, reserve0, reserve1);
            require(amountOut >= _amountOutmin, "Slippage");
            Engine(pair).swap(0, amountOut, _to);
        } else {
            amountOut = getAmountOut(_amountIn, reserve1, reserve0);
            require(amountOut >= _amountOutmin, "Slippage");
            Engine(pair).swap(amountOut, 0, _to);
        }
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure returns (uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");

        uint amountInWithFee = amountIn * 997; // 0.3% fee
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function sortTokens(
        address tokenA,
        address tokenB
    ) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ZERO_ADDRESS");
    }
}
