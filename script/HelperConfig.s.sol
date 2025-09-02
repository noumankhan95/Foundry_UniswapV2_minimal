//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

contract HelperConfig {
    struct networkConfig {
        uint256 chainId;
        address account;
    }
    uint256 constant ETH_CHAIN_ID = 1;
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ANVIL_CHAIN_ID = 31337;
    mapping(uint256 => networkConfig) config;

    function run() public {
        config[ETH_CHAIN_ID] = getEthereumConfig();
        config[SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        config[ANVIL_CHAIN_ID] = getAnvilConfig();
    }

    function returnConfig(
        uint256 _chainId
    ) public view returns (networkConfig memory) {
        if (_chainId == ETH_CHAIN_ID) {
            return config[ETH_CHAIN_ID];
        } else if (_chainId == SEPOLIA_CHAIN_ID) {
            return config[SEPOLIA_CHAIN_ID];
        } else {
            return config[ANVIL_CHAIN_ID];
        }
    }

    function getEthereumConfig() internal pure returns (networkConfig memory) {
        return
            networkConfig({
                chainId: 1,
                account: 0xBABdA7A7df0b74578E639a7FE470D4d780E55079
            });
    }

    function getSepoliaEthConfig()
        internal
        pure
        returns (networkConfig memory)
    {
        return
            networkConfig({
                chainId: 11155111,
                account: 0xBABdA7A7df0b74578E639a7FE470D4d780E55079
            });
    }

    function getAnvilConfig() internal pure returns (networkConfig memory) {
        return
            networkConfig({
                chainId: 31337,
                account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
            });
    }
}
