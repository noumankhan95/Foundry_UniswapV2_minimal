//SPDX-License-Identifier:MIT
pragma solidity 0.8.24;
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Engine} from "src/Engine.sol";
import {Factory} from "src/Factory.sol";
import {Router} from "src/Router.sol";
import {DeployContract} from "script/Deploy.s.sol";
import {Script} from "forge-std/Script.sol";
import {USDTMock} from "./Mocks/USDT.sol";
import {WETHMock} from "./Mocks/Weth.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {console} from "forge-std/console.sol";

contract UnitTest is Script {
    Router router;
    Factory factory;
    HelperConfig.networkConfig config;
    address user;
    USDTMock usdt;
    WETHMock weth;

    function setUp() public {
        DeployContract deploy = new DeployContract();
        usdt = new USDTMock();
        weth = new WETHMock();
        (config, router, factory) = deploy.run();
        user = makeAddr("user");
        vm.deal(user, 1000 ether);
        usdt.mint(user, 60000e18);
        weth.mint(user, 1000 ether);
    }

    function testIsLiquiditySet() public {
        console.log(address(usdt));
        console.log(address(weth));
        console.log(weth.balanceOf(user));
        console.log(usdt.balanceOf(user));
        vm.startPrank(user);
        weth.approve(address(router), 10 ether);
        usdt.approve(address(router), 50000e18);

        router.AddLiquidity(address(weth), address(usdt), 10, 50000e18);
        address pair = factory.getPair(address(weth), address(usdt));
        console.log(pair);
        // IERC20(pair).balanceOf(usdt);
        vm.stopPrank();
        assert(pair != address(0));
    }
}
