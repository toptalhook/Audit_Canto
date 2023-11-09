// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/Script.sol";
import "../src/bonding_curve/LinearBondingCurve.sol";
import "../src/Market.sol";
// import "../src/Contract.sol";

contract DeploymentScript is Script {
    // https://docs.canto.io/evm-development/contract-addresses
    // address constant NOTE = address(0x4e71A2E537B7f9D9413D3991D37958c0b5e1e503);
    address constant NOTE = address(0x03F734Bd9847575fDbE9bEaDDf9C166F880B5E5f);
    uint256 constant LINEAR_BONDING_CURVE_INCREASE = 1e18 / 1000;
    string constant ERC1155_URI = "https://tbd.com/{id}.json";

    function setUp() public {}

    function run() public {
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        LinearBondingCurve bondingCurve = new LinearBondingCurve(LINEAR_BONDING_CURVE_INCREASE);
        Market market = new Market(ERC1155_URI, NOTE);
        market.changeBondingCurveAllowed(address(bondingCurve), true);
        vm.stopBroadcast();
    }
}
