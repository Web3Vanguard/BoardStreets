// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

library Events {
    event GameCreated(address indexed host, uint256 gameId);
    event JoinGame(address player, uint256 gameId);
    event GameStarted(uint256 gameId, address host);
    event DiceRolled(uint256 gameId, address player, uint256 dieOne, uint256 dieTwo, bool stillInJail);
    event PropertyPurchased(uint256 gameId, address, uint8, uint32);
    event HouseBought(uint256, address, uint8, uint8);
    event HouseSold(uint256, address, uint8, uint8, uint32);
    event PropertyMortgaged(uint256, address, uint8, uint32);
    event PropertyUnMortgaged(uint256, address, uint8, uint32);
    event JailFreeCardUsed(uint256, address);
    event PaidToLeaveJail(uint256, address, uint8);
    event GameWon(uint256, address);
    event PlayerBankRupt(uint256, address);
    event TurnChanged(uint256, uint8);
}