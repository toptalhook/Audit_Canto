// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import {Turnstile} from "../interface/Turnstile.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {asD} from "./asD.sol";

contract asDFactory is Ownable2Step {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    address public immutable cNote;

    /// @notice Stores the addresses of all created tokens, allowing third-party contracts to check if an address is a legit token
    mapping(address => bool) public isAsD;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreatedToken(address token, string symbol, string name, address creator);

    /// @notice Initiates CSR on main- and testnet
    /// @param _cNote Address of the cNOTE token
    constructor(address _cNote) {
        cNote = _cNote;
        if (block.chainid == 7700 || block.chainid == 7701) {
            // Register CSR on Canto main- and testnet
            Turnstile turnstile = Turnstile(0xEcf044C5B4b867CFda001101c617eCd347095B44);
            turnstile.register(tx.origin);
        }
    }

    function create(string memory _name, string memory _symbol) external returns (address) {
        asD createdToken = new asD(_name, _symbol, msg.sender, cNote, owner());
        isAsD[address(createdToken)] = true;
        emit CreatedToken(address(createdToken), _symbol, _name, msg.sender);
        return address(createdToken);
    }
}
