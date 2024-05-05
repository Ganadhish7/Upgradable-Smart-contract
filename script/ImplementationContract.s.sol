// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {ImplementationContract} from "../src/ImplementationContract.sol";

contract ImplementationContractScript is Script {
 function run() external returns (ImplementationContract){
  vm.startBroadcast();

  ImplementationContract implementationContract = new ImplementationContract(99999);

  vm.stopBroadcast();

  return implementationContract;
 }
}