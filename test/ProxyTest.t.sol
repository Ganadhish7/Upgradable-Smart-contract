// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../src/ProxyContract.sol";
import "../src/ImplementationContract.sol";

contract ProxyTest  {
    Proxy proxy;

    function setUp() public {
        proxy = new Proxy();
    }

    // Test adding a new implementation address
    function testAddImplementation() public {
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));
        address newImplementation = address(new ImplementationContract(0x123));

        proxy.addImplementation(functionSelector, newImplementation);

        // Instead, you can use Solidity's require statement for assertions
        // For example, to assert that the implementation address is updated:
        address implementationAddress = proxy.implementationAddresses(functionSelector);
        require(implementationAddress == newImplementation, "Implementation address should be Added");
    }

    // Test Updating an existing implementation address 
    function testUpdateImplementation() public{
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));
        address newImplementation = address(new ImplementationContract(0x123));

        proxy.updateImplementation(functionSelector, newImplementation);

        address implementationAddress = proxy.implementationAddresses(functionSelector);
        require(implementationAddress == newImplementation, "Implementation address should be updated");
    }

    // Test removing an implementation address
    function testRemoveImplementation() public {
        bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));
        address newImplementation = address(new ImplementationContract(0x123));

        proxy.addImplementation(functionSelector, newImplementation);
        proxy.removeImplementation(functionSelector);

        address implementationAddress = proxy.implementationAddresses(functionSelector);
        require(implementationAddress == address(0), "Implementation address should be removed");
    }

    // Test fallback function delegation
    // function testFallbackDelegation() public{
    //  bytes4 functionSelector = bytes4(keccak256("transfer(address,uint256)"));
    //  address newImplementation = address(new ImplementationContract(1000));

    //  proxy.addImplementation(functionSelector, newImplementation);

    //  // Simulate a call to the proxy contract 
    //  (bool success, ) = address(proxy).call(abi.encodeWithSignature("transfer(address,uint256)", address(0x123), 1000));

    //  // use require for assertion
    //  require(success, "Fallback function should successfully delegate the call");
    // }

    // Test fallback function delegation
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
