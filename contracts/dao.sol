// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DAOTreasury {
    address public owner;
    uint256 public proposalCount;

    struct Proposal {
        uint256 id;
        address payable recipient;
        uint256 amount;
        string description;
        uint256 votes;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public voters;
    mapping(address => bool) public hasVoted;

    event ProposalCreated(uint256 id, address recipient, uint256 amount, string description);
    event ProposalVoted(uint256 id, address voter);
    event ProposalExecuted(uint256 id, address recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to submit a new proposal
    function submitProposal(
        address payable _recipient,
        uint256 _amount,
        string memory _description
    ) external onlyOwner {
        require(_recipient != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than zero");

        proposalCount++;
        proposals[proposalCount] = Proposal(
            proposalCount,
            _recipient,
            _amount,
            _description,
            0,
            false
        );

        emit ProposalCreated(proposalCount, _recipient, _amount, _description);
    }

    // Function to vote on a proposal
    function voteOnProposal(uint256 _proposalId) external {
        require(voters[msg.sender], "You are not authorized to vote");
        require(!hasVoted[msg.sender], "You have already voted");
        require(proposals[_proposalId].id != 0, "Invalid proposal ID");

        proposals[_proposalId].votes++;
        hasVoted[msg.sender] = true;

        emit ProposalVoted(_proposalId, msg.sender);
    }

    // Function to execute a proposal if it passes
    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];

        require(proposal.votes > 0, "Proposal has not been approved");
        require(!proposal.executed, "Proposal has already been executed");

        proposal.executed = true;
        proposal.recipient.transfer(proposal.amount);

        emit ProposalExecuted(_proposalId, proposal.recipient, proposal.amount);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}
