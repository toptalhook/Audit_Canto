pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../bonding_curve/LinearBondingCurve.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LinearBondingCurveTest is Test {
    LinearBondingCurve bondingCurve;
    uint256 constant LINEAR_INCREASE = 1e18 / 1000;

    function setUp() public {
        bondingCurve = new LinearBondingCurve(LINEAR_INCREASE);
    }

    function testGetPriceSingle() public {
        (uint256 price, uint256 fee) = bondingCurve.getPriceAndFee(1, 1);
        assertEq(price, LINEAR_INCREASE);
        assertEq(fee, LINEAR_INCREASE / 10);
    }

    function testGetPriceMultiple() public {
        (uint256 price, uint256 fee) = bondingCurve.getPriceAndFee(1, 4);
        assertEq(price, LINEAR_INCREASE + 2 * LINEAR_INCREASE + 3 * LINEAR_INCREASE + 4 * LINEAR_INCREASE);
        assertEq(
            fee,
            LINEAR_INCREASE / 10 + (2 * LINEAR_INCREASE) / 10 + (3 * LINEAR_INCREASE) / 10 + (4 * LINEAR_INCREASE) / 20
        );
    }
}
