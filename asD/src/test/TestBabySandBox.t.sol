// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.7.0;
import {Setup} from "../contracts/Setup.sol";
import {BabySandboxAttacker} from "../contracts/BabySandboxAttacker.sol";
import {BabySandbox} from "../contracts/BabySandbox.sol";
import {Reciever} from "../BabyTest2/Reciever.sol";
import {Dummy} from "../BabyTest2/Dummy.sol";
import { console2 } from "forge-std/console2.sol";

import {DSTest} from "ds-test/test.sol";

contract TestBabySandBox is DSTest {
    Setup set;
    BabySandboxAttacker attacker;
    BabySandbox sandbox;
    Reciever reciever;
    Dummy dummy;

    function setUp() public {
        set = new Setup();
        attacker = new BabySandboxAttacker();
        sandbox = set.sandbox();
        // dummy = new Dummy();
        reciever = new Reciever(address(new Dummy()));
    }

    function test_attack() public {
        sandbox.run(address(attacker));
        assertTrue(set.isSolved());
    }

    function test_attack2() public {
        console2.logAddress(reciever.dummy());
        console2.logAddress(address(set.sandbox()));
        sandbox.run(address(reciever));
        console2.logBool(set.isSolved());
        // assertTrue(set.isSolved());
    }
}
