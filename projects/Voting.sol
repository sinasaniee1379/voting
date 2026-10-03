// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Voting {
    struct Proposal{
        string name;
        string description;
        address creator;
        uint endTime;
        uint createTime;
        uint yesVotes;
        uint noVotes;
        mapping(address => bool) hasVoted;
    }

    Proposal[] public proposals;

    function addProposal (string memory _name, string memory _description, uint _durationInMinutes) public {
        Proposal storage proposal = proposals.push();
        proposal.name = _name;
        proposal.description = _description;
        proposal.creator = msg.sender;
        proposal.createTime = block.timestamp;
        proposal.endTime = block.timestamp + (_durationInMinutes + 1 minutes);
        proposal.yesVotes = 0;
        proposal.noVotes = 0;

    }

    function vote (uint _proposalIndex, bool _yesVote) public {
        require(_proposalIndex < proposals.length, "proposal is not exist");
        Proposal storage proposal = proposals[_proposalIndex];

        require(!proposal.hasVoted[msg.sender], "You have already voted before");
        require(block.timestamp < proposal.endTime,"The time has finished");

        if(_yesVote){
            proposal.yesVotes += 1;
        }else {
            proposal.noVotes += 1;
        }

        proposal.hasVoted[msg.sender] = true;
    }

    function getResult (uint _proposalIndex) public view returns(uint _yesVotes , uint _noVotes) {
        require(_proposalIndex < proposals.length, "proposal is not exist");
        Proposal storage proposal = proposals[_proposalIndex];

        return (proposal.yesVotes , proposal.noVotes);
    }
}