//
//  Character.swift
//  MyProject
//
//  Created by Kevin Lee on 6/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

enum CharacterState :Int {
    case idle,
    walking,
    running
}

class Character: SCNNode {
    
    private var id: Int
    private var health: Int
    private var mana: Int
    private var movementSpeed: Float
    private var turnSpeed: Float
    
    var creatureScene: SCNScene //creature scene
    var model: SCNNode //model node
    
    var state : CharacterState = .idle {
        didSet {
            guard oldValue != state else { return }
            switch(state){
            case .idle      : self.idle()
            case .walking   : self.walk()
            case .running   : self.run()
            }
        }
    }
    
    var idlePlayer: SCNAnimationPlayer?
    var walkPlayer: SCNAnimationPlayer?
    var runPlayer: SCNAnimationPlayer?
    
    override init() {
        
        //Load data from JSON
        let jsonResult = JSONData(filename: "json/dragon").getData()
        let daeFilename = jsonResult?["scene"] as! String
        
        self.id = 0
        self.health = 100
        self.mana = 100
        self.movementSpeed = 1.0
        self.turnSpeed = 1.0
        
        self.creatureScene = SCNScene(named: daeFilename)!
        self.model = SCNNode()
        
        self.idlePlayer = self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationPlayer(forKey: "animation1")
        
        let walkDae = jsonResult?["walk"] as! String
        let walkScene = SCNScene(named: walkDae)!
        self.walkPlayer = walkScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationPlayer(forKey: "animation1")
        self.walkPlayer?.stop()
        self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.addAnimationPlayer(self.walkPlayer!, forKey: "walk")
        
        let runDae = jsonResult?["run"] as! String
        let runScene = SCNScene(named: runDae)!
        self.runPlayer = runScene.rootNode.childNode(withName: "Armature", recursively: false)?.animationPlayer(forKey: "animation1")
        self.runPlayer?.stop()
        self.creatureScene.rootNode.childNode(withName: "Armature", recursively: false)?.addAnimationPlayer(self.runPlayer!, forKey: "run")
        
        for childNode in self.creatureScene.rootNode.childNodes {
            self.model.addChildNode(childNode as SCNNode)
        }
        
        self.model.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        self.model.opacity = 1.0
        
        
        super.init()
        self.addChildNode(self.model)
        self.name = "Dragon of Legends"
        self.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func getId() -> Int {
        return self.id
    }
    
    public func getHealth() -> Int {
        return self.health
    }
    
    public func getMana() -> Int {
        return self.mana
    }
    
    public func getMovementSpeed() -> Float {
        return self.movementSpeed
    }
    
    public func walk() {
        self.idlePlayer?.stop()
        self.runPlayer?.stop()
        self.walkPlayer?.play()
    }
    
    public func idle() {
        self.walkPlayer?.stop()
        self.runPlayer?.stop()
        self.idlePlayer?.play()
    }
    
    public func run() {
        self.walkPlayer?.stop()
        self.idlePlayer?.stop()
        self.runPlayer?.play()
    }
    /*
    public func translate(to destination : SCNVector3){
        let time = TimeInterval(destination.distance(from: self.position) / self.movementSpeed)
        let finalOrientation = atan2(destination.x, destination.z)
        let turnAngle = self.eulerAngles.y - finalOrientation
        let turnTime = TimeInterval(abs(turnAngle) / self.turnSpeed)
        self.runAction(SCNAction.sequence([
            SCNAction.rotate(by: CGFloat(turnAngle), around: SCNVector3(0, 1, 0), duration: turnTime),
            SCNAction.move(to: destination, duration: time)
        ])
    }
    
    public func translate(by distance : Float){
        let time = TimeInterval(distance / self.movementSpeed)
        
        self.runAction(SCNAction.sequence([
            SCNAction.rotate(by: <#T##CGFloat#>, around: <#T##SCNVector3#>, duration: <#T##TimeInterval#>),
            self.runAction(SCNAction.move(by: <#T##SCNVector3#>, duration: time))
        ])
    }
*/
}
