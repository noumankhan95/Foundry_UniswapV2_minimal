//SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;
import "./Engine.sol";
import "./Factory.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

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
            pair = factory.createPair(_tokenA, _tokenB, _reserveA, _reserveB);
        }
        IERC20(_tokenA).transferFrom(msg.sender, pair, _reserveA);
        IERC20(_tokenB).transferFrom(msg.sender, pair, _reserveB);
        Engine(pair).mint(msg.sender);
    }

    function swapExactTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _to
    ) public {
        address pair = factory.getPair(_tokenIn, _tokenOut);
        require(pair != address(0), "Pool does not exist");
        IERC20(_tokenIn).transferFrom(msg.sender, pair, _amountIn);
        Engine(pair).swap(_tokenIn, _amountIn, _to);
    }
}
