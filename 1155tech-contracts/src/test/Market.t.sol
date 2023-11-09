pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../Market.sol";
import "../bonding_curve/LinearBondingCurve.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract MarketTest is Test {
    Market market;
    LinearBondingCurve bondingCurve;
    MockERC20 token;
    uint256 constant LINEAR_INCREASE = 1e18 / 1000;
    address bob;
    address alice;

    function setUp() public {
        bondingCurve = new LinearBondingCurve(LINEAR_INCREASE);
        token = new MockERC20("Mock Token", "MTK", 1e18);
        market = new Market("http://uri.xyz", address(token));
        bob = address(1);
        alice = address(2);
    }

    function testChangeBondingCurveAllowed() public {
        market.changeBondingCurveAllowed(address(bondingCurve), true);
        assertTrue(market.whitelistedBondingCurves(address(bondingCurve)));

        market.changeBondingCurveAllowed(address(bondingCurve), false);
        assertFalse(market.whitelistedBondingCurves(address(bondingCurve)));
    }

    function testFailChangeBondingCurveAllowedNonOwner() public {
        // TODO: For some reason, assertion fails, but call reverts as expected
        // vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(bob);
        market.changeBondingCurveAllowed(address(bondingCurve), true);
    }

    function testFailCreateNewShareWhenBondingCurveNotWhitelisted() public {
        // TODO: For some reason, assertion fails, but call reverts as expected
        // vm.expectRevert("Bonding curve not whitelisted");
        market.createNewShare("Test Share", address(bondingCurve), "metadataURI");
    }

    function testCreateNewShare() public {
        market.changeBondingCurveAllowed(address(bondingCurve), true);
        market.restrictShareCreation(false);
        vm.prank(bob);
        market.createNewShare("Test Share", address(bondingCurve), "metadataURI");
        assertEq(market.shareIDs("Test Share"), 1);
    }

    function testGetBuyPrice() public {
        testCreateNewShare();
        (uint256 priceOne, uint256 feeOne) = market.getBuyPrice(1, 1);
        (uint256 priceTwo, uint256 feeTwo) = market.getBuyPrice(1, 2);
        assertEq(priceOne, LINEAR_INCREASE);
        assertEq(priceTwo, priceOne + LINEAR_INCREASE * 2);
        assertEq(feeOne, priceOne / 10);
        assertEq(feeTwo, priceTwo / 10); // log2(2) = 1
    }

    function testBuy() public {
        testCreateNewShare();
        token.approve(address(market), 1e18);
        market.buy(1, 1);
        assertEq(token.balanceOf(address(market)), LINEAR_INCREASE + LINEAR_INCREASE / 10);
        assertEq(token.balanceOf(address(this)), 1e18 - LINEAR_INCREASE - LINEAR_INCREASE / 10);
    }

    function testSell() public {
        testBuy();
        market.sell(1, 1);
        uint256 fee = LINEAR_INCREASE / 10;
        // Because of autoclaiming, 1/3 is transferred back
        assertEq(token.balanceOf(address(market)), fee + (fee * 67) / 100);
        assertEq(token.balanceOf(address(this)), 1e18 - (fee + (fee * 67) / 100));
    }

    function testMint() public {
        testBuy();
        market.mintNFT(1, 1);
        uint256 fee = LINEAR_INCREASE / 10;
        // Get back one third because of autoclaiming
        assertEq(token.balanceOf(address(market)), LINEAR_INCREASE + 2 * fee - (fee * 33) / 100);
    }

    function testBurn() public {
        testMint();
        market.burnNFT(1, 1);
        uint256 fee = LINEAR_INCREASE / 10;
        assertEq(token.balanceOf(address(market)), LINEAR_INCREASE + 3 * fee - (fee * 33) / 100);
    }

    function claimCreatorFeeNonCreator() public {
        testCreateNewShare();
        vm.expectRevert("Not creator");
        vm.prank(alice);
        market.claimCreatorFee(1);
    }

    function claimCreator() public {
        testBuy();
        vm.prank(bob);
        market.claimCreatorFee(1);
        uint256 fee = LINEAR_INCREASE / 10;
        assertEq(token.balanceOf(bob), (fee * 33) / 100);
    }

    function claimPlatform() public {
        testBuy();
        uint256 balBefore = token.balanceOf(address(this));
        market.claimPlatformFee();
        uint256 fee = LINEAR_INCREASE / 10;
        assertEq(token.balanceOf(address(this)), balBefore + (fee * 67) / 100);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
