//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract Engine is ERC20 {
    address public token0;
    address public token1;

    uint112 private reserve0; // balance of token0
    uint112 private reserve1; // balance of token1

    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    constructor(address _token0, address _token1) ERC20("LP Token", "LPT") {
        token0 = _token0;
        token1 = _token1;
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function getReserves() public view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    /// @notice mint LP tokens for providing liquidity
    function mint(address to) external returns (uint liquidity) {
        (uint112 reserveA, uint112 reserveB) = getReserves();
        uint balanceA = IERC20(token0).balanceOf(address(this));
        uint balanceB = IERC20(token1).balanceOf(address(this));
        uint amountA = balanceA - reserveA;
        uint amountB = balanceB - reserveB;
        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = sqrt(amountA * amountB) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // lock permanently
        } else {
            liquidity = min(
                (amountA * _totalSupply) / reserve0,
                (amountB * _totalSupply) / reserve1
            );
        }
        require(liquidity > 0, "Insufficient liquidity minted");
        _mint(to, liquidity);

        _update(balanceA, balanceB);
    }

    /// @notice burn LP tokens to remove liquidity
    function burn(address to) external returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1) = getReserves();
        address _token0 = token0;
        address _token1 = token1;

        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));

        uint liquidity = balanceOf(address(this));

        uint _totalSupply = totalSupply();

        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;

        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity burned");

        _burn(address(this), liquidity);
        IERC20(_token0).transfer(to, amount0);
        IERC20(_token1).transfer(to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1);
    }

    /// @notice swap between token0 and token1
    function swap(uint amount0Out, uint amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output");
        (uint112 _reserve0, uint112 _reserve1) = getReserves();

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "Insufficient liquidity"
        );

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "Insufficient input");

        // enforce constant product k = xy
        require(balance0 * balance1 >= uint(_reserve0) * uint(_reserve1), "K");

        _update(balance0, balance1);
    }

    /// @dev simple helpers
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint) {
        return x < y ? x : y;
    }
}
