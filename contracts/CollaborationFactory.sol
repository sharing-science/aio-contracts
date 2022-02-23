//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./CollaborationEvent.sol";

contract CollaborationFactory {
    using Counters for Counters.Counter;
    Counters.Counter private CollabIds;

    struct Researcher {
        string name;
        string institution;
        uint256[] sharing_ids;
        uint256[] seeking_ids;
        bool exists;
    }

    mapping(address => Researcher) participants;
    mapping(uint256 => address) collaborations;

    event CollaborationInitialized(uint256 CollabId);
    event ParticipantAdded(string name, string institution);

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function _lookupResName(address res) public view returns (string memory) { return participants[res].name;}
    function _lookupResInstitution(address res) public view returns (string memory) { return participants[res].institution;}
    function _lookupResShare(address res) public view returns (uint256[] memory) { return participants[res].sharing_ids;}
    function _lookupResSeek(address res) public view returns (uint256[] memory) { return participants[res].seeking_ids;}

    function _lookupCollab(uint256 id) public view returns(address) { return collaborations[id]; }

    /// @notice Initialize a collaboration between two researchers, generally
    ///         would be initialized by the data seeker
    /// @param res_1 Address of confirmed participant in the protocol who is sharing data
    /// @param res_2 Address of confirmed participant in the protocol who is seeking data
    function _initCollab(address res_1, address res_2) public returns (address newCollab) {
        require(participants[res_1].exists == true);
        require(participants[res_2].exists == true);

        CollabIds.increment();
        uint256 id = CollabIds.current();

        CollaborationEvent c = new CollaborationEvent(res_1, res_2);
        collaborations[id] = address(c);
        participants[res_1].sharing_ids.push(id);
        participants[res_2].seeking_ids.push(id);

        emit CollaborationInitialized(id);

        return collaborations[id];
    } 

    /// @notice A researcher must be a confirmed participant on the protocol in
    ///         to share or seek data
    /// @param name first and last name of researcher
    /// @param institution associated institution of the researcher
    function _addRes(string memory name, string memory institution) public {
        require(participants[msg.sender].exists == false, "Already a researcher associated with this address");

        uint256[] memory arr1;
        uint256[] memory arr2;
        participants[msg.sender] = Researcher(name, institution, arr1, arr2, true);
        emit ParticipantAdded(name, institution);
    }

}