// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
// import "../src/Contract.sol";

contract DeploymentScript is Script {
    // https://docs.canto.io/evm-development/contract-addresses
    address constant NOTE = address(0x4e71A2E537B7f9D9413D3991D37958c0b5e1e503);

    function setUp() public {}

    function run() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        // address contractToDeploy = new Contract();
        vm.stopBroadcast();
    }
}
