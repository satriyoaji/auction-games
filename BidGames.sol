// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract BidGames {
    // admin BidGames
    address admin;
    uint256 itemBidNotFoundStatus = 9999;

    event LogMemberFundingReceived(address addr, uint coin, uint contractBalance);
    event LogAdminRole(address addrAdmin, string roleMessage);
    event LogBidSuccess(address addrMember, string itemName, string successMessage);
    event LogBidWinner(string itemName, string winnerName, uint bidPriceWon);
    event checkLogString(string message, uint256 idx);

    constructor() {
        admin = msg.sender;
        emit LogAdminRole(admin, "You're an Admin of this Auction game");
    }

    struct Member {
        string name;
        uint coin;
        bool canBid;
        uint blockTime;
        uint blockNumber;
    }
    mapping(address => Member) private dataMember;
    address[] private arrAddressMembers;
    
    struct ItemBid {
        string name;
        uint highestBidPrice;
        address lastBidMemberAddress;
        uint lastBidTimeAt;
        uint openAuctionTimeAt;
        bool active;
    }
    ItemBid[] private itemBids;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the Admin can operate");
        _;
    }
    modifier onlyMemberRegistered() {
        require(msg.sender != admin, "Only the Member can operate. Admin is prohibited!");
        require(checkIfMemberExist(msg.sender) == true, "Only the registered Member (by Admin) can operate.");
        _;
    }

    function addMember(address payable _walletAddress, string memory _memberName, bool _canBid) public onlyAdmin {
        require(!checkIfMemberExist(_walletAddress), "The member has already registered (by Admin).");

        dataMember[_walletAddress].name = _memberName;
        dataMember[_walletAddress].coin = 0;
        dataMember[_walletAddress].canBid = _canBid;
        dataMember[_walletAddress].blockTime = block.timestamp;
        dataMember[_walletAddress].blockNumber = block.number;
        // _walletAddress.transfer(_coin);
        arrAddressMembers.push(_walletAddress);
    }

    function addItemBid(string memory _itemName) public onlyAdmin {

        itemBids.push(ItemBid(
            _itemName,
            0,
            address(0), //address(0)
            0,
            0,
            false
        ));
    }

    function deleteMember(address _rekAddress) public {
        require(checkIfMemberExist(_rekAddress) == true , "Member address not found!");
        delete dataMember[_rekAddress];
        removeAddressByValue(_rekAddress);
    }

    function removeMemberByIdx(uint256 _idx) private {
        if (_idx >= arrAddressMembers.length) return;
     //    delete arrAddressMembers[_idx];
        for (uint256 i = _idx; i<arrAddressMembers.length-1; i++){
            arrAddressMembers[i] = arrAddressMembers[i+1];
        }
        arrAddressMembers.pop();
    }
    function removeAddressByValue(address _rekAddress) private {
        for (uint256 i = 0; i<arrAddressMembers.length; i++){
            if (_rekAddress == arrAddressMembers[i]) {
                    removeMemberByIdx(i);
                    return;
            }
        }
    }

    function findMemberByAddress(address _rekAddress) public view
    returns(Member memory) {
        require(checkIfMemberExist(_rekAddress) == true , "Member address not found!");
        return dataMember[_rekAddress];
        // return (itemName, highestBidPrice, lastBidMemberAddress, lastBidTimeAt, openAuctionTimeAt, active);
    }

    function checkIfMemberExist(address _memberAddress) private view returns (bool) {
        for (uint256 i = 0; i<arrAddressMembers.length; i++){
            if (_memberAddress == arrAddressMembers[i]) {
                    return true;
            }
        }
        return false;
    }

    function balanceOf(address _walletAddress) public view returns(uint) {
        return address(_walletAddress).balance;
    }

    function topupBalance() payable public onlyMemberRegistered {
        // only Ether that can be accepted
        require(msg.value % 1 ether == 0 , "Topup value must be in Ether!");
        dataMember[msg.sender].coin = dataMember[msg.sender].coin + msg.value;
        emit LogMemberFundingReceived(msg.sender, msg.value, balanceOf(msg.sender));
    }

    //topupBalance funds to contract, specifically to a member's account
    function addMemberCoin(address _walletAddress) payable public onlyAdmin {
        // only Ether that can be accepted
        require(msg.value % 1 ether == 0 , "Topup value must be in Ether!");

        require(checkIfMemberExist(_walletAddress) == true, "Only the registered Member (by Admin) can operate.");

        dataMember[_walletAddress].coin = dataMember[_walletAddress].coin + msg.value;
        emit LogMemberFundingReceived(_walletAddress, msg.value, balanceOf(_walletAddress));
    }

    function findItemBidByName(string memory _itemName) public view
    returns(ItemBid memory) {
        uint256 idx = findItemIdxByName(_itemName);
        require(idx != itemBidNotFoundStatus, "Item bid not found");
        // emit checkLogString(itemBids[idx].name, idx);
        return itemBids[idx];
    }

    modifier itemBidCheckActive(string memory _itemName, bool _status) {
        uint256 idx = findItemIdxByName(_itemName);
        require(idx != itemBidNotFoundStatus, "Item bid not found");
        if (_status){
            require(itemBids[idx].active == true, "Item must be actived to bid");
        }
        else {
            require(itemBids[idx].active == false, "Item must not be actived to bid");
        }

        _;
    }

    function findItemIdxByName(string memory _name) private view returns(uint256) {
        for (uint256 i = 0; i<itemBids.length; i++){
            if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(itemBids[i].name))) {
                return i;
            }
        }
        return itemBidNotFoundStatus;
    }
    function deleteItemBidByName(string memory _name) public itemBidCheckActive(_name, false) onlyAdmin {
        uint256 idx = findItemIdxByName(_name);
        removeItemByIdx(idx);
    }
    function removeItemByIdx(uint256 _idx) private {
        if (_idx >= itemBids.length) return;
        
        for (uint256 i = _idx; i<itemBids.length-1; i++){
            itemBids[i] = itemBids[i+1];
        }
        itemBids.pop();
    }

    function startAuction(string memory _itemName) public onlyAdmin itemBidCheckActive(_itemName, false) {
        uint256 idx = findItemIdxByName(_itemName);
        require(itemBids[idx].openAuctionTimeAt == 0, "Item bid have ever been opened for auction before."); //just once auction opened
        itemBids[idx].openAuctionTimeAt = block.timestamp;
        itemBids[idx].active = true;
    }

    function endAuction(string memory _itemName) public onlyAdmin itemBidCheckActive(_itemName, true) {
        uint256 idx = findItemIdxByName(_itemName);
        itemBids[idx].active = false;
    }

    function getWinnerOfItemBid(string memory _itemName) public onlyAdmin itemBidCheckActive(_itemName, false) returns(string memory) {
        uint256 idx = findItemIdxByName(_itemName);
        require(itemBids[idx].openAuctionTimeAt > 0, "Item bid must ever been opened in the auction!");
        require(itemBids[idx].lastBidMemberAddress != address(0) && itemBids[idx].highestBidPrice > 0, "Item bid must have a winner first!");

        emit LogBidWinner(_itemName, findMemberByAddress(itemBids[idx].lastBidMemberAddress).name, itemBids[idx].highestBidPrice);

        return findMemberByAddress(itemBids[idx].lastBidMemberAddress).name;
    }


    function bid(string memory _itemName, uint _bidPrice) public onlyMemberRegistered {
        uint256 idxitemBid = findItemIdxByName(_itemName);
        require(idxitemBid != itemBidNotFoundStatus, "Item bid not found");
        require(itemBids[idxitemBid].highestBidPrice < (_bidPrice*1 ether), "Item price that need to bid must be higher than last highest bid price!");
        require(itemBids[idxitemBid].openAuctionTimeAt > 0, "Item bid need to open in auction first!");
        require(itemBids[idxitemBid].active == true, "Item status need to be activated to bid first!");

        require(dataMember[msg.sender].coin > _bidPrice, "Member's balance must be greater then price that wanna bid!");

        // Returning  Coin balance if last bid member is losebid
        if (itemBids[idxitemBid].lastBidMemberAddress != address(0) && itemBids[idxitemBid].highestBidPrice > 0) {
            dataMember[itemBids[idxitemBid].lastBidMemberAddress].coin += itemBids[idxitemBid].highestBidPrice;
            // payable(itemBids[idxitemBid].lastBidMemberAddress).transfer(itemBids[idxitemBid].highestBidPrice);
        }

        // update the item bid
        itemBids[idxitemBid].highestBidPrice = (_bidPrice*1 ether);
        itemBids[idxitemBid].lastBidTimeAt = block.timestamp;
        itemBids[idxitemBid].lastBidMemberAddress = msg.sender;

        // update the member's coin
        dataMember[msg.sender].coin = dataMember[msg.sender].coin-(_bidPrice*1 ether);
        payable(admin).transfer(_bidPrice*1 ether);
        // payable(msg.sender).transfer((address(this).balance - _bidPrice));

        emit LogBidSuccess(msg.sender, _itemName, "Successfully bid item!");
    }

}