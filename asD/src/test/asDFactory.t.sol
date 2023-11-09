// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;
import {asDFactory} from "../asDFactory.sol";
import {asD} from "../asD.sol";
import {DSTest} from "ds-test/test.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory symbol, string memory name) ERC20(symbol, name) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract asDFactoryTest is DSTest {
    asDFactory factory;
    MockERC20 cNOTE;
    string asDName = "Test";
    string asDSymbol = "TST";

    function setUp() public {
        cNOTE = new MockERC20("cNOTE", "cNOTE");
        factory = new asDFactory(address(cNOTE));
    }

    function test_create_asD() public {
        address asDAddress = factory.create(asDName, asDName);
        assertNotEq(asDAddress, address(0));
    }

    function test_registry() public {
        address asDAddress = factory.create(asDName, asDName);
        assertNotEq(asDAddress, address(0));
        assertTrue(factory.isAsD(asDAddress));
    }

    function test_token_metadata() public {
        address asDAddress = factory.create(asDName, asDSymbol);
        assertNotEq(asDAddress, address(0));
        asD asdToken = asD(asDAddress);
        assertEq(asdToken.symbol(), asDSymbol);
        assertEq(asdToken.name(), asDName);
    }

    function test_token_owner() public {
        address asDAddress = factory.create(asDName, asDSymbol);
        assertNotEq(asDAddress, address(0));
        asD asdToken = asD(asDAddress);
        assertEq(asdToken.owner(), address(this));
    }
}
