// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StreamToken.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        StreamToken token = new StreamToken(
            address(0x31aC7b9Efef929d44F432d51C00bE13F206b85e8),
            "Metapebble Demo Stream Token",
            "MDST"
        );

        vm.stopBroadcast();
    }
}
