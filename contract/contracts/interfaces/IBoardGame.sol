// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.28;

interface IBoardGame {
    function createGame(uint256 gameId) external;
    function joinGame( uint256 gameId, uint8 piece) external;
    function startGame( uint256 gameId) external;
    function rollDice( uint256 gameId) external returns (uint256 dieOne, uint256 dieTwo);  // return type -> (u8, u8)
    function buyProperty( uint256 gameId, uint8 position) external;
    function buyHouse( uint256 gameId, uint8 position) external;
    function sellHouse( uint256 gameId, uint8 position) external;
    function mortgageProperty( uint256 gameId, uint8 position) external;
    function unmortgageProperty( uint256 gameId, uint8 position) external;
    function nextTurn( uint256 gameId) external;
    function payRent( uint256 gameId, uint8 propertyPosition) external;
    function useJailFreeCard( uint256 gameId) external;
    function payToLeaveJail( uint256 gameId) external;
    function declareBankruptcy( uint256 gameId) external;
    function setNFTContract( address nftContract) external;
    function setOwner( address owner) external;
}