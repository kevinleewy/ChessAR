//
//  JoystickOverlayScene.swift
//  MyProject
//
//  Created by Kevin Lee on 6/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit
import SpriteKit

class JoystickOverlayScene: SKScene {
    var character: Character?
    
    let moveAnalogStick = 🕹(diameter: 110) // from Emoji
    //let moveAnalogStick = AnalogJoystick(diameter: 100) // from Class
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = UIColor.clear
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        moveAnalogStick.position = CGPoint(x: moveAnalogStick.radius + 15, y: moveAnalogStick.radius + 15)
        moveAnalogStick.stick.image = UIImage(named: "jStick")
        moveAnalogStick.substrate.image = UIImage(named: "jSubstrate")
        addChild(moveAnalogStick)
        
        //MARK: Handlers
        moveAnalogStick.beginHandler = { [unowned self] in
            
            guard let character = self.character else {
                return
            }

        }
        
        moveAnalogStick.trackingHandler = { [unowned self] data in
            
            guard let character = self.character else {
                return
            }

            //character.translate(to: <#T##SCNVector3#>)
            
            if data.velocity.length > 20.0 {
                character.state = .running
            } else if data.velocity.length > 0.0 {
                character.state = .walking
            } else {
                character.state = .idle
            }
            
            let destination = SCNVector3(character.position.x + (Float(data.velocity.x) * 0.0005), character.position.y, character.position.z - (Float(data.velocity.y) * 0.0005))
            character.runAction(SCNAction.sequence([
                SCNAction.rotateTo(x: 0.0, y: data.angular, z: 0.0, duration: 0.001),
                SCNAction.move(to: destination, duration: 0.1)
            ]))
            
        }
        
        moveAnalogStick.stopHandler = { [unowned self] in
            
            guard let character = self.character else {
                return
            }
            
            character.state = .idle
        }
        
        view?.isMultipleTouchEnabled = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

