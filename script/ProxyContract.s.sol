// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Proxy} from "../src/ProxyContract.sol";

contract ProxyContractScript is Script{
  function run() external returns (Proxy){
    vm.startBroadcast();

    Proxy proxy = new Proxy();

    vm.stopBroadcast();

    return proxy;
  }
}