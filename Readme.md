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

#### As an Player:
1. Bid action using `bid` function
2. Topup coin balance using `topupBalance` function
3. find Item bid using `findItemBidByName` function
