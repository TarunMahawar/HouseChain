pragma solidity ^0.4.2;

import './Asset.sol';

contract Reoligy{
    address public owner;
    function Reoligy() public{
        owner = msg.sender;
    }
    
    //Active == Bidding on; Pending == Bidding has been done recently and waiting for transfer to new owner
    // Inactive == you know this
    enum AuctionStatus{Active , Inactive, Pending}
    address public temp;
    struct UserAsset{
        address contractAddress;
        AuctionStatus _AuctionStatus;
    }
    
    mapping(address =>  UserAsset[]) public contractsByUser;
    
    struct AuctionedAsset{
        address AssetOwner;
        address AssetAddress;
    }
    
    AuctionedAsset[] public _auctionedAssets;
    
    function RegisterAsset( address _contract)
    {
        Asset _asset = Asset(_contract);
    
        address _assetOwner = _asset.getOwner();
        temp = _asset.getOwner();
         UserAsset _userAsset;
        if(msg.sender == _assetOwner)
        {
            _userAsset.contractAddress = _contract;
            _userAsset._AuctionStatus = AuctionStatus.Inactive;
            contractsByUser[msg.sender].push(_userAsset);
        }
    }
    
    function AddtoAuction(uint indexOfAsset)
    {
        require(indexOfAsset < contractsByUser[msg.sender].length);
        require(contractsByUser[msg.sender][indexOfAsset]._AuctionStatus == AuctionStatus.Pending);
        address _contractAddress = contractsByUser[msg.sender][indexOfAsset].contractAddress;

        Asset _asset = Asset(_contractAddress);
        require(_asset.getAuctionStatus() == 1);
        
        AuctionedAsset _tempAuctionedAsset;
        _tempAuctionedAsset.AssetOwner = msg.sender;
        _tempAuctionedAsset.AssetAddress = _contractAddress;
        
        _auctionedAssets.push(_tempAuctionedAsset);
    }
    
    
}