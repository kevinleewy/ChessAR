const GameRoomService = require('../services/GameRoomService');
const constants = require('../shared/constants');
const errorCode = require('../models/errorCode');
const SocketService = require('../services/SocketService');
const services = require('servicemanager').default;

module.exports = class GameRoomController {

	constructor() {
		services.ensure(
			[ GameRoomService.name, SocketService.name ],
			(gameRoomService, socketService) => {
				this.gameRoomService = gameRoomService;
				this.socketService = socketService;
		});
	}

	getGameRoom(request, response) {

		const id = request.params.id;

	    if(this.gameRoomService.gameRoomExists(id)) {
	    	response.send({
	    		status: 'OK',
	    		message: this.gameRoomService.getGameRoomState(id)
	    	});
	    } else {
	    	response.send({
	    		status: 'ERROR',
	    		message: `Game room does not exist for ${id}`
	    	});
	    }
	}


	enterGameRoom(request, response) {

		const id = request.params.id;
		const roomId = request.query.roomId;

		try {

			//If already in a game room
			if(this.gameRoomService.gameRoomExists(id)) {
				throw 9990;
		    }

		    var gameRoomState;

		    if(!!roomId) {
		    	//If room with specified ID does not exist
				if(!this.gameRoomService.gameRoomExists(roomId)) {
					throw 1002;
			    }
			    gameRoomState = this.gameRoomService.joinGameRoom(request.params.id, roomId, true);

				switch(gameRoomState["status"]){
					case constants.GAME_STATUS.WAITING:

						//announce to all game room participants
						this.socketService.emitSocketEvent(
							gameRoomState.participants.filter(p => {
								return p !== gameRoomState.newParticipant;
							}),
							'playerJoined',
							gameRoomState.newParticipant
						);
						break;

					case constants.GAME_STATUS.ENDED:
						throw 1103;
						break;

					case constants.GAME_STATUS.ACTIVE:
						break;

					default:
						throw 1100;
				}

			} else {
		    	gameRoomState = this.gameRoomService.createGameRoom(id);
		    }

			response.send({
				status  : 'OK',
				message : gameRoomState
			});
		} catch(err) {
			const lang = !!request.query.lang ? request.query.lang : "EN";
			console.log(err, errorCode(err, lang))
			response.send({
				status: 'ERROR',
				message: errorCode(err, lang)
			});
		}
	}

	leaveGameRoom(request, response) {

		const id = request.params.id;
		const roomId = request.query.roomId;

		try {
			const gameRoomState = this.gameRoomService.leaveGameRoom(id, true);

			switch(gameRoomState["status"]){
				case constants.GAME_STATUS.WAITING:
					//announce to all game room participants
					this.socketService.emitSocketEvent(
						gameRoomState.participants,	//TODO: exclude new participant
						'playerLeft',
						gameRoomState.removedParticipant
					);
					break;

				case constants.GAME_STATUS.ENDED:
					throw 1103;
					break;

				case constants.GAME_STATUS.ACTIVE:
					break;

				default:
					throw 1100;
			}

			response.send({
				status  : 'OK',
				message : gameRoomState
			});
		} catch(err) {
			const lang = !!request.query.lang ? request.query.lang : "EN";
			console.log(err, errorCode(err, lang))
			response.send({
				status: 'ERROR',
				message: errorCode(err, lang)
			});
		}
	}
};