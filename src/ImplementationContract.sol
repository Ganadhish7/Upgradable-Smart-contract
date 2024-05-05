// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ImplementationContract {
    // Simulate a token contract by storing balances
    mapping(address => uint256) public balances;

    // Event to log transfers
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Event to log Ether received
    event EtherReceived(address indexed from, uint256 amount);

    // Constructor to initialize balances
    constructor(uint256 initialBalance) {
     
        // Set the initial balance for the deployer
        balances[msg.sender] = initialBalance;
    }

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

    // Function to simulate receiving tokens
    function receiveTokens(address sender, uint256 amount) public {
        require(msg.sender != address(0), "cannot be zero receive tokens");

        // Update sender's balances
        balances[sender] += amount;
    }

    // Fallback function to handle Ether transfers
    receive() external payable {

        // update the sender's balance with the amount of Ether received
        balances[msg.sender] += msg.value;

        // Emit a custom event to log the Ether received
        emit EtherReceived(msg.sender, msg.value);
    }
}