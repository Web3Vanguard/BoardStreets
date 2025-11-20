// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

library BoardTypes {
    struct Game {
        uint256 gameId;
        address host;
        bool started;
        uint8 currentPlayer;
        uint8 playerCount;
        address winner;
        uint8 turnTimeout;
    }

    struct Player {
        uint256 gameId;
        address playerAddress;
        uint8 playerId;
        uint8 position;
        uint32 money;
        uint8 piece;
        bool isActive;
        bool bankRupt;
        bool inJail;
        uint8 jailTurns;
        uint8 jailGetOutFree;
    }

    struct Property {
        uint256 gameId;
        uint8 position;
        address owner;
        uint8 houses;
        uint32 price;
        uint32 rentBase;
        uint32 housePrice;
        uint8 colorGroup;
        bool mortgaged;
    }

    struct GameMove {
        uint256 gameId;
        uint32 moveId;
        address player;
        uint8 dice1;
        uint8 dice2;
        uint8 newPosition;
        uint64 timestamp;
    }
}