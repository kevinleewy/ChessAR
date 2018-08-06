const errorCode = require('../models/errorCode.js');

const GameRoomService = require('../services/GameRoomService');
const services = require('servicemanager').default;

const http = require('http');
const SocketIO = require('socket.io');

module.exports = class SocketService {

    constructor(port) {

        this.port = port;
        services.ensure(
          [ GameRoomService.name ],
          (gameRoomService) => {
            this.gameRoomService = gameRoomService;
        });

        this.emitSocketEvent = this.emitSocketEvent.bind(this);
    }

    createSocket() {
        const socketServer = http.createServer();
        this.io = SocketIO(socketServer);

        this.socketClients = {}; //mapping(token=>{id, token})
        this.bindEvents();

        socketServer.listen(this.port);
        console.log(`Server started. SocketIO listening on port ${this.port}`);
    }

    bindEvents() {

      const self = this;

      // event called on Socket.IO connection
      this.io.on('connect', function(client) {

        // incoming parameters
        let token = client.handshake.query.token;
        console.log ("connected: " + client.id); // print to console the incoming socket ID

        // create an object with the socketID and the token that's associated with
        let clientConnection = {
            socketid: client.id,
            token: token
        };

        self.socketClients[token] = clientConnection;

        client.on('retrieveGameRoom', message => {
            try {
                const response = self.gameRoomService.getGameRoomState(token);
                client.emit('gameRoomRetrieved', response);

            } catch(err) {
                const lang = !!message.lang ? message.lang : "EN";
                const errorMsg = errorCode(err, lang)
                console.error(err, errorMsg);
                client.emit('appError', [err, errorMsg]);
            }
        });

        client.on('startGame', message => {
         
          try {
              const participants = self.gameRoomService.startGame(token);

              //announce to all game room participants
              self.emitSocketEvent(participants, 'gameStarted');

          } catch(err) {
              const lang = !!message.lang ? message.lang : "EN";
              const errorMsg = errorCode(err, lang)
              console.error(err, errorMsg);
              client.emit('appError', [err, errorMsg]);
          }
        });

        client.on('joinGame', function(message){
          try {
            const response = self.gameRoomService.getGameState(token);
            //console.log(response);
            client.emit('joinedGame', response);

          } catch(err) {
            const lang = !!message.lang ? message.lang : "EN";
            const errorMsg = errorCode(err, lang)
            console.error(err, errorMsg);
            client.emit('appError', [err, errorMsg]);
          }
        });

        client.on('actionSelect', function(message){
          try {
            var response, participants;
            [response, participants] = self.gameRoomService.conductAction(token, message.action);
            //console.log(response);
            self.emitSocketEvent(participants, 'actionResponse', response);

          } catch(err) {
            const lang = !!message.lang ? message.lang : "EN";
            const errorMsg = errorCode(err, lang)
            console.error(err, errorMsg);
            client.emit('appError', [err, errorMsg]);
          }
        });


        client.on('leaveGame', function(message){
            console.log(token + " left the game");
        });

        client.on('destroyGame', function(message){

        });

      });
    }

    emitSocketEvent(participants, eventKey, eventBody){

        //announce to all game room participants
        participants.forEach(participantId => {

            //retrieve socket
            const socket = this.socketClients[participantId];
            // check this is a connected socketID
            if (this.io.sockets.connected[socket.socketid]) {
                // if checks out that this is a connected socket emit the event to socketID
                
                // print to console current socket being emitted to
                //console.log("Emitting to "+socket.socketid);
                this.io.sockets.connected[socket.socketid].emit(eventKey, eventBody);
            };
            
            // print to console current socket being emitted to
            //console.log (socket_value.socketid);

        });
    }
};


