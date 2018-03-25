pragma solidity ^0.4.16;

contract Asset{
    address public owner;
    string name;
    string url;
    string description;
    string latlong;

    enum AuctionStatus {Active , Inactive, Pending}

    event LogFailure(string message);
    AuctionStatus public _auctionstatus;
    
    uint public highestBid;
    uint private ReservedPrice;
    uint public startPrice;
    uint public bidends;
    address highestBidder;
    
    // uint public currentBlock = block.number;
    
    struct BID{
        uint amount;
        address bidder;
        uint timestamp;
    }
    
    BID[] public _Bids;
    
     function Asset(string _name, string _url, string _description, string _latlong) public
    {   
        owner = msg.sender;
        name = _name;
        url = _url;
        description = _description;
        latlong = _latlong;
    }
    
    
    function startAuction(uint _startPrice, uint32 _bidends) public
    {
        startPrice = _startPrice;
        bidends = block.number + _bidends;
        _auctionstatus = AuctionStatus.Active;
    }
    


    function Bid() payable public{
        require(_auctionstatus == AuctionStatus.Active);
        require(msg.value > startPrice);
        require(msg.value > highestBid);
        require(block.number <= bidends);
        
        BID _bid;
        _Bids.push(_bid);
        uint length = _Bids.length - 1;
        address sender = msg.sender;
        uint value = msg.value;
        _Bids[length].amount = value;
        _Bids[length].bidder = sender;
        _Bids[length].timestamp = block.timestamp;
        highestBid = value;
        highestBidder = sender;
    }
    


    function EndAuction() public payable
    {   
        if (_auctionstatus != AuctionStatus.Active) {
            LogFailure("Can not end an auction that's already ended");    
            throw;
        }
        
        if (block.number < bidends) {
            LogFailure("Can not end an auction that hasn't hit the deadline yet"); 
            throw; 
        }
        
        uint refund;
        uint length = _Bids.length;
        
        for(uint i =0; i< length-1; i++)
        {
            refund = _Bids[i].amount;
            _Bids[i].amount = 0;
            if (!_Bids[i].bidder.send(refund))
            {    _Bids[i].amount = refund; }
            // else{ Log(_Bids[i].bidder, refund); }            
        }
            
        if(length >= 1)
        {    owner.transfer(this.balance);
             highestBid = 0;
             owner = highestBidder; 
        }
        
        startPrice = 0;
        _auctionstatus = AuctionStatus.Inactive;
        bidends =0;
        delete _Bids;

    }
    
    function getOwner() constant returns (address)
    {
        return owner;
    }
    
    function getendtime() constant returns(uint){
        return bidends;
    }
    
    function getAuctionStatus() returns (uint )
    {
        if(_auctionstatus == AuctionStatus.Inactive){return 0;}
        
        else if(_auctionstatus == AuctionStatus.Active){return 1;}
        
        else if(_auctionstatus == AuctionStatus.Pending){return 2;}
    }
    
    function WithdrawToOwner() payable
    {
        require(msg.sender == owner);
        owner.transfer(this.balance);
    }
}