const GameRoom = require('../models/GameRoom');

module.exports = class GameRoomService {

	constructor() {
		this.gameRooms = {}; //mapping(player ID => GameController) many-to-one
	}

	/**
	 * Checks whether playerId already has an active game room
	 * @param {string} playerId
	 * @returns {boolean}
	 */
	gameRoomExists(playerId) {
		return !!this.gameRooms[playerId];
	}

	/**
	 * Creates a game room
	 * @param string creator playerId
	 * @return gameRoomState
	 * @throw int - errorCode
	 */
	createGameRoom(playerId) {

		//if already part of a game room
		if( this.gameRoomExists(playerId) ){
			throw 1001;
		}

		this.gameRooms[playerId] = new GameRoom(playerId);
		return this.gameRooms[playerId].getGameRoomState(playerId);
	}

	/**
	 * Destroys a game room
	 * @param playerId - player Id initiating game room destruction
	 * @param io - SocketIO object
	 * @param socketIds - mapping from playerId to socketId
	 * @throw int - errorCode
	 */
	destroyGameRoom(playerId) {
		//if game room doesn't exist
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		const gameRoom = gameRooms[playerId];
		const participants = gameRoom.getAllParticipants();
		participants.forEach(playerId => {
			this.gameRooms[id] = null;
		});

		console.log(`${playerId} destroyed game room`);
		return;
	}

	/**
	 * Joins a game room as a player or spectator
	 * @param string playerId - player who is requesting to join
	 * @param string gameRoomParticipantId - Another participant already in desired game room
	 * @param bool asPlayer
	 * @return GameState
	 * @throw int - errorCode
	 */
	joinGameRoom(playerId, gameRoomParticipantId, asPlayer) {
		
		//if already part of a game room
		if( this.gameRoomExists(playerId) ){
			throw 1001;
		}

		//if game room doesn't exist
		if( !this.gameRoomExists(gameRoomParticipantId) ){
			throw 1002;
		}

		const gameRoom = this.gameRooms[gameRoomParticipantId];

		if( asPlayer ){
			gameRoom.addAsPlayer(playerId);	//throws if fail
		} else {
			gameRoom.addAsSpectator(playerId);	//throw if fail
		}

		this.gameRooms[playerId] = gameRoom;
		//console.log(playerId + " successfully joins the same game room as " + gameRoomParticipantId);
		var response = {
			"newParticipant"  : playerId,
			"asPlayer"		  : asPlayer,
			"participants"    : gameRoom.getParticipants(),
			"status"		  : gameRoom.status
		};
		return response;
	}

	/**
	 * Leaves a game room
	 * @param string playerId - player who is requesting to join
	 * @param bool asPlayer
	 * @throw int - errorCode
	 */
	leaveGameRoom(playerId, asPlayer) {

		//if game room doesn't exist
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		var gameRoom = this.gameRooms[playerId];
		if( asPlayer ){
			gameRoom.removeAsPlayer(playerId); //throws if fail
		} else {
			gameRoom.removeAsSpectator(playerId); //throws if fail
		}
		this.gameRooms[playerId] = null;
		var response = {
			"removedParticipant" : playerId,
			"asPlayer"		     : asPlayer,
			"participants"    	 : gameRoom.getParticipants(),
			"status"		  	 : gameRoom.status
		};
		return response;
	}

	/**
	 * Retrieves game room state
	 * @param playerId - player Id requesting gameState
	 * @return GameRoomState
	 * @throw int - errorCode
	 */
	getGameRoomState(playerId) {
		//if game room doesn't exist
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		return this.gameRooms[playerId].getGameRoomState(playerId);
	}

	/**
	 * Retrieves game state from game room
	 * @param playerId - player Id requesting gameState
	 * @return GameState
	 * @throw int - errorCode
	 */
	getGameState(playerId) {
		//if game room doesn't exist
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		return this.gameRooms[playerId].getGameState(playerId);
	}

	/**
	 * Requests to start the game in a game room
	 * @param playerId - player Id requesting gameStart
	 * @return array - participants
	 * @throw int - errorCode
	 */
	startGame(playerId) {
		//if game room doesn't exist
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		const gameRoom = this.gameRooms[playerId];
		gameRoom.startGame(playerId);
		return gameRoom.getParticipants();
	}

	/**
	 * Conduct a game-related action
	 * @param playerId - player Id conducting the action
	 * @return GameState
	 * @throw int - errorCode
	 */
	conductAction(playerId, action) {
		if( !this.gameRoomExists(playerId) ){
			throw 1002;
		}
		const gameRoom = this.gameRooms[playerId];
		if( gameRoom.hasEnded() ){
			throw 1103;
		}
		const response = gameRoom.conductAction(playerId, action);
		const participants = gameRoom.getParticipants();
		return [response, participants];
	}

};