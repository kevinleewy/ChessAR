const GameRoomController = require('./controllers/GameRoomController');
const GameRoomService = require('./services/GameRoomService');
const SocketService = require('./services/SocketService');
const routes = require('./config/routes');
const errorCode = require('./models/errorCode');
const constants = require('./config/constants');

const { default: services, ServiceLifetime } = require('servicemanager');
 

const express = require('express');
const app = express();

//const connection = require('./config/connection');
//const bodyParser = require ('body-parser');

//Initialize Database
//connection.init();

//Create game room service
const gameRoomService = new GameRoomService();
services.set(GameRoomService.name, new GameRoomService(), ServiceLifetime.Singleton);

//Initialize SocketIO
const socketService = new SocketService(constants.SOCKET_PORT);
socketService.createSocket();


//Bind services
services.set(SocketService.name, socketService, ServiceLifetime.Singleton);

//Bind routes
routes.init(app);

//Listen on port
app.listen (constants.API_PORT); // API, port 3000

