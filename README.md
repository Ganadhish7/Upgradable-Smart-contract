## Task 2: Proxy Contract for Load Balancing and Function Delegation

# Index

- [Introduction](#introduction)
  - [Architecture](#architecture)
  - [Implementation](#implementation)
  - [Interaction](#interaction)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Start a local node](#start-a-local-node)
  - [Deploy](#deploy) 
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Thank you!](#thank-you)   


# Introduction

## Architecture

- What is a Proxy Contract?

A proxy contract is a contract that acts as an intermediary between the end user and the actual logic contract (implementation contract). It stores the states of the current implementation contract and forwards calls to it. Proxy contracts are used for upgradability because they allow the logic contract to be swapped out without changing the contract's address, and preserving its state and interactions.

![Proxy Contract](./public/Proxy%20architecture.drawio.png)

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

![delegatecall](./public/Delegate%20call%20architecture.drawio.png)

- What is a fallback function?

A fallback function in Solidity is a special function that is executed when a contract receives plain Ether (without data) or when a function call is made to the contract but no matching function exists. The fallback function can be used to handle unexpected inputs or to provide a default behavior for the contract. In the context of upgradable smart contracts, the fallback function can be used to ensure that the contract behaves correctly even if an upgrade introduces changes that affect existing interactions .

- What is the assembly block in the solidity contract?

The assembly block in a Solidity contract refers to a section of the contract where low-level assembly language instructions are written. Assembly language provides direct access to the Ethereum Virtual Machine (EVM) and allows for operations that are not directly supported by Solidity's high-level syntax. While Solidity abstracts away many of the complexities of the EVM, the assembly block can be used for performance optimizations, complex computations, or when interacting with other contracts in a very specific way.

## Implemention 

According to the Proxy contract design from Task Description, Following is the Proxy contract that maintains a registry of implementation addresses for token transfers functionality.

- [Proxy Contract](https://github.com/Ganadhish7/Wasserstoff-Task2-2024-Blockchain-Interview/blob/master/src/ProxyContract.sol)

## Interaction




# Getting Started

## Requirements 

  - [foundry](https://getfoundry.sh/)
   - Installed Foundry locally, Foundry is a blazing fast, portable and modular toolkit for Ethereum application development

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```
or 

```shell
$ forge create src/ProxyContract.sol:Proxy --rpc-url <your_rpc_url> --private-key <your_private_key>
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
git clone https://github.com/Cyfrin/foundry-erc20-f23
cd foundry-erc20-f23
forge install 
forge build
```


# Usage 


## Start a local node

```shell
make anvil
```

## Deploy

This will default to your local node. You need to have it running in another terminal in order for it to deploy.

```shell
make deploy
```

## Deploy - Other Network

[See below](#deployment-to-a-testnet-or-mainnet)

## Testing

```shell
forge test
```
or 

```shell
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```shell
forge coverage
```


# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.
