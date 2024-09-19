//SPDX

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;


    struct NetworkConfig {
        address priceFeed;        
    }

    NetworkConfig public activeNetworkConfig;

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig.priceFeed = getSepoliaEthConfig().priceFeed;
        }else {
            activeNetworkConfig.priceFeed = getOrCreateAnvilConfig().priceFeed;        
        }
    }
    
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        // price feed address
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaEthConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory){
        // price feed address

        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }


        
        vm.startBroadcast();

        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS, 
            INITIAL_PRICE
            );
        vm.stopBroadcast();
        
        NetworkConfig memory anvilEthConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });

        return anvilEthConfig;
    }

}