pragma solidity 0.7.0;

contract Dummy {
  fallback() external {
    selfdestruct(address(0));
  }
}