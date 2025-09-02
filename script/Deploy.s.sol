//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Engine} from "src/Engine.sol";
import {Factory} from "src/Factory.sol";
import {Router} from "src/Router.sol";

contract DeployContract is Script {
    function run()
        public
        returns (HelperConfig.networkConfig memory, Router, Factory)
    {
        HelperConfig hconfig = new HelperConfig();
        hconfig.run();
        HelperConfig.networkConfig memory config = hconfig.returnConfig(
            block.chainid
        );
        vm.startBroadcast(config.account);
        Factory factory = new Factory();
        Router router = new Router(factory);
        vm.stopBroadcast();
        return (config, router, factory);
    }
}
