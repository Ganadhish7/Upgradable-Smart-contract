// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Proxy {
    address public owner;
    mapping(bytes4 => address) public implementationAddresses;

    mapping(address => uint256) public balances;

    event ImplementationUpdated(bytes4 indexed functionSelector, address indexed newImplementation);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function updateImplementation(bytes4 functionSelector, address newImplementation) public onlyOwner {
        require(newImplementation!= address(0), "New implementation address cannot be zero");
        implementationAddresses[functionSelector] = newImplementation;
        emit ImplementationUpdated(functionSelector, newImplementation);
    }

     function addImplementation(bytes4 functionSelector, address newImplementation) public onlyOwner {
    require(newImplementation != address(0), "New implementation address cannot be zero");
    implementationAddresses[functionSelector] = newImplementation;
    emit ImplementationUpdated(functionSelector, newImplementation);
   }

   function removeImplementation(bytes4 functionSelector) public onlyOwner{
    delete implementationAddresses[functionSelector];
    emit ImplementationUpdated(functionSelector, address(0));
   }

   fallback() external payable {
     bytes4 functionSelector = msg.sig;
     address implementation = implementationAddresses[functionSelector];
     // require(implementation != address(0), "No implementation found for this function");

     if(implementationAddresses[functionSelector] != address(0)){
      implementation = implementationAddresses[functionSelector];
     }

     assembly {
      // variable to load memory pointer
      // let ptr := mload(0x40)
      // copy s/(calldatesize()) bytes from calldata at position f/(0) to memory at position t/(ptr)
      calldatacopy(0, 0, calldatasize())

      // Delegate the call to the implementation contract
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
      
      // size of the last returndata
      // let size := returndatasize()

      // copy s/(size) bytes from returndata at position f/(0) to mem at position t/(ptr)
      returndatacopy(0, 0, returndatasize())

      // Handle the result of the delegatecall
      switch result
      case 0 {revert(0, returndatasize())} // If delegatecall failed, revert with the returned data
      default {return(0, returndatasize())}  // otherwise return the result
     }
   }

    // fallback() external payable {
    //     address implementation = address(0);
    //     bytes4 functionSelector = msg.sig;

    //     if (implementationAddresses[functionSelector]!= address(0)) {
    //         implementation = implementationAddresses[functionSelector];
    //     }

    //     assembly {
    //         let ptr := mload(0x40)
    //         calldatacopy(ptr, 0, calldatasize())
    //         let result := delegatecall(gas(), implementation, ptr, calldatasize(), 0, 0)
    //         let size := returndatasize()
    //         returndatacopy(ptr, 0, size)

    //         switch result
    //         case 0 { revert(ptr, size) }
    //         default { return(ptr, size) }
    //     }
    // }

    receive() external payable{
        balances[msg.sender] += msg.value;
    }
}
