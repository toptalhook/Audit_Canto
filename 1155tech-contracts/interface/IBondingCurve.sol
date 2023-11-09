
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;
interface IBondingCurve {
    /// @notice Returns the price and fee for buying or selling a given number of shares.
    /// @param shareCount The number of shares in circulation. For buys, this is the amount after the first buy succeeds (e.g., 1 for the first ever buy).
    /// For sells, this is the amount before the sell is executed (e.g., 1 when the only remaining share is sold).
    /// @param amount The number of shares to buy or sell.
    function getPriceAndFee(uint256 shareCount, uint256 amount) external view returns (uint256 price, uint256 fee);

    /// @notice Returns the fee for buying or selling one share when the market has a given number of shares in circulation.
    /// @param shareCount The number of shares in circulation.
    function getFee(uint256 shareCount) external returns (uint256 fee);
}