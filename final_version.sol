// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract ProposalContract {

    address owner;  //Owner
    uint256 private counter; // added to keep track of the ids


    struct Proposal {
        string title;   // title of the proposal
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

    address[] private voted_addresses; 

    mapping(address => bool) private hasVoted;  


    constructor() {     //constructor
        owner = msg.sender;     // the address that made the transaction with: msg.sender
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);   // checks msg.sender(account calling the function) is equal to stored owner address
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }



    function setOwner(address new_owner) external onlyOwner {   // to transfer the ownership of the contract to the given address as the parameter 
        owner = new_owner;
    }


    function create(string calldata _title, string calldata _description, uint256 _approve, uint256 _reject, uint256 _pass, uint256 _total_vote_to_end) external {    // to create a new proposal
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, _approve, _reject, _pass, _total_vote_to_end, false, true);
    }


    function vote(uint8 choice) external active newVoter(msg.sender){
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }


    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }


    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;
        
        // pass > approve : can be happen howewer pass votes do not have huge impact on overall proposal
        if (proposal.pass % 5 == 1) {
            pass += 1;
        }
        else {  
            pass = pass / 5; 
        }

        // reject > approve+pass :
        if (reject > approve + pass) {
            return false;
        } 
        else {
            return true;
        }
    }


    // ****************** Query Functions ***********************

    function isVoted(address _address) public view returns (bool) {
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }


    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
        require(number <= counter, "Proposal does not exist.");
        return proposal_history[number];
    }

}
