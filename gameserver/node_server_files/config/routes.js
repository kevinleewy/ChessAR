const GameRoomController = require('../controllers/GameRoomController');


function init(app) {

  const _GameRoomController = new GameRoomController();

  //HTTP GET: Check whether already part of game room
  app.get ('/room/:id', _GameRoomController.getGameRoom.bind(_GameRoomController));

  //HTTP POST: Create/Join game room
  app.post('/room/:id', _GameRoomController.enterGameRoom.bind(_GameRoomController));

  //HTTP DELETE: Leave game room
  app.delete('/room/:id', _GameRoomController.leaveGameRoom.bind(_GameRoomController));
}

module.exports.init = init;