//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CollaborationEvent is Ownable{
    address public data_sharer; 
    address public data_seeker; 
    CollaborationState public _collaborationState;
    IntendedUse public _intendedUse ;

    enum CollaborationState { 
        AwaitingDataRequest, AwaitingDataRequestApproval, AwaitingDataShareConfirm, AwaitingDataReceiveConfirm, AwaitingReuseReport, AwaitingReviews, ContractDestroyed
    }   

    enum IntendedUse {
        none, DataMerge, Reproduce, Reuse, Cite
    }

    uint startTime;
    uint reviewCount;

    event CollaborationDestroyed(uint time);

    event RequestSubmitted(uint time, IntendedUse _type);
    event RequestApproved(uint time);
    event RequestDenied(uint time);

    event DataShared(uint time);
    event DataReceived(uint time);
    event DataNotReceived(uint time);

    event ReuseReported(uint time, bool wasReused);
    event DataNotReused(uint time);
    event ReviewSubmitted(uint time, address isAbout);

    ///***** Getters *********************************///
    function _DataSharer() public view returns (address) { return data_sharer;}
    function _DataSeeker() public view returns (address) { return data_seeker;}


    /// @notice modifier onlyDataSharer
    modifier onlyDataSharer(){
        require(msg.sender == data_sharer);
        _;
    }

    /// @notice modifier onlyDataSeeker can call
    modifier onlyDataSeeker(){
        require(msg.sender == data_seeker);
        _;
    }

    /// @notice getter CollaborationState
    function _getCollaborationState() public view returns(uint8) {
        return uint8(_collaborationState);
    }

    /// @notice increment Review count, if count == 2, destroy contract
    function _incrementReviewCount() public onlyOwner {
        reviewCount += 1;
        if (reviewCount == 2) {
            destruct();
        }
    }


    /// @notice constructor called within CollaborationFactory only
    ///
    /// @param _data_sharer address of data sharer
    /// @param _data_seeker address of data seeker
    constructor(address _data_sharer, address _data_seeker) {
        startTime = block.timestamp;
        reviewCount = 0;

        data_sharer = _data_sharer;

        data_seeker = _data_seeker;

        _collaborationState = CollaborationState.AwaitingDataRequest;
        _intendedUse = IntendedUse.none;
    }



    /// Data Request Event @ aio v1
    /// see 2 functions below

    /// @notice submit request type from Data Seeker
    /// 
    /// @param _type enum 0-4 represent request type enumerator
    function _submitRequest(IntendedUse _type) public onlyDataSeeker {
        require(_collaborationState == CollaborationState.AwaitingDataRequest, "Request already submitted");
        _collaborationState = CollaborationState.AwaitingDataRequestApproval;
        _intendedUse = _type;
        
        emit RequestSubmitted(block.timestamp, _type);
    }


    /// @notice data seeker approve or deny request
    /// 
    /// @param _approved boolean true if approved false if denied
    function _answerRequest(bool _approved) public onlyDataSharer {
        require(_collaborationState == CollaborationState.AwaitingDataRequestApproval, "Request not submitted or request already approved");
        if (_approved) {
            _collaborationState = CollaborationState.AwaitingDataShareConfirm;
            emit RequestApproved(block.timestamp);
        }
        else {
            _collaborationState = CollaborationState.ContractDestroyed;
            emit RequestDenied(block.timestamp);
            destruct();
        }
    }


    /// Data Sharing Event from aio v1
    /// two functions below



    /// @notice after sharing the data data sharer confirms the data has been shared
    function _shareData() public onlyDataSharer {
        require(_collaborationState == CollaborationState.AwaitingDataShareConfirm, "Request not approved or Data already shared");
        _collaborationState = CollaborationState.AwaitingDataReceiveConfirm;
        emit DataShared(block.timestamp);
    }

    /// @notice on receive of data data seeker confirms it has received and is complete
    /// 
    /// @param _received boolean true if received as expected, false otherwise
    function _receiveData(bool _received) public onlyDataSeeker {
        require(_collaborationState == CollaborationState.AwaitingDataReceiveConfirm, "Data not shared or Data already rececived");
        if (_received) {
            _collaborationState = CollaborationState.AwaitingReuseReport;
            emit DataReceived(block.timestamp);
        }
        else {
            _collaborationState = CollaborationState.ContractDestroyed;
            emit DataNotReceived(block.timestamp);
            destruct();
        }
    }

    /// Data Reuse Reporting Event from aio v1
    /// two functions below

    /// @notice Report the reuse
    /// @dev include DOI reporting... where to put
    /// @param wasReused boolean true if reused false otherwise
    function _reportReuse(bool wasReused) public onlyDataSeeker {
        require(_collaborationState == CollaborationState.AwaitingReuseReport, "Data not received or reuse already reported");
        if (wasReused == false) {
            emit DataNotReused(block.timestamp);
            destruct();
        }
        else {
            _collaborationState = CollaborationState.AwaitingReviews;
            emit ReuseReported(block.timestamp, wasReused);
        }
    }


    /// @notice voids all function calls even though function is still visible
    ///         on chain
    /// @dev must catch CollaborationDestroyed event and not allow any other interfacing from application
    function destruct() private {
        emit CollaborationDestroyed(block.timestamp);
        selfdestruct(payable(owner()));
    }
    
}