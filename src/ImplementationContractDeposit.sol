// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DepositContract
 * @dev This is a contract that includes a deposit function.
 */

contract DepositContract {
    // A mapping from address to keep a track of balances.
    mapping(address => uint256) public balances;

    // Event to log deposits
    event Deposit(address indexed from, uint256 amount);

    // Event to log Ether received
    event EtherReceived(address indexed from, uint256 amount);

    // Constructor to initialize balances
    constructor(uint256 initialBalance) {
        // Set the initial balance for the deployer
        balances[msg.sender] = initialBalance;
    }

    // Function to simulate depositing tokens
    function deposit(uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance");

        // Update sender's balances
        balances[msg.sender] -= amount;

        // Emit deposit event
        emit Deposit(msg.sender, amount);

        return true;
    }

    // Function to simulate receiving tokens
    function receiveTokens(address sender, uint256 amount) public {
        require(msg.sender!= address(0), "cannot be zero receive tokens");

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
