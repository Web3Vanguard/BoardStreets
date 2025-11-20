// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

import "./interfaces/IBoardGame.sol";
import "./lib/event.sol";

contract BoardStreet {

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

    mapping(uint256 => Game) games;
    mapping(address => Player) players;

    function createGame(uint256 gameId) external{
        Game memory game = Game({
            gameId: gameId,
            host: msg.sender,
            started: false,
            currentPlayer: 0,
            playerCount: 0,
            winner: address(0),
            turnTimeout: 30
        });

        games[gameId] = game;

        emit Events.GameCreated(msg.sender, gameId);
        
    }

    function joinGame(uint256 gameId, uint8 _piece) external {
        Game storage getGame = games[gameId];

        require(!getGame.started, "Game started already");
        require(getGame.playerCount < 4, "Game is already complete");

        Player memory player = Player({
            gameId: gameId,
            playerAddress: msg.sender,
            playerId: getGame.playerCount,
            position: 0,
            money: 1500,
            piece: _piece,
            isActive: true,
            bankRupt: false,
            inJail: false,
            jailTurns: 0,
            jailGetOutFree: 0
        });

        players[msg.sender] = player;
        getGame.playerCount += 1;

        emit Events.JoinGame(msg.sender, gameId);
    }

    function startGame(uint256 gameId) external {
        Game storage getGame = games[gameId];

        require(msg.sender == getGame.host, "Only host can start game");
        require(getGame.playerCount >= 2, "Minimum of two players needed to play");
        require(!getGame.started, "Game started already");

        getGame.started = true;
        getGame.currentPlayer = 0;

        emit Events.GameStarted(gameId, msg.sender);
    }
}