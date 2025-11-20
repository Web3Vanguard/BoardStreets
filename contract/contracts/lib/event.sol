// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

library Events {
    event GameCreated(address indexed host, uint256 gameId);
    event JoinGame(address player, uint256 gameId);
    event GameStarted(uint256 gameId, address host);
    event DiceRolled(uint256 gameId, address player, uint256 dieOne, uint256 dieTwo, bool stillInJail);
}