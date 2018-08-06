//
//  GameViewController.swift
//  MyProject
//
//  Created by Kevin Lee on 6/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

private let log = Log()

class GameViewController: UIViewController, ARSCNViewDelegate {
    
    var spriteScene: JoystickOverlayScene!
    
    @IBOutlet weak var sceneView: ARSCNView!

    var isWorldSetUp = false
    
    var playerId: String?

    var board = Board(config: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", color: .white)
    
    var DEBUG = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //self.sceneView.showsStatistics = true
        
        // Set up spotlight attached to camera
        self.attachSpotLight()
        
        self.setUpWorld()
        
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
    
    func setUpWorld(){
        
        log.info("Setting up world")
        
        self.isWorldSetUp = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
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
    
    
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        log.info("Rendering")
        return self.board
     }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        log.info("Session interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        log.info("Session interruption ended")
    }
}
