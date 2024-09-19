//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    
    function run() external returns (FundMe){

        //antes de starBrodcast no es una transacción "real" es simulada 
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFee = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe _fundMe = new FundMe(ethUsdPriceFee);
        vm.stopBroadcast();
        return _fundMe;

    }
        
}