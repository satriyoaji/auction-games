## Solidity Project about Auction & Bid games

[**Solidity**](https://docs.soliditylang.org/) is an object-oriented, high-level language for implementing smart contracts. Smart contracts are programs which govern the behaviour of accounts within the Ethereum state.


###  How to setting and run this Repository

- Open the smart contract IDE, like using [**Remix**](https://remix.ethereum.org/)  
- Compile and Deploy the SmartContract

### This project is consists of Admin as an auction manager and Player as a auction member.
#### As an Admin:
1. add Item bid using `addItemBid` function
2. find Item bid using `findItemBidByName` function
3. delete Item bid using `deleteItemBidByName` function
4. add Member data detail using `addMember` function
5. find Member data detail using `findMemberByAddress` function
6. delete Member data detail using `deleteMember` function
7. add Member coin balance using `addMemberCoin` function
8. start and end auction session using `startAuction` and `endAuction` function
9. get winner of the opened auction session using `getWinnerOfItemBid` function

#### As a Player:
1. Bid action using `bid` function
2. Topup coin balance using `topupBalance` function
3. find Item bid using `findItemBidByName` function

#### Positive test cases:
1. As Admin, add Item bid
    a. find Item bid to check all of added item
2. As Admin, add Member data with other address and some balance (if needed)
    a. find Member data to check all of added Member
3. As Admin, add Member's coin balance (either only)
4. As Admin, start auction session of 1 item
    a. can start another item bid
    b. start again the item that has been started, so it will throw an error validation that can't be started again
5. As Member, can topup balance (either only)
6. As Member, can bid the started item in an auction. Make sure the bid price must higher than previous price bid.
    a. the lose Member that has bid before, will be returning its price bid to the Member again
7. As Admin, can stop the started auction item. So it will return the winner of the auction. And the price bid of the winner will transferred to the Admin's balance
8. As Admin, delete the item bid of the previous stopped auction
9. As admin can delete the unusual Member