## Task 2: Proxy Contract for Load Balancing and Function Delegation

# Index

- [Introduction](#introduction)
  - [Architecture](#architecture)
  - [Implementation](#implementation)
  - [Interaction](#interaction)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)

# Introduction

## Architecture

- What is a Proxy Contract?

A proxy contract is a contract that acts as an intermediary between the end user and the actual logic contract (implementation contract). It stores the states of the current implementation contract and forwards calls to it. Proxy contracts are used for upgradability because they allow the logic contract to be swapped out without changing the contract's address, and preserving its state and interactions.

![Proxy Contract](/public/Proxy%20architecture.drawio.png)

- What is an Upgradable Smart contract?

Proxy contract is a type of Upgradable smart contract, An Upgradable smart contract is a type of smart contract that allows for changes to its business logic while preserving its state. Upgradability is achieved by using few patterns like proxy contracts, implementation contracts. These methods enable the creation of new versions of the contract or the delegation of function calls to different contracts, allowing for modification of the contract's behavior without changing its address or state.

- What are the types of Upgradable smart contracts?

There are several types of upgradable smart contracts, primarily distinguished by the proxy pattern they use:

1. Migrations: This type of upgrading a smart contract is to deploy a new smart contract on the blockchain and telling the users to not use the old one and shift to the new smart contract, which might left few users keep using the old version and not getting informed about the currently upgraded contract.

2. Transparent Proxy: This pattern involves a proxy contract that forwards calls to an implementation contract. The proxy contract stores the address of the current implementation contract and delegates calls to it. When an upgrade is needed, a new implementation contract is deployed, and the proxy contract's address is updated to point to the new contract. This method is straightforward but requires the proxy contract to be aware of the implementation contract's address.

3. UUPS (Universal Upgradeable Proxy Standard): This is a more advanced pattern that allows for upgrades without changing the proxy contract's address. It uses a mechanism where the proxy contract itself can be upgraded, enabling the storage of the new implementation contract's address within the proxy. This pattern provides greater flexibility and security compared to the transparent proxy pattern.

4. Diamond Pattern: This pattern involves a single proxy contract that delegates calls to multiple implementation contracts based on the function being called. Each implementation contract contains a specific set of functions. This pattern is useful for contracts that require a modular architecture, allowing for the addition or removal of functionalities without redeploying the entire contract.

- What is an implementation contract?

An implementation contract (also known as a logic contract) contains the actual business logic of the smart contract. It is the contract that performs the desired operations when called by the proxy contract. In the context of upgradable smart contracts, multiple versions of the implementation contract can exist, allowing for the upgrade of the contract's functionality without affecting its state or address.

- What is a delegatecall function? 

The delegatecall function is a low-level function in Solidity that allows a contract to execute code from another contract while preserving the context of the calling contract. This means that the called contract's code is executed in the context of the calling contract, including using its storage and message sender. This feature is particularly useful in upgradable smart contracts, where it allows the proxy contract to delegate calls to the implementation contract while maintaining the original contract's state and identity.

![delegatecall](/public/Delegate%20call%20architecture.drawio.png)

- What is a fallback function?

A fallback function in Solidity is a special function that is executed when a contract receives plain Ether (without data) or when a function call is made to the contract but no matching function exists. The fallback function can be used to handle unexpected inputs or to provide a default behavior for the contract. In the context of upgradable smart contracts, the fallback function can be used to ensure that the contract behaves correctly even if an upgrade introduces changes that affect existing interactions .

- What is the assembly block in the solidity contract?

The assembly block in a Solidity contract refers to a section of the contract where low-level assembly language instructions are written. Assembly language provides direct access to the Ethereum Virtual Machine (EVM) and allows for operations that are not directly supported by Solidity's high-level syntax. While Solidity abstracts away many of the complexities of the EVM, the assembly block can be used for performance optimizations, complex computations, or when interacting with other contracts in a very specific way.

- How does the EVM(Ethereum Virtual Machine) stores the variables?

The Ethereum Virtual Machine (EVM) stores data in a system of storage slots, each capable of holding 256 bits (32 bytes) of data. These slots are numbered from 0 to (2^{256} - 1), allowing for a vast addressable space. When a contract needs to store data, it writes to a specific storage slot using a key-value pair, where the key is the slot's index and the value is the data. Initially, all slots are set to 0, indicating that explicit writing is required to store data. Accessing storage slots can be costly in terms of gas fees, emphasizing the importance of efficient storage management. Storage slots are referenced using their keccak256 hash, especially for Merkel Patricia Trees (MPTs), providing a standardized way to reference variable-length key values.

![Slot Storage](/public/EVM%20Storage%20slots.png)

- What is the function selector in EVM and its importance?

In the Ethereum Virtual Machine (EVM), a function selector is a unique identifier for each function within a smart contract. It serves as the key that allows the EVM to determine which function to execute when a transaction is initiated. Function selectors are automatically generated in Solidity for each function using a 4-byte hash derived from the function's name and parameter types. This mechanism enables the EVM to differentiate between various functions and execute the correct one.

![Function Selector](/public/Function%20selectorDiagram.drawio.png)

## Implemention 

I am using Foundry toolkit for the development.

- 1. Proxy Contract (`src/ProxyContract.sol`)

According to the Proxy contract design from Task Description, Following is the Proxy contract that maintains a registry of implementation addresses for token transfers functionality.

I have used transparent proxy pattern, as it supports the update functionalities and also restrict the functionalities to the Owner or Admin only.

- [Proxy Contract](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/src/ProxyContract.sol)

This proxy contract also supports adding new implementation address, and deleting a specific implementation address. 

```shell
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
```

Contract has a fallback function that takes a functionSelector as input and delegates the call to the corrosponding contract address.

```shell
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
```

- 2. Implementation Contract (`src/ImplementationContract.sol`)

An Implementation contract has two functions transferTokens and receiveTokens.

- [Implementation Contract](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/src/ImplementationContract.sol)

Balances Mapping: The contract maintains a mapping of balances to track the token balance of each address.

```shell
// A mapping from address to keep a track of balances.
    mapping(address => uint256) public balances;
```    

Transfer Function: The transfer function simulates transferring tokens from one address to another. It checks if the sender has enough balance, updates the balances, and emits a Transfer event.

```shell
// Function to simulate transferring tokens

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance");

        // Update sender's balances
        balances[msg.sender] -= amount;

        // Update recipient's balance to avoid potential underflows
        balances[recipient] += amount;

        // Emit transfer event
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }
```    

Receive Function: The receive function is a placeholder to simulate receiving tokens.

```shell
  // Function to simulate receiving tokens
    function receiveTokens(address sender, uint256 amount) public {
        require(msg.sender != address(0), "cannot be zero receive tokens");

        // Update sender's balances
        balances[sender] += amount;
     }
```

## Interaction

## Requirements 

  - [foundry](https://getfoundry.sh/)
   - Installed Foundry locally, Foundry is a blazing fast, portable and modular toolkit for Ethereum application development

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

- Testing the contract (`test/ProxyTest.t.sol`)

- [ProxyTest Contract](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/test/ProxyTest.t.sol)

This Contract is for testing the functionalities of a proxy contract.

- 1. Add Implementation address: 

```shell
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
```

- 2. Update Implementation Address: 

```shell
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
```

- 3. Remove Implementation Address: 

```shell
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
```

- 4. Fallback delegation function:

```shell
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
```

Run the following command in the command line.
```shell
$ forge test
```

Test Results on my local environment:

```shell
ganadhish@:~/blockchain-proxy$ forge test
[⠒] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/ProxyTest.t.sol:ProxyTest
[PASS] testAddImplementation() (gas: 266368)
[PASS] testFallbackDelegation() (gas: 10645)
[PASS] testRemoveImplementation() (gas: 249228)
[PASS] testUpdateImplementation() (gas: 266324)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 8.62ms (1.30ms CPU time)

Ran 1 test suite in 27.03ms (8.62ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```
Tests also indicating the consumption of gas for each function, and clearly indicating how less gas is consumed by the `testFallbackDelegation()` function.

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

Anvil is a local testnet node shipped with Foundry. You can use it for testing your contracts from frontends or for interacting over RPC.

To use Anvil, simply type anvil. You should see a list of accounts and private keys available for use, as well as the address and port that the node is listening on.

```shell
ganadhish@:~/blockchain-proxy$ anvil


                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    0.2.0 (d58ab7f 2024-02-27T00:15:58.797747783Z)
    https://github.com/foundry-rs/foundry

Available Accounts
==================

(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
(2) 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000.000000000000000000 ETH)
(3) 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000.000000000000000000 ETH)
(4) 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000.000000000000000000 ETH)
(5) 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (10000.000000000000000000 ETH)
(6) 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (10000.000000000000000000 ETH)
(7) 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 (10000.000000000000000000 ETH)
(8) 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f (10000.000000000000000000 ETH)
(9) 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000.000000000000000000 ETH)

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
(3) 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
(4) 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
(5) 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
(6) 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
(7) 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
(8) 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
(9) 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Wallet
==================
Mnemonic:          test test test test test test test test test test test junk
Derivation path:   m/44'/60'/0'/0/


Chain ID
==================

31337

Base Fee
==================

1000000000

Gas Limit
==================

30000000

Genesis Timestamp
==================

1714987242

Listening on 127.0.0.1:8545
```

Run the following command in the command line.
```shell
$ anvil
```

### Deploy

Forge also provies deploying smart contracts using scripts.

Deploying using script provides additional insights. 

- [ProxyContract Script](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/script/ProxyContract.s.sol)

- [ImplementationContract Script](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/script/ImplementationContract.s.sol)

First start Anvil:
```shell
$ anvil
```
Then run the following script, by replacing <your_rpc_url> and <your_private_key>
```shell
$ forge script script/ProxyContract.s.sol:ProxyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```
```shell
ganadhish@:~/blockchain-proxy$ forge script script/ProxyContract.s.sol:ProxyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key>

[⠒] Compiling...
No files changed, compilation skipped
Script ran successfully.

== Return ==
0: contract Proxy 0x5FbDB2315678afecb367f032d93F642f64180aa3
EIP-3855 is not supported in one or more of the RPCs used.
Unsupported Chain IDs: 31337.
Contracts deployed with a Solidity version equal or higher than 0.8.20 might not work properly.
For more information, please see https://eips.ethereum.org/EIPS/eip-3855

## Setting up 1 EVM.

==========================

Chain 31337

Estimated gas price: 5 gwei

Estimated total gas used for script: 433560

Estimated amount required: 0.0021678 ETH

==========================

SIMULATION COMPLETE. To broadcast these transactions, add --broadcast and wallet configuration(s) to the previous command. See forge script --help for more.

Transactions saved to: /home/ganadhish/blockchain-proxy/broadcast/ProxyContract.s.sol/31337/dry-run/run-latest.json

Sensitive values saved to: /home/ganadhish/blockchain-proxy/cache/ProxyContract.s.sol/31337/dry-run/run-latest.json
```

or 

Forge can deploy smart contracts to a given network with the forge create command.

Forge CLI can deploy only one contract at a time.

```shell
$ forge create src/ProxyContract.sol:Proxy --rpc-url <your_rpc_url> --private-key <your_private_key>
```

```shell
ganadhish@:~/blockchain-proxy$ forge create src/ProxyContract.sol:Proxy --rpc-url <your_rpc_url> --private-key <your_private_key>

[⠒] Compiling...
No files changed, compilation skipped
Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Transaction hash: 0xb3259b52c40256695457c26181d4fddcdbd7258dfa16ef30c5def3b02e977b2f
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Quickstart 

```shell
git clone https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview.git
cd foundry-erc20-f23
forge install 
forge build
```
