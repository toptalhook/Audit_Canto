// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

interface IasDFactory {
    function create(string memory _symbol, string memory _name) external;

    function note() external view returns (address);
}
