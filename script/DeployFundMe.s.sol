// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed)=helperConfig.activeNetworkConfig();
        console.log(ethUsdPriceFeed);
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return (fundme);
    }
}
