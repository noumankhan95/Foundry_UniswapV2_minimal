//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

contract Factory {
    mapping(address pair_address => mapping(address _tokenA => address _tokenB)) s_contract_pair;

    function createPair(
        address _tokenA,
        address _tokenB,
        uint256 _reserveA,
        uint256 _reserveB
    ) external returns (address) {}

    function getPair(
        address _tokenA,
        address _tokenB
    ) external returns (address) {}

    function getAllPairs() external {}
}
