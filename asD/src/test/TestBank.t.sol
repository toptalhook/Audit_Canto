// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.5;
import {Setup} from "../BankTest/Setup.sol";
import {Bank} from "../BankTest/Bank.sol";
import {exploit} from "../BankTest/Exploit.sol";
import { console2 } from "forge-std/console2.sol";

import {DSTest} from "ds-test/test.sol";

contract TestBank is DSTest {
    Setup set;
    Bank bank;
    exploit exploit;

    function setUp() public {
        set = new Setup();
        exploit = new Exploit(set);
    }

    function test_test_attack() public {
        exploit.attack();
        assertTrue(set.isSolved());
    }

    // function test_attack2() public {
    //     console2.logAddress(reciever.dummy());
    //     console2.logAddress(address(set.sandbox()));
    //     sandbox.run(address(reciever));
    //     console2.logBool(set.isSolved());
    //     // assertTrue(set.isSolved());
    // }
}
