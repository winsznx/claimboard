// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Uclaimboard.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Uclaimboard registry = new Uclaimboard();
        
        console.log("Uclaimboard deployed to:", address(registry));
        
        vm.stopBroadcast();
    }
}
