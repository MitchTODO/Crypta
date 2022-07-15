// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract Dao {

    struct Group {
      uint256 id;
      string name;
      address creator;
      string description;
      string image; // IPFS url
      uint256 proposalCount;
      bool isActive;
    }

    struct Proposal {
      uint256 id;
      string title;
      string description;
      address creator;
      uint256 proposalStart;
      uint256 proposalEnd;
    }

    struct Choice
    {
      uint256 votes;
      string description;
    }

    struct Vote
    {
      bool voted;  // if true, that person already voted
      uint256 indexChoice;
    }


    /********************** Variables ***********************/
    //GroupId -> ProposalId -> address -> has voted
    mapping(uint256 => mapping(uint256 => mapping(address => Vote)) ) voteMap;
    // GroupId -> ProposalId -> Choices Array
    mapping(uint256 => mapping(uint256 => Choice[])) choices; // max of ten chocies;
    // groupID -> list of Proposals
    mapping(uint256 => Proposal[]) proposals;
    // groupID -> Amount
    mapping(uint256 => Group) groups;

    Group[] public groupArray;

    uint256 public groupIdTracker = 0;

    /********************** Events ***********************/
    event GroupCreated(uint256);
    event GroupActivated(uint256);
    event GroupDisabled(uint256);
    event ProposalCreated(uint256,Proposal);

    /********************** Modifiers ***********************/

    modifier groupsExist(uint256 startIndex,uint256 numberOfGroups) {
      require(startIndex >= 0, "Index cant be less then zero");
      require(numberOfGroups > 0,"Number of groups cant be zero");
      require((groupArray.length - startIndex) >= numberOfGroups,"Amount of groups requested exceeds amount of existing groups");
      _;
    }
    modifier groupExist(uint256 groupId) {
      require(groupId <= groupArray.length,"Group dosent exist check groupId");
      require(groups[groupId].isActive,"Group is inActive or dosent exist");
      _;
    }

    modifier groupActivate(uint256 id){
      require(groups[id].isActive == false,"Group already active");
      _;
    }

    modifier groupDisabled(uint256 id) {
      require(groups[id].isActive == true,"Group already disabled.");
      _;
    }

    modifier isCreator(uint256 id) {
      require(msg.sender == groups[id].creator,"Only the creator can disable or activate a group.");
      _;
    }

    modifier pollisActive(uint256 groupId, uint256 proposalId) {
      require(proposals[groupId][proposalId].proposalStart <= block.timestamp, "Poll isnt open");
      require(proposals[groupId][proposalId].proposalEnd >= block.timestamp,"Poll has end");

      _;
    }

    modifier canRemove(uint256 groupId, uint256 proposalId) {
      require(voteMap[groupId][proposalId][msg.sender].voted == true,"You must vote first");
      _;
    }

    modifier hasVoted(uint256 groupId, uint256 proposalId){
      require(voteMap[groupId][proposalId][msg.sender].voted == false,"You have already voted");
      _;
    }

    modifier proposalsExist(uint256 groupId,uint256 startIndex ,uint256 numberOfProposals){
      require(startIndex >= 0, "Start index cant be less then zero");
      require(numberOfProposals > 0,"Number of proposals cant be zero");
      require((proposals[groupId].length - startIndex) >= numberOfProposals,"Amount of proposals requested exceeds amount of existing proposals");
      _;
    }

    modifier proposalExist(uint256 groupId, uint256 proposalId){
      require(proposals[groupId].length >= proposalId + 1 , "Proposal doesn't exist.");
      _;
    }


    /********************** Proposal Functions ***********************/
    // Proposals cannot be removed or delete

    function createProposal(uint256 groupId,string memory _title, string memory _description, uint256 _proposalStart, uint256 _proposalEnd, Choice[] memory _choices)
    public
    groupExist(groupId) // Check if groups exist
    {
      require(_proposalStart < _proposalEnd,"Check poll start time.");
      require(_choices.length < 5, "Too many choices, Contract is limited to 5 choices per proposal.");
      Proposal memory eve;
      eve.id = groups[groupId].proposalCount; // set Proposal id to group ProposalCount
      groups[groupId].proposalCount++; // increase proposal counter within group
      groupArray[groupId] = groups[groupId]; // Update group in groupArray
      eve.title = _title;
      eve.description = _description;
      eve.creator = msg.sender;
      eve.proposalEnd = _proposalEnd;
      eve.proposalStart = _proposalStart;

      proposals[groupId].push(eve);

      for (uint i = 0; i < _choices.length; i++) {
        choices[groupId][eve.id].push(_choices[i]);
      }

      emit ProposalCreated(groupId,eve);
    }
  // [[0,"1"],[0,"2"],[0,"3"]]
    function getProposalCount(uint256 groupId) public view
    groupExist(groupId)
    returns(uint256)
    {
      return(groups[groupId].proposalCount);
    }

    function getProposals(uint256 _groupId,uint256 _startIndex, uint256 _numberOfProposals) public view
    proposalsExist(_groupId,_startIndex,_numberOfProposals)
    returns(Proposal[] memory,Vote[] memory)
    {

      uint256 end = _startIndex + _numberOfProposals;
      uint256 newIndex = 0;
      Proposal[] memory mProposals = new Proposal[](_numberOfProposals); // empty array with length of number of groups
      Vote[] memory mVotes = new Vote[](_numberOfProposals);

      for(uint i = _startIndex;i < end; i++){
          mProposals[newIndex] = proposals[_groupId][i];
          mVotes[newIndex] = voteMap[_groupId][i][msg.sender];
          newIndex++;
      }
      return (mProposals,mVotes);
    }



    // ProposalId is also the index
    function getProposal(uint256 groupId, uint256 proposalId) public view
    groupExist(groupId)
    proposalExist(groupId, proposalId)
     returns(Proposal memory,Vote memory)
    {
      Proposal memory p = proposals[groupId][proposalId];
      Vote memory v = voteMap[groupId][proposalId][msg.sender];
      return(p,v);
    }

    /********************** Choice Functions ***********************/

    function getChoice(uint256 _groupId, uint256 _proposalId)
    public
    view
    returns(Choice[] memory)
    {
       Choice[] memory cho = choices[_groupId][_proposalId];
       return(cho);
    }


    /********************** Voting Functions ***********************/
    // This is only a one to one voting, not weighted
    function vote(uint256 _groupId, uint256 _proposalId,uint256 _choiceId) public
    groupExist(_groupId)
    pollisActive(_groupId,_proposalId)
    hasVoted(_groupId,_proposalId)
    {
      // update poll with new vote
      Choice memory cho = choices[_groupId][_proposalId][_choiceId];
      cho.votes++;
      choices[_groupId][_proposalId][_choiceId] = cho;

      // Update mapping with voting details
      voteMap[_groupId][_proposalId][msg.sender].indexChoice = _choiceId;
      voteMap[_groupId][_proposalId][msg.sender].voted = true;
    }

    function getVote(uint256 _groupId, uint256 _proposalId) public view
      groupExist(_groupId)
      proposalExist(_groupId, _proposalId)
      //hasVoted(_groupId,_proposalId)
      returns(Vote memory)
    {
      Vote memory ty = voteMap[_groupId][_proposalId][msg.sender];
      return (ty);
    }

    function removeVote(uint256 _groupId, uint256 _proposalId) public
      groupExist(_groupId)
      canRemove(_groupId,_proposalId)
      pollisActive(_groupId,_proposalId)

    {
      // Choice of what address voted for
      uint256 _choiceId = voteMap[_groupId][_proposalId][msg.sender].indexChoice;
      // update poll with new vote
      Choice memory cho = choices[_groupId][_proposalId][_choiceId];
      cho.votes--;
      choices[_groupId][_proposalId][_choiceId] = cho;

      // Update mapping with voting details
      voteMap[_groupId][_proposalId][msg.sender].indexChoice = 0;
      voteMap[_groupId][_proposalId][msg.sender].voted = false;


    }

    /********************** Group Functions ***********************/

    function newGroup(string memory _name, string memory _description, string memory _groupImage)
    public
    {
        Group memory group;
        group.creator = msg.sender;
        group.name = _name;
        group.proposalCount = 0; // using for indexing for proposals
        group.description = _description;
        group.image = _groupImage;
        group.id = groupIdTracker;
        group.isActive = true;

        groups[groupIdTracker] = group;
        groupArray.push(group);
        groupIdTracker++;
        emit GroupCreated(group.id);
    }

    // Should groups be removed??
    function disableGroup(uint256 _groupId) public
    isCreator(_groupId)
    groupDisabled(_groupId)
    {
      // set mapping group activity to false
      groups[_groupId].isActive = false;
      // delete group from array
      // This will NOT shift the elements
      //delete groupArray[_groupId]; // keep index the same

      emit GroupDisabled(_groupId);
    }

    function activateGroup(uint256 _groupId) public
    isCreator(_groupId)
    groupActivate(_groupId)
    {
      groups[_groupId].isActive = true;

      emit GroupActivated(_groupId);
    }



    function getGroup(uint256 _startIndex, uint256 _numberOfGroups) public view
    groupsExist(_startIndex,_numberOfGroups)
    returns(Group[] memory)

    {
        uint256 end = _startIndex + _numberOfGroups;
        uint256 newIndex = 0;
        Group[] memory mGroups = new Group[](_numberOfGroups); // empty array with length of number of groups
        for(uint i = _startIndex;i < end; i++){
            mGroups[newIndex] = groupArray[i];
            newIndex++;
        }
        return (mGroups);
    }



}
