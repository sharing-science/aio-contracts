//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./CollaborationEvent.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CollaborationFactory {
    using SafeMath for uint;
    using Counters for Counters.Counter;
    Counters.Counter private CollabIds;

    /// @notice struct for containing all Researcher data
    struct Researcher {
        string cid;

        uint SCIENCE_index;
        uint peer_review_score;

        string[] dataMetaCid;
        string[] publications;

        uint256[] sharing_ids;
        uint256[] seeking_ids;

        string[] reviewAbout_cids;
        string[] reviewFrom_cids;

        bool exists;
    }
    
    address public owner;

    /// storage containers
    mapping(address => Researcher) participants;
    mapping(uint256 => address) collaborations;

    /// events
    event CollaborationInitialized(uint256 CollabId);
    event ParticipantAdded(string cid);
    event ReviewSubmitted(string cid);

    

    /// @notice Constructor which takes no argument
    constructor() {
        owner = msg.sender;
    }


    ///***** Lookup functions ***********************************************///

    function _lookupResCid(address res) public view returns (string memory) { return participants[res].cid;}
    function _lookupResShare(address res) public view returns (uint256[] memory) { return participants[res].sharing_ids;}
    function _lookupResSeek(address res) public view returns (uint256[] memory) { return participants[res].seeking_ids;}

    function _lookupCollab(uint256 id) public view returns(address) { return collaborations[id]; }

    /// @notice A lookup function to get all active collaborations by filtering by CollaborationState
    function _allActiveCollabs() public view returns(address[] memory) {
        address[] memory ret = new address[](CollabIds.current());
        for (uint i = 0; i < CollabIds.current(); i++) {
            CollaborationEvent temp = CollaborationEvent(collaborations[i]);
            if (temp._getCollaborationState() != 6) {
                ret[i] = collaborations[i];
            }
        }
        return ret;
    }



    ///***** Initializers ***********************************************///


    /// @notice Initialize a collaboration between two researchers, generally
    ///         would be initialized by the data seeker
    /// @param res_1 Address of confirmed participant in the protocol who is sharing data
    /// @param res_2 Address of confirmed participant in the protocol who is seeking data
    function _initCollaboration(address res_1, address res_2) public {
        require(participants[res_1].exists == true);
        require(participants[res_2].exists == true);

        CollabIds.increment();
        uint256 id = CollabIds.current();

        CollaborationEvent c = new CollaborationEvent(res_1, res_2);
        collaborations[id] = address(c);
        participants[res_1].sharing_ids.push(id);
        participants[res_2].seeking_ids.push(id);

        emit CollaborationInitialized(id);
    } 

    /// @notice A researcher must be a confirmed participant on the protocol in
    ///         to share or seek data
    /// @param cid IPFS contentID pointing to a JSON handling researcher metadata
    function _addResearcher(string memory cid) public {
        require(participants[msg.sender].exists == false, "Already a researcher associated with this address");

        string[] memory arr;
        string[] memory arr1;
        uint256[] memory arr2;
        uint256[] memory arr3;
        string[] memory arr4;
        string[] memory arr5;
        
        participants[msg.sender] = Researcher(cid, 0, 0, arr, arr1, arr2, arr3, arr4, arr5, true);
        emit ParticipantAdded(cid);
    }



    ///***** Researcher Activities ***********************************************///



    /// @notice add a dataset to researcher's list of datasets that they are willing to share
    /// 
    /// @param researcher address of researcher listing artifact
    /// @param cid IPFS contentID which contains metadata describing the artifact, generated
    ///            by the application
    function _listResearchArtifact(address researcher, string memory cid) public {
        participants[researcher].dataMetaCid.push(cid);
    }


    /// @notice report the reuse of a shared research artifact
    /// 
    /// @param collaborationEvent address of collab contract
    /// @param cid IPFS contentID pointing to metadata of the new publication,
    ///            empty string if data was not reused
    function _reportReuse(address collaborationEvent, string memory cid) public {
        CollaborationEvent collab = CollaborationEvent(collaborationEvent);
        require(collab._DataSeeker() == msg.sender, "Only Data Seeker can report their reuse");
        if (keccak256(abi.encodePacked(cid)) == '') collab._reportReuse(false);
        else {
            collab._reportReuse(false);
            participants[collab._DataSeeker()].publications.push(cid);
        }
    }


    /// @notice Updates a researcher's peer review score and adds the review's content ID to
    ///         the appropriate arrays for later lookup
    /// @param  collaborationEvent the collaboration the review pertains to
    /// @param  about The researcher's address the review is about
    /// @param  cid IPFS contentID pointing to a JSON handling the review metadata, pinned by application
    /// @param  reviewScore calculated based on the different review fields outlined in AIO, calculated in application
    function _submitReview(address collaborationEvent, address about, string memory cid, uint reviewScore) public {
        CollaborationEvent collab = CollaborationEvent(collaborationEvent);
        uint _currState = collab._getCollaborationState();
        require(_currState == 5, "Not ready for reviews or reviews already submitted");

        uint currReviewCount = participants[about].reviewAbout_cids.length;
        uint newReviewScore = ((participants[about].peer_review_score * currReviewCount) + reviewScore) / (currReviewCount + 1);
        participants[about].peer_review_score = newReviewScore;

        participants[msg.sender].reviewFrom_cids.push(cid);
        participants[about].reviewAbout_cids.push(cid);

        collab._incrementReviewCount();
    }


/*
    function _retrieveSCIENCEindex(address researcher) public {
        string memory cid = participants[researcher].cid;
        /// @dev throw cid to external chainlink adapter which should return new science-index
        participants[researcher].SCIENCE_index += 1;
    }
*/

}