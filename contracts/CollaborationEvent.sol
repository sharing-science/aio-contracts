//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract CollaborationEvent {
    address payable public factory;
    address public data_sharer; 
    address public data_seeker; 
    contractState public _contractState;
    requestType public _requestType ;

    enum contractState { 
        AwaitingDataRequest, AwaitingDataRequestApproval, AwaitingDataShareConfirm, AwaitingDataReceiveConfirm, AwaitingReuseReport, AwaitingReviews, ContractDestroyed
    }   

    enum requestType {
        none, DataMerge, Reproduce, Reuse, Cite
    }

    uint startTime;

    event CollaborationDestroyed(uint time);

    event RequestSubmitted(uint time, requestType _type);
    event RequestApproved(uint time);
    event RequestDenied(uint time);

    event DataShared(uint time);
    event DataReceived(uint time);

    event ReuseReported(uint time, bool wasReused);
    event DataNotReused();
    event ReviewSubmitted(uint time, address isAbout);

    modifier onlyDataSharer(){
        require(msg.sender == data_sharer);
        _;
    }

    modifier onlyDataSeeker(){
        require(msg.sender == data_seeker);
        _;
    }

    constructor(address _data_sharer, address _data_seeker) {
        startTime = block.timestamp;
        factory = payable(msg.sender);
        data_sharer = _data_sharer;

        data_seeker = _data_seeker;

        _contractState = contractState.AwaitingDataRequest;
        _requestType = requestType.none;
    }

    function _submitRequest(requestType _type) public onlyDataSeeker {
        require(_contractState == contractState.AwaitingDataRequest, "Request already submitted");
        _contractState = contractState.AwaitingDataRequestApproval;
        _requestType = _type;
        
        emit RequestSubmitted(block.timestamp, _type);
    }

    function _approveRequest() public onlyDataSharer {
        require(_contractState == contractState.AwaitingDataRequestApproval, "Request not submitted or request already approved");
        _contractState = contractState.AwaitingDataShareConfirm;
        
        emit RequestApproved(block.timestamp);
    }

    function _denyRequest() public onlyDataSharer {
        require(_contractState == contractState.AwaitingDataShareConfirm, "Request not submitted or request already approved");
        _contractState = contractState.ContractDestroyed;
        emit RequestDenied(block.timestamp);
        destruct();
    }





    function _shareData() public onlyDataSharer {
        require(_contractState == contractState.AwaitingDataShareConfirm, "Request not approved or Data already shared");
        _contractState = contractState.AwaitingDataReceiveConfirm;
        emit DataShared(block.timestamp);
    }

    function _receiveData() public onlyDataSeeker {
        require(_contractState == contractState.AwaitingDataReceiveConfirm, "Data not shared or Data already rececived");
        _contractState = contractState.AwaitingReuseReport;
        emit DataReceived(block.timestamp);
    }

    //didnt receive data



    function _reportReuse(bool wasReused) public onlyDataSeeker {
        require(_contractState == contractState.AwaitingReuseReport, "Data not received or reuse already reported");
        if (wasReused == false) {
            emit DataNotReused();
            destruct();
        }
        else {
            _contractState = contractState.AwaitingReviews;
            emit ReuseReported(block.timestamp, wasReused);
        }
    }

    function _submitReviewOfDataSharer(int Communication, int EaseOfUse, int Reproducibility, int Timeliness, int Verifiability) public onlyDataSeeker {
        
    }


    function _submitReviewOfDataSeeker(int Communication, int EaseOfUse, int Reproducibility, int Timeliness, int Verifiability) public onlyDataSharer {

    }



    function destruct() private {
        emit CollaborationDestroyed(block.timestamp);
        selfdestruct(factory);
    }
    
}