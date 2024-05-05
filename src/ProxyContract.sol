// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Proxy
 * @dev This is a proxy contract that maintains a registry of implementation addresses for 
 * different functionalities and implements a fallback function that delegates calls to the 
 * corresponding contract address.
 */

contract Proxy {
    //  Stores the address of the contract owner, who has the authority to update the registry.
    address public owner;

    // A mapping from bytes4 function selectors to address of the implementation contracts.
    mapping(bytes4 => address) public implementationAddresses;
    
    // A mapping from address to keep a track of balances.
    mapping(address => uint256) public balances;

    // Emitted whenever an implementation address is updated, added, or removed from the registry.
    event ImplementationUpdated(bytes4 indexed functionSelector, address indexed newImplementation);

    // Initializes the owner to the address deploying the contract, ensuring that only the deployer can manage the registry.
    constructor() {
        owner = msg.sender;
    }

    // A modifier that restricts access to certain functions (like updating the registry) to the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Allows the owner to update an existing implementation address for a specific function.
    function updateImplementation(bytes4 functionSelector, address newImplementation) public onlyOwner {
        require(newImplementation!= address(0), "New implementation address cannot be zero");
        implementationAddresses[functionSelector] = newImplementation;
        emit ImplementationUpdated(functionSelector, newImplementation);
    }

    // Allows the owner to add a new implementation address for a specific function.
    function addImplementation(bytes4 functionSelector, address newImplementation) public onlyOwner {
        require(newImplementation != address(0), "New implementation address cannot be zero");
        implementationAddresses[functionSelector] = newImplementation;
        emit ImplementationUpdated(functionSelector, newImplementation);
    }

    // Allows the owner to remove an implementation address for a specific function.
    function removeImplementation(bytes4 functionSelector) public onlyOwner{
        delete implementationAddresses[functionSelector];
        emit ImplementationUpdated(functionSelector, address(0));
    }

    // Fallback function using "delegatecall" to execute the function in the context of the proxy contract.
    fallback() external payable {
        bytes4 functionSelector = msg.sig;
        address implementation = implementationAddresses[functionSelector];

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

    // To receive tokens or ETH from the EOA's
    receive() external payable{
        balances[msg.sender] += msg.value;
    }
}
