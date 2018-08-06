//
//  ViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 3/30/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit
import SocketIO

class ViewController: UIViewController, ARSCNViewDelegate {

    var spriteScene: OverlayScene!
    
    @IBOutlet weak var connectButton: UIButton!
    
    
    @IBOutlet weak var endButton: UIButton!

    
    @IBOutlet var sceneView: ARSCNView!
    
    //Environment variables
    let configuration = ARWorldTrackingConfiguration()
    let trayLauncher = TrayLauncher()
    var isWorldSetUp = false
    var gameEnded = false
    
    //Player information
    var playerId: String?
    var playerColor: PieceColor?
    var isMyTurn = false
    
    //Networking variables
    var manager: SocketManager?
    var socket: SocketIOClient!
    var host: String = ""
    
    //Game assets
    var board: Board?
    var moves: [[String: String]]?
    var selectedPiece : Piece? = nil
    var selectedCard : SCNCard? = nil
    
    var DEBUG = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //self.sceneView.showsStatistics = true
        
        // Set up spotlight attached to camera
        attachSpotLight()
        
        // Set Up Socket Events
        self.setSocketEvents()
        
    }
    
    func debugprint(_ s:String){
        if self.DEBUG {
            print("DEBUG: \(s)")
        }
    }
    
    func attachSpotLight(){
        let spotLight = SCNLight()
        spotLight.type = .spot
        spotLight.spotInnerAngle = 60
        spotLight.spotOuterAngle = 60
        let spotNode = SCNNode()
        spotNode.light = spotLight
        self.sceneView.pointOfView?.addChildNode(spotNode)
    }
    
    func setUpWorld(config: [String: Any]){
        /*
        debugprint("Setting up world")
        debugprint(config.description)
        let playersConfig = config["players"] as! [Any]
        let temp = playersConfig[0] as! [String: Any]
        
        var p1conf : [String : Any]
        var p2conf : [String : Any]
        if temp["id"] as? String == self.playerId {
            p1conf = playersConfig[0] as! [String: Any]
            p2conf = playersConfig[1] as! [String: Any]
        } else {
            p1conf = playersConfig[1] as! [String: Any]
            p2conf = playersConfig[0] as! [String: Any]
        }
        let turnPlayer = config["turnPlayer"] as! String
        
        self.isMyTurn = (turnPlayer == self.playerId)
        
        */
        
        // Load Overlay Scene
        self.spriteScene = OverlayScene(size: self.view.bounds.size)
        self.sceneView.overlaySKScene = self.spriteScene
        
        // Parse header
        let header = config["header"] as! [String: String]
        if(header["White"] == self.playerId) {
            self.spriteScene.announcement = "You are playing as White."
            self.playerColor = .white
        } else if(header["Black"] == self.playerId) {
            self.spriteScene.announcement = "You are playing as Black."
            self.playerColor = .black
        } else {
            self.spriteScene.announcement = "You are not a player."
            return
        }
        
        //Check turn
        let turn = config["turn"] as! String
        self.isMyTurn = self.playerColor?.rawValue == turn
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.sceneView.addGestureRecognizer(longPressGesture)
        
        // Load board
        self.board = Board(
            config: config["board"] as! String,
            color: self.playerColor!
        )
        board?.position = SCNVector3(0.0, -0.3, -0.3)
        scene.rootNode.addChildNode(board!)
        
        self.moves = config["moves"] as? [[String: String]]
        
        //Configure buttons
        //self.configureButtons()
        
        //Configure tray
        //let handConf = p1conf["hand"] as! [Int]
        //self.trayLauncher.handScene.loadHand(cardIds: handConf, socket: self.socket)

    }
    
    func configureButtons(){

    }
    
    func restartSession() {
        self.sceneView.overlaySKScene = nil
        //self.trayLauncher.handScene.destroyHand()
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.isWorldSetUp = false
    }
    
    @IBAction func connectAction(_ sender: Any) {
        if gameEnded {
            debugprint("Game ended. Leaving game room...")
            performSegue(withIdentifier: "BackToMainMenu", sender: nil)
        }
        if isWorldSetUp {
            debugprint("Leaving game")
            self.socket.emit("leaveGame",[])
            restartSession()
            connectButton.setTitle("Join", for: .normal)
        } else {
            debugprint("Attempting to join game")
            self.socket.emit("joinGame",[])
        }
    }
    
    
    @IBAction func toggleTray(_ sender: Any) {
        trayLauncher.toggleTray()
    }
    
    @IBAction func endAction(_ sender: Any) {
        self.socket.emit("actionSelect", ["action":"endTurn"])
    }
    

    // MARK: Tap Handlers
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: self.sceneView)
        let hitResults = self.sceneView.hitTest(p, options: [:])
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: SCNHitTestResult = hitResults[0]
            
            if let piece = result.node.getPiece(depth: 1) {
                self.pieceTappedHandler(piece)
            //} else if let board = result.node.getBoard(depth: 1) {
            //    print("Tapped board")
            } else if let move = result.node as? MoveIndicator {
                print("Executing \(move.getSan())")
                self.socket.emit("actionSelect", ["action": move.getSan(), "lang": "EN"])
            } else {
                print(result.node.debugDescription)
            }
            
            // result.node is the node that the user tapped on
            // perform any actions you want on it
            
        }
    }
    
    @objc func handleLongPress(_ gestureRecognize: UIGestureRecognizer) {
        
        if gestureRecognize.state == UIGestureRecognizerState.began {
            // check what nodes are tapped
            let p = gestureRecognize.location(in: self.sceneView)
            var hitResults = self.sceneView.hitTest(p, options: [:])
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: SCNHitTestResult = hitResults[0]
                
                // result.node is the node that the user tapped on
                // perform any actions you want on it
                if let piece = result.node.getPiece(depth: 1) {
                    self.selectedPiece = piece
                    piece.lift()
                    //self.pieceTappedHandler(piece)
                }
                
            }
        } else if gestureRecognize.state == UIGestureRecognizerState.ended {
            self.selectedPiece?.drop()
            self.selectedPiece = nil

        } else if gestureRecognize.state == UIGestureRecognizerState.changed {

            if (self.selectedPiece != nil) && self.selectedPiece!.isLifted() {
                let p = gestureRecognize.location(in: self.sceneView)
                let hitResults = self.sceneView.hitTest(p, types: ARHitTestResult.ResultType.featurePoint)
                if hitResults.count > 0 {
                    let result: ARHitTestResult = hitResults[0]
                    let targetTransform = SCNMatrix4(result.worldTransform)
                    
                        //self.selectedPiece?.moveTo(x: <#T##Float#>, y: <#T##Float#>, animated: false)
                        
                    let targetPosition = SCNVector3(targetTransform.m41, self.selectedPiece!.worldPosition.y, targetTransform.m43)

                    self.selectedPiece?.worldPosition = targetPosition
                }
            }
        }
    }
    
    func pieceTappedHandler(_ piece: Piece) {
        NSLog("Piece tapped")
        guard isMyTurn else { return }
        NSLog("It is my turn")
        self.board?.clearMoveIndicators()
        if(self.selectedPiece == piece){
            self.selectedPiece = nil
        } else {
            self.selectedPiece = piece
            self.board?.placeMoveIndicatorsOf(piece: piece, moves: self.moves!)
        }
    }

    
    // MARK: Socket Events
    
    private func setSocketEvents() {
        
        self.socket.removeAllHandlers()
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
        self.socket.on(clientEvent: .disconnect, callback: {data, ack in
            print("socket disconnected");
        });
        
        self.socket.on(clientEvent: .reconnect, callback: {data, ack in
            print("socket reconnected");
            self.debugprint("Attempting to reconnect to game")
            self.restartSession()
            self.socket.emit("joinGame",[])
        });
        
        self.socket.on(clientEvent: .error, callback: {data, ack in
            print("socket error");
        });

        self.socket.on("appError") {data, ack in
            let err = data[0] as! [Any]
            if let errorCode = err[0] as? Int,
                let errorMsg = err[1] as? String {
                displayError(message: errorMsg)
                print("Error \(errorCode.description): \(errorMsg)")
            }
        }
        
        self.socket.on("joinedGame") {data, ack in
            self.debugprint(data.description);
            self.debugprint("Joined game")
            
            if let config = data[0] as? [String : Any] {
                self.setUpWorld(config: config)
                self.isWorldSetUp = true
                self.connectButton.setTitle("Leave", for: .normal)
            }
        }
        
        self.socket.on("gameEnded") {data, ack in
            self.debugprint(data.description);
            self.debugprint("Game Ended")
            
            if let winnerId = data[0] as? String {
                self.spriteScene.announcement = "Game ended. \(winnerId) won."
                self.gameEnded = true
                self.connectButton.setTitle("Leave", for: .normal)
            }
        }
        
        self.socket.on("actionResponse") {data, ack in
            self.debugprint(data.description);
            
            if self.isWorldSetUp, let response = data[0] as? [String:Any] {
                
                //Execute result
                if let result = response["result"] as? [String: String] {
                    self.board?.clearMoveIndicators()
                    self.board?.performMove(move: result)
                
                    //Check turn
                    let turn = response["turn"] as! String
                    if self.playerColor?.rawValue == turn {
                        
                        //Load next set of moves
                        self.moves = response["moves"] as? [[String: String]]
                        self.isMyTurn = true
                        self.spriteScene.announcement = "Your turn."
                    } else {
                        
                        self.moves = nil
                        self.isMyTurn = false
                        self.spriteScene.announcement = "Turn ended."
                    }
                }
            }
        }
        
    }
 
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToMainMenu" {
            let destinationVC = segue.destination as! MenuViewController
            destinationVC.playerId = self.playerId!
            destinationVC.host = self.host
            destinationVC.loggedIn = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Set debug options
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        // Run the view's session
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        NSLog("Session interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        NSLog("Session interruption ended")
    }
}
