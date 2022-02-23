//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract CollaborationEvent {
    address public data_sharer; 
    address public data_seeker; 
    contractState public _contractState;
    requestType public _requestType ;

    enum contractState { 
        Created, ReceivedRequest, AwaitingDataShare, AwaitingDataReceive, AwaitingReuseReport, AwaitingReviews
    }   

    enum requestType {
        none, DataMerge, Reproduce, Reuse
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
        data_sharer = _data_sharer;

        data_seeker = _data_seeker;

        _contractState = contractState.Created;
        _requestType = requestType.none;
    }

    function _submitRequest(requestType _type) public onlyDataSeeker {
        require(_contractState == contractState.Created, "Request already submitted");
        _contractState = contractState.ReceivedRequest;
        _requestType = _type;
        
        emit RequestSubmitted(block.timestamp, _type);
    }

    function _approveRequest() public onlyDataSharer {
        require(_contractState == contractState.ReceivedRequest, "Request not submitted or request already approved");
        _contractState = contractState.AwaitingDataShare;
        
        emit RequestApproved(block.timestamp);
    }

    function _denyRequest() public onlyDataSharer {
        require(_contractState == contractState.ReceivedRequest, "Request not submitted or request already approved");
        emit RequestDenied(block.timestamp);
        destruct();
    }





    function _shareData() public onlyDataSharer {
        require(_contractState == contractState.AwaitingDataShare, "Request not approved or Data already shared");
        _contractState = contractState.AwaitingDataReceive;
        emit DataShared(block.timestamp);
    }

    function _receiveData() public onlyDataSeeker {
        require(_contractState == contractState.AwaitingDataReceive, "Data not shared or Data already rececived");
        _contractState = contractState.AwaitingReuseReport;
        emit DataReceived(block.timestamp);
    }



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



 












    function destruct() private {
        emit CollaborationDestroyed(block.timestamp);
    }
    
}