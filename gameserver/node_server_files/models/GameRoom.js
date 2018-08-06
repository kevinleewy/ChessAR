var constants = require('../shared/constants.js');
const Chess = require('chess.js').Chess;

MAX_NUMBER_OF_PLAYERS = 2;
MIN_NUMBER_OF_PLAYERS = 2;
MAX_NUMBER_OF_SPECTATORS = 10;
MIN_NUMBER_OF_SPECTATORS = 0;

module.exports = class GameRoom {

	constructor(creatorId){
		this.players = [creatorId];
		this.spectators = [];
		this.status = constants.GAME_STATUS.WAITING;
		this.chess = null;
	}

	addAsPlayer(playerId) {
		if(this.players.length >= MAX_NUMBER_OF_PLAYERS){
			throw 1003;
		}
		this.players.push(playerId);
	}

	addAsSpectator(spectatorId) {
		if(this.spectators.length >= MAX_NUMBER_OF_SPECTATORS){
			throw 1004;
		}
		this.spectators.push(spectatorId);
	}

	removeAsPlayer(playerId) {
		for(var i=0; i < this.players.length; i++){
			if(this.players[i] === playerId){
				this.players.splice(i, 1);
				return;
			}
		}
		throw 1005;
	}

	removeAsSpectator(spectatorId) {
		for(var i=0; i < this.spectators.length; i++){
			if(this.spectators[i] === spectatorId){
				this.spectators.splice(i, 1);
				return;
			}
		}
		throw 1006;
	}

	isPlayer(id){
		return this.players.includes(id);
	}

	isSpectator(id){
		return this.spectators.includes(id);
	}

	startGame(id) {
		if(this.players < MIN_NUMBER_OF_PLAYERS){
			throw 1008;
		}

		if(this.players > MAX_NUMBER_OF_PLAYERS){
			throw 1009;
		}

		if(this.spectators < MIN_NUMBER_OF_SPECTATORS){
			throw 1010;
		}

		if(this.spectators > MAX_NUMBER_OF_SPECTATORS){
			throw 1011;
		}

		if(this.status === constants.GAME_STATUS.ACTIVE){
			throw 1102;
		}

		if(this.status === constants.GAME_STATUS.ENDED){
			throw 1103;
		}

		//Only game room owner can start the game
		if(id !== this.players[0]){
			throw 1104;
		}

		this.status = constants.GAME_STATUS.ACTIVE;
		this.chess = new Chess();
		this.chess.header('White', this.players[0], 'Black', this.players[1]);
		return true;
	}

	endGame(id) {

		if(this.status === constants.GAME_STATUS.ENDED){
			throw 1103;
		}

		this.status = constants.GAME_STATUS.ENDED;
	}

	isActive() {
		return this.chess && !this.chess.game_over();
	}

	hasEnded() {
		return this.chess && this.chess.game_over();
	}

	getGameRoomState(id) {
		if(!this.isPlayer(id) && !this.isSpectator(id)){
			throw 1007;
		}

		return {
			status 			: this.status,
			players 		: this.players,
			spectators 		: this.spectators,
			minPlayers 		: MIN_NUMBER_OF_PLAYERS,
			maxPlayers 		: MAX_NUMBER_OF_PLAYERS,
			minSpectators 	: MIN_NUMBER_OF_SPECTATORS,
			maxSpectators 	: MAX_NUMBER_OF_SPECTATORS,
			gameState 		: this.chess ? this.chess.fen() : null
		}
	}

	getGameState(id) {
		if(!this.isPlayer(id) && !this.isSpectator(id)){
			throw 1007;
		}

		if(this.status === constants.GAME_STATUS.WAITING){
			throw 1101;
		}

		if(this.status === constants.GAME_STATUS.ENDED){
			throw 1103;
		}

		if(this.isSpectator(id)){
			id = this.players[0];
		}
		return {
			header: this.chess.header(),
			board: this.chess.fen(),
			turn: this.chess.turn(),
			moves: this.chess.moves({verbose: true})
		};
	}

	getParticipants() {
		return this.players.concat(this.spectators);
	}

	getMoves() {
		return this.chess.moves({verbose: true});
	}

	conductAction(playerId, action) {

		if(!this.isPlayer(playerId)){
			throw 1005;
		}

		if(this.status === constants.GAME_STATUS.WAITING){
			throw 1101;
		}

		if(this.hasEnded()){
			throw 1103;
		}

		if(!this.chess.moves().includes(action)){
			throw `Invalid action: ${action}`
		}

		console.log("Conducting action " + action);

		const actionResult = this.chess.move(action);

		//check for game end
		//this.chess.
		return {
			result: actionResult,
			turn: this.chess.turn(),
			moves: this.chess.moves({verbose: true})
		};
	}
};