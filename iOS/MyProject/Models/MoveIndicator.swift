//
//  MoveIndicator.swift
//  MyProject
//
//  Created by Kevin Lee on 8/5/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

enum MoveType : String {
    case NON_CAPTURE = "n",
    STANDARD_CAPTURE = "c",
    PROMOTION = "p",
    EN_PASSANT = "e",
    PAWN_LEAP = "b",
    KINGSIDE_CASTLING = "k",
    QUEENSIDE_CASTLING = "q"
}

class MoveIndicator: SCNNode {
    
    private var piece: Piece
    private var x: Int  //board coordinates
    private var y: Int  //board coordinates
    private var moveTypes: [MoveType]
    private var san: String //Standard notation for move
    
    //Class Constants
    private static let SCALE: CGFloat = 0.01
    private static let FALL_DIST: CGFloat = 0.02
    private static let COLOR: UIColor = UIColor.green
    
    init(piece: Piece, x: Int, y: Int, flags: String, san: String) {
        self.piece = piece
        self.x = x
        self.y = y
        self.moveTypes = [MoveType]()
        self.san = san
        
        //Add move types based on flags
        for flag in flags {
            self.moveTypes.append(MoveType.init(rawValue: String(flag))!)
        }
        
        super.init()
        
        //let temp = Board.boardCoordinateToVector(x: x, y: y)
        //self.position.x = temp.x
        //self.position.y = Float(MoveIndicator.FALL_DIST)
        //self.position.z = -temp.y
        self.position = Board.boardCoordinateToVector(x: x, y: y)
        self.position.z = Float(MoveIndicator.FALL_DIST)
        
        //Creates a sphere
        self.geometry = SCNSphere(radius: MoveIndicator.SCALE)
        /*SCNBox(
            width: MoveIndicator.SCALE,
            height: MoveIndicator.SCALE,
            length: MoveIndicator.SCALE,
            chamferRadius: MoveIndicator.SCALE
        )*/
        
        //Set color
        self.geometry?.firstMaterial?.diffuse.contents = MoveIndicator.COLOR
        
        //Set to invisible. Must call appearOnBoard() to become visible
        self.opacity = 0.0
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func getPiece() -> Piece {
        return self.piece
    }
    
    public func getX() -> Int {
        return self.x
    }
    
    public func getY() -> Int {
        return self.y
    }
    
    public func getMoveTypes() -> [MoveType] {
        return self.moveTypes
    }
    
    public func getSan() -> String {
        return self.san
    }
    
    public func appearOnBoard(animated: Bool) {
        if animated {
            self.runAction(SCNAction.group([
                SCNAction.moveBy(x: 0.0, y: 0.0, z: -MoveIndicator.FALL_DIST, duration: 0.5),
                SCNAction.fadeIn(duration: 0.5)
            ]))
        } else {
            self.opacity = 1.0
            self.position.z = 0.0
        }
    }
    
    public func disappearFromBoard(animated: Bool) {
        if animated {
            self.runAction(SCNAction.sequence([
                SCNAction.group([
                    SCNAction.moveBy(x: 0.0, y: 0.0, z: -MoveIndicator.FALL_DIST, duration: 0.5),
                    SCNAction.fadeOut(duration: 0.5)
                    ]),
                SCNAction.run({node in
                    let thisNode = node as! MoveIndicator
                    thisNode.removeFromParentNode()
                })
            ]))
        } else {
            self.removeFromParentNode()
        }
    }
}

