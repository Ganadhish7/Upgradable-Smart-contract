// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../src/ProxyContract.sol";
import "../src/ImplementationContract.sol";

// Define a contract named ProxyTest for testing the functionality of a proxy contract.
contract ProxyTest  {
    // Declare a variable to hold an instance of the Proxy contract.
    Proxy proxy;

    // Setup function to initialize the proxy instance before each test.
    function setUp() public {
        // Create a new instance of the Proxy contract.
        proxy = new Proxy();
    }

    // Test function to verify adding a new implementation address to the proxy.
    function testAddImplementation() public {
        // Calculate the function selector for the "transfer" function using keccak256.
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));

        // Create a new instance of the ImplementationContract with a specific address.
        address newImplementation = address(new ImplementationContract(0x123));

        // Add the new implementation to the proxy for the specified function.
        proxy.addImplementation(functionSelector, newImplementation);

        // Retrieve the implementation address for the specified function from the proxy.
        address implementationAddress = proxy.implementationAddresses(functionSelector);

        // Assert that the implementation address added is the expected one.
        require(implementationAddress == newImplementation, "Implementation address should be Added");
    }

     // Test function to verify updating an existing implementation address in the proxy.
    function testUpdateImplementation() public {
        // Similar to testAddImplementation, but this time updating an existing implementation.
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));

        // Create a new instance of the ImplementationContract with a specific address.
        address newImplementation = address(new ImplementationContract(0x123));

        // Update the implementation for the specified function in the proxy.
        proxy.updateImplementation(functionSelector, newImplementation);

        // Retrieve the implementation address for the specified function from the proxy.
        address implementationAddress = proxy.implementationAddresses(functionSelector);

        // Assert that the implementation address has been updated to the expected one.
        require(implementationAddress == newImplementation, "Implementation address should be updated");
    }

     // Test function to verify removing an implementation address from the proxy.
    function testRemoveImplementation() public {
        // Similar to testAddImplementation, but this time removing the implementation.
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));

        // Create a new instance of the ImplementationContract with a specific address.
        address newImplementation = address(new ImplementationContract(0x123));

        // Add the new implementation to the proxy for the specified function.
        proxy.addImplementation(functionSelector, newImplementation);

        // Remove the implementation for the specified function from the proxy.
        proxy.removeImplementation(functionSelector);

        // Retrieve the implementation address for the specified function from the proxy.
        address implementationAddress = proxy.implementationAddresses(functionSelector);

        // Assert that the implementation address has been removed.
        require(implementationAddress == address(0), "Implementation address should be removed");
    }


     // Test function to verify fallback function delegation to the correct implementation.
    function testFallbackDelegation() public {
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));
        // address newImplementation = address(new ImplementationContract(1000));

        // proxy.addImplementation(functionSelector, newImplementation); 

        // Simulate a call to the proxy contract's fallback function with the transfer function selector
        (bool success, ) = address(proxy).call(abi.encodeWithSelector(functionSelector, address(proxy), 0x123));

        // Use require for assertion
        require(success, "Fallback function should successfully delegate the call");
    }
}
