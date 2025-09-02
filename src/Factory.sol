//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;
import "./Engine.sol";

contract Factory {
    //ERRORS
    error Factory__Address0();
    error Factory__TokensIdentical();
    error Factory__PairExists();

    //Events

    event PairCreated(address _tokenA, address _tokenB);
    mapping(address pair_address => mapping(address _tokenA => address _tokenB)) s_contract_pair;
    address[] public s_AllPairs;

    function createPair(
        address _tokenA,
        address _tokenB,
        uint256 _reserveA,
        uint256 _reserveB
    ) external returns (address) {
        require(
            _tokenA != address(0) && _tokenB != address(0),
            Factory__Address0()
        );
        require(_tokenA != _tokenB, Factory__TokensIdentical());
        require(
            s_contract_pair[_tokenA][_tokenB] == address(0) &&
                s_contract_pair[_tokenB][_tokenA] == address(0),
            Factory__PairExists()
        );
        Engine pair = new Engine(_tokenA, _tokenB);
        s_contract_pair[_tokenA][_tokenB] = address(pair);
        s_contract_pair[_tokenB][_tokenA] = address(pair);
        s_AllPairs.push(address(pair));
        emit PairCreated(_tokenA, _tokenB);
    }

    function getPair(
        address _tokenA,
        address _tokenB
    ) external view returns (address) {
        return s_contract_pair[_tokenA][_tokenB];
    }

    function getAllPairs() external {}
}
