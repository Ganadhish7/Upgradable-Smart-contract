// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ImplementationContract} from "../src/ImplementationContract.sol";

// Define a contract named ImplementationContractScript that inherits from a base contract named Script.
 contract ImplementationContractScript is Script {

  // Define a function named run that can be called externally
  function run() external returns (ImplementationContract){
   // Start a broadcast on the virtual machine (vm).
   vm.startBroadcast();
   // Create a new instance of the Proxy contract.
   ImplementationContract implementationContract = new ImplementationContract(99999);
   // Stop the broadcast on the virtual machine (vm).
   vm.stopBroadcast();
   // Return the newly created Proxy instance.
   return implementationContract;
  }
 }