pragma solidity >= 0.7.0;

contract Reciever {

  address public dummy;

  constructor(address _dummy) {
    dummy = _dummy;
  }
  fallback() external {
    address test = dummy;
    assembly {
      // hardcode the Destroyer's address here before deploying Receiver
      
      switch call(gas(), 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a, 0x00, 0x00, 0x00, 0x00, 0x00)
        case 0 {
          return(0x00, 0x00)
        }
        case 1 {
          selfdestruct(0)
        }
    }
  }
}