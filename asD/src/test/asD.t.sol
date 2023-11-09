// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;
import {asD} from "../asD.sol";
import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "forge-std/Test.sol";

contract MockERC20 is ERC20 {
    constructor(string memory symbol, string memory name) ERC20(symbol, name) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockCNOTE is MockERC20 {
    address public underlying;
    uint256 public exchangeRateCurrent = 1e28;

    constructor(
        string memory symbol,
        string memory name,
        address _underlying
    ) MockERC20(symbol, name) {
        underlying = _underlying;
    }

    function mint(uint256 amount) public returns (uint256 statusCode) {
        SafeERC20.safeTransferFrom(IERC20(underlying), msg.sender, address(this), amount);
        _mint(msg.sender, (amount * 1e28) / exchangeRateCurrent);
        statusCode = 0;
    }

    function redeemUnderlying(uint256 amount) public returns (uint256 statusCode) {
        SafeERC20.safeTransfer(IERC20(underlying), msg.sender, amount);
        _burn(msg.sender, (amount * exchangeRateCurrent) / 1e28);
        statusCode = 0;
    }

    function redeem(uint256 amount) public returns (uint256 statusCode) {
        SafeERC20.safeTransfer(IERC20(underlying), msg.sender, (amount * exchangeRateCurrent) / 1e28);
        _burn(msg.sender, amount);
        statusCode = 0;
    }

    function setExchangeRate(uint256 _exchangeRate) public {
        exchangeRateCurrent = _exchangeRate;
    }
}

contract asDFactory is Test {
    asD asdToken;
    MockERC20 NOTE;
    MockCNOTE cNOTE;
    string asDName = "Test";
    string asDSymbol = "TST";
    address owner;
    address alice;

    function setUp() public {
        NOTE = new MockERC20("NOTE", "NOTE");
        cNOTE = new MockCNOTE("cNOTE", "cNOTE", address(NOTE));
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        asdToken = new asD(asDName, asDSymbol, owner, address(cNOTE), owner);
    }

    function testMint() public {
        uint256 mintAmount = 10e18;
        NOTE.mint(address(this), mintAmount);
        uint256 initialBalance = NOTE.balanceOf(address(this));
        NOTE.approve(address(asdToken), mintAmount);
        asdToken.mint(mintAmount);
        assertEq(NOTE.balanceOf(address(this)), initialBalance - mintAmount);
        assertEq(asdToken.balanceOf(address(this)), mintAmount);
        assertEq(NOTE.balanceOf(address(cNOTE)), mintAmount);
    }

    function testBurn() public {
        testMint();
        uint256 initialBalanceNOTE = NOTE.balanceOf(address(this));
        uint256 initialBalanceASD = asdToken.balanceOf(address(this));
        uint256 initialBalanceNOTEcNOTE = NOTE.balanceOf(address(cNOTE));
        uint256 burnAmount = 6e18;
        asdToken.burn(burnAmount);
        assertEq(NOTE.balanceOf(address(this)), initialBalanceNOTE + burnAmount);
        assertEq(asdToken.balanceOf(address(this)), initialBalanceASD - burnAmount);
        assertEq(NOTE.balanceOf(address(cNOTE)), initialBalanceNOTEcNOTE - burnAmount);
    }

    function testWithdrawCarry() public {
        testMint();
        uint256 newExchangeRate = 1.1e28;
        cNOTE.setExchangeRate(newExchangeRate);
        uint256 initialBalance = NOTE.balanceOf(owner);
        uint256 asdSupply = asdToken.totalSupply();
        // Should be able to withdraw 10%
        uint256 withdrawAmount = asdSupply / 10;
        vm.prank(owner);
        asdToken.withdrawCarry(withdrawAmount);
        assertEq(NOTE.balanceOf(owner), initialBalance + withdrawAmount);
    }

    function testWithdrawCarryWithZeroAmount() public {
        testMint();
        uint256 newExchangeRate = 1.1e28;
        cNOTE.setExchangeRate(newExchangeRate);
        uint256 initialBalance = NOTE.balanceOf(owner);
        uint256 asdSupply = asdToken.totalSupply();
        // Should be able to withdraw 10%
        uint256 maxWithdrawAmount = asdSupply / 10;
        vm.prank(owner);
        asdToken.withdrawCarry(0);
        assertEq(NOTE.balanceOf(owner), initialBalance + maxWithdrawAmount);
    }

    function testWithdrawCarryTooMuch() public {
        testMint();
        uint256 newExchangeRate = 1.1e28;
        cNOTE.setExchangeRate(newExchangeRate);
        uint256 asdSupply = asdToken.totalSupply();
        // Should be able to withdraw 10%
        uint256 withdrawAmount = asdSupply / 10 + 1;
        vm.prank(owner);
        vm.expectRevert("Too many tokens requested");
        asdToken.withdrawCarry(withdrawAmount);
    }

    function testWithdrawCarryNonOwner() public {
        uint256 withdrawAmount = 2000;
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        asdToken.withdrawCarry(withdrawAmount);
    }
}
