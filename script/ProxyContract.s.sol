// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Proxy} from "../src/ProxyContract.sol";

// Define a contract named ProxyContractScript that inherits from a base contract named Script.
contract ProxyContractScript is Script{

  // Define a function named run that can be called externally (from outside the contract).
  function run() external returns (Proxy){
    // Start a broadcast on the virtual machine (vm).
    vm.startBroadcast();
    // Create a new instance of the Proxy contract.
    Proxy proxy = new Proxy();
    // Stop the broadcast on the virtual machine (vm).
    vm.stopBroadcast();
    // Return the newly created Proxy instance.
    return proxy;
  }
}