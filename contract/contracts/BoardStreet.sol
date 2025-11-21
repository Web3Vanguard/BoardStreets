// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

import "./interfaces/IBoardGame.sol";
import "./lib/event.sol";
import "./NFTToken.sol";

contract BoardStreet {

    mapping(uint256 => Game) games;
    mapping(address => Player) players;
    mapping(uint256 => mapping(uint32 => GameMove)) gameMoves;
    mapping(uint256 => mapping(uint8 => Property)) property;
    address public NFTToken;

    constructor(address _NFTToken) {
        NFTToken = _NFTToken;
    }

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
        uint256 dice1;
        uint256 dice2;
        uint8 newPosition;
        uint256 timestamp;
    }

    

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
        Game storage game = games[gameId];

        require(!game.started, "Game started already");
        require(game.playerCount < 4, "Game is already complete");

        Player memory player = Player({
            gameId: gameId,
            playerAddress: msg.sender,
            playerId: game.playerCount,
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
        game.playerCount += 1;

        emit Events.JoinGame(msg.sender, gameId);
    }

    function startGame(uint256 gameId) external {
        Game storage game = games[gameId];

        require(msg.sender == game.host, "Only host can start game");
        require(game.playerCount >= 2, "Minimum of two players needed to play");
        require(!game.started, "Game started already");

        game.started = true;
        game.currentPlayer = 0;

        emit Events.GameStarted(gameId, msg.sender);
    }

    function rollDice(uint256 gameId) external returns(uint256 dieOne, uint256 dieTwo) {
        Game storage game = games[gameId];
        Player storage player = players[msg.sender];

        require(game.started, "Game not started yet");


        bytes32 randomNess = keccak256(abi.encodePacked(block.timestamp, block.gaslimit, msg.sender, block.number));



        uint256 dieOne = (uint256(randomNess) % 6) + 1;
        uint256 dieTwo = (uint256(keccak256(abi.encodePacked(randomNess))) % 6) + 1;

        if (player.inJail) {
            if (dieOne == dieTwo) {
                player.inJail = false;
                player.jailTurns = 0;
            } else {
                player.jailTurns += 1;
                if (player.jailTurns >= 3) {
                    player.inJail = false;
                    player.jailTurns = 0;
                    player.money -= 50;
                } else {
                    emit Events.DiceRolled(gameId, msg.sender, dieOne, dieTwo, true);

                    return (dieOne, dieTwo);
                }
            }
        }

        uint8 total = uint8(dieOne + dieTwo);
        uint8 newPosition = player.position + total;

        if (newPosition >= 40) {
            player.money += 200;
            newPosition = uint8(newPosition % 40);
        }

        player.position = newPosition;

        uint32 moveCount = getMoveCount(gameId);

        GameMove memory gameMove = GameMove({
            gameId: gameId,
            moveId: moveCount,
            player: msg.sender,
            dice1: dieOne,
            dice2: dieTwo,
            newPosition: newPosition,
            timestamp: block.timestamp
        });

        gameMoves[gameId][moveCount] = gameMove;

        emit Events.DiceRolled(gameId, msg.sender, dieOne, dieTwo, false);

        return (dieOne, dieTwo);
    }


    function getMoveCount(uint256 gameId) internal returns (uint32) {
        uint32 count = 0;
        uint32 i = 0;

        while (i < 1000) {
            GameMove memory gameMove = gameMoves[gameId][i];
            if (gameMove.timestamp == 0) {
                break;
            }
            count += 1;
            i += 1;
        }

        return count;
    }

    function buyProperty(uint256 gameId, uint8 position) external {
        Player storage player = players[msg.sender];
        Property storage property = property[gameId][position];

        require(property.owner == address(0), "Property already owned");
        require(player.money >= property.price, "Insufficient money to buy property");

        player.money -= property.price;
        property.owner = msg.sender;


        BoardStreetNFT(NFTToken).mint(msg.sender, uint256(position), 1, bytes(abi.encodePacked("")));

        emit Events.PropertyPurchased(gameId, msg.sender, position, property.price);
    }


    function buyHouse(uint256 gameId, uint8 position) external {
        Player storage player = players[msg.sender];
        Property storage property = property[gameId][position];

        require(property.owner == msg.sender, "You do not own the property");
        require(property.houses < 5, "Only maximum of five houses per hotel");
        require(!property.mortgaged, "Property is already mortgaged");
        require(player.money >= property.housePrice, "Insufficient funds to make purchase");
        
        player.money -= property.housePrice;
        property.houses += 1;

        BoardStreetNFT NFTTokenContract = BoardStreetNFT(NFTToken);

        if (property.houses == 5) {
            uint256 houseTokenID = 1000 + uint256(position);
            NFTTokenContract.burn(msg.sender, houseTokenID, 4);

            uint256 hotelTokenId = 2000 + uint256(position);
            NFTTokenContract.mint(msg.sender, hotelTokenId, 1, bytes(abi.encodePacked("")));
        } else {
            uint256 houseTokenId = 1000 + uint256(position);
            NFTTokenContract.mint(msg.sender, houseTokenId, 1, bytes(abi.encodePacked("")));
        }

        emit Events.HouseBought(gameId, msg.sender, position, property.houses);
    }

    function sellHouse(uint256 gameId, uint8 position) external {
        Player storage player = players[msg.sender];
        Property storage property = property[gameId][position];

        require(property.owner == msg.sender, "Not your property");
        require(property.houses > 0, "No houses to sell");

        BoardStreetNFT NFTTokenContract = BoardStreetNFT(NFTToken);

        if (property.houses == 5) {
            uint256 hotelTokenId = 2000 + uint256(position);

            NFTTokenContract.burn(msg.sender, hotelTokenId, 1);

            uint256 houseTokenId = 1000 + uint256(position);
            NFTTokenContract.mint(msg.sender, houseTokenId, 4, bytes(abi.encodePacked("")));
        } else {
            uint256 houseTokenId = 1000 + uint256(position);
            NFTTokenContract.burn(msg.sender, houseTokenId, 1);
        }

        uint32 sellPrice = property.housePrice / 2;
        player.money += sellPrice;
        property.houses -= 1;

        emit Events.HouseSold(gameId, msg.sender, position, property.houses, sellPrice);


    }

    function mortgageProperty(uint256 gameId, uint8 position) external {
        Player storage player = players[msg.sender];
        Property storage property = property[gameId][position];

        require(property.owner == msg.sender, "Not your property");
        require(!property.mortgaged, "Property already mortgaged");
        require(property.houses == 0, "Sell houses first");

        uint32 mortgageValue = property.price / 2;
        player.money += mortgageValue;
        property.mortgaged = true;

        emit Events.PropertyMortgaged(gameId, msg.sender, position, mortgageValue);


    }
}