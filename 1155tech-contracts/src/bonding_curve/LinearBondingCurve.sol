// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.19;

import {IBondingCurve} from "../../interface/IBondingCurve.sol";

contract LinearBondingCurve is IBondingCurve {
    // By how much the price increases per share, provided in the token decimals
    uint256 public immutable priceIncrease;

    constructor(uint256 _priceIncrease) {
        priceIncrease = _priceIncrease;
    }

    function getPriceAndFee(uint256 shareCount, uint256 amount)
        external
        view
        override
        returns (uint256 price, uint256 fee)
    {
        for (uint256 i = shareCount; i < shareCount + amount; i++) {
            uint256 tokenPrice = priceIncrease * i;
            price += tokenPrice;
            fee += (getFee(i) * tokenPrice) / 1e18;
        }
    }

    function getFee(uint256 shareCount) public pure override returns (uint256) {
        uint256 divisor;
        if (shareCount > 1) {
            divisor = log2(shareCount);
        } else {
            divisor = 1;
        }
        // 0.1 / log2(shareCount)
        return 1e17 / divisor;
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    /// Returns 0 if `x` is zero.
    /// @notice Copied from Solady: https://github.com/Vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // forgefmt: disable-next-item
            r := or(
                r,
                byte(
                    and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                    0x0706060506020504060203020504030106050205030304010505030400000000
                )
            )
        }
    }
}
