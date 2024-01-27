// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Example {
    // This is the owner of the contract
    address owner;

    // This is our counter struct. It will hold necessary information about the counter which are number and description
    // like objects in the python(shortly OOP)
    struct Counter {
        uint number;        //unsigned integer: from 0 to positive numbers
        string description;
    }

    // Here we create an instance of our Counter. 
    // It is empty for now, but we will initialize it in the constructor.
    Counter counter;

    // We will use this modidifer with our execute functions.
    // This modifiers make sure that the caller of the function is the owner of the contract.
    // it helps to modify functions call, such as we define a condition and if its met it goes on with function call
    // only owner can access this function call sections(or modifier)
    // msg.sender is the one who send the transaction
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can increment or decrement the counter");
        _;      // if its true, just continue with the function; if false error msg is printed or sent 
    }

    // This is our constructor function. It only runs once when we deploy the contract.
    // Since it takes two parameters, initial_value and description, they should be provided when we deploy our contract.
    // "memory" indicates that during the execution we will store these values but not on the blockchain
    // another type is the one store on the blockchain: "storage" keyword is used for that

    constructor(uint initial_value, string memory description) {
        owner = msg.sender;
        counter = Counter(initial_value, description);
    }

    // Below, we have two execute functions, increment_counter and decrement_counter
    // Since they modify data on chain, they require gas fee.
    // They are "external" functions, meaning they can only be called outside of the contract.
    // They also have the onlyOwner modifier which we created above. This make sure that only the owner of this contract can call these functions.
   
    // "internal" function: can be called in the smart contract and other smart contracts that inherited from it 
    // "private" function: special to only this smart contract
    // "public" function: can be used inside and outside 

    // This function gets the number field from the counter struct and increases it by one.
    function increment_counter() external onlyOwner {
        counter.number += 1;
    }

    // This function is similar the one above, but instead of increasing we deacrease the number by one.
    function decrement_counter() external onlyOwner {
        counter.number -= 1;
    }

    // The function below is a "query" function. It does not change any data on the chain. It just rerieves data.
    // We use the keyword "view" to indicate it retrieves data but does not change any.
    // Since we are not modifying any data, we do not pay any gas fee.

    // "pure": we are not even receiving any data from blockchain and we are not changing any data from blockchain

    // This function returns the number field of our counter struct. Returning the current state of our counter.
    function get_counter_value() external view returns(uint) {
        return counter.number;
    }

    // A query function which returns the description:
    function get_description()  external view returns(string memory) {
        return counter.description;
    }

}