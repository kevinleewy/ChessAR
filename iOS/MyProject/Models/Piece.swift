//
//  Piece.swift
//  MyProject
//
//  Created by Kevin Lee on 8/3/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

enum PieceType : String {
    case pawn = "pawn",
    rook = "rook",
    knight = "knight",
    bishop = "bishop",
    queen = "queen",
    king = "king"
}

enum PieceColor : String {
    case white = "w",
    black = "b"
}

class Piece: SCNNode {
    
    private var type: PieceType
    private var color: PieceColor
    private var x: Int  //board coordinates
    private var y: Int  //board coordinates
    private var lifted: Bool
    private var model: SCNNode?
    
    //Class Constants
    private static let SCALE_FACTOR: Float = 0.01
    private static let LIFTED_HEIGHT: CGFloat = 0.02
    
    init(type: PieceType, color: PieceColor, x: Int, y: Int) {

        self.type = type
        self.color = color
        self.x = x
        self.y = y
        self.lifted = false
        
        super.init()
        
        self.position = Board.boardCoordinateToVector(x: x, y: y)
        
        self.loadModel(type: type, color: color)
        
    }
    
    required init(coder x: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    public func getType() -> PieceType {
        return self.type
    }
    
    public func getColor() -> PieceColor {
        return self.color
    }
    
    public func getX() -> Int {
        return self.x
    }
    
    public func getY() -> Int {
        return self.y
    }
    
    public func isAt(x: Int, y: Int) -> Bool {
        return self.x == x && self.y == y
    }
    
    public func isLifted() -> Bool {
        return self.lifted
    }
    
    public func lift() {
        self.lifted = true
        self.runAction(
            SCNAction.moveBy(x: 0.0, y: 0.0, z: Piece.LIFTED_HEIGHT, duration: 0.5)
        )
    }
    
    public func drop() {
        self.lifted = false
        self.runAction(
            SCNAction.moveBy(x: 0.0, y: 0.0, z: -Piece.LIFTED_HEIGHT, duration: 0.5)
        )
    }
    
    public func moveTo(x: Int, y: Int, animated: Bool) {
        self.x = x
        self.y = y
        
        if lifted {
            var targetPosition = Board.boardCoordinateToVector(x: x, y: y)
            targetPosition.z = Float(Piece.LIFTED_HEIGHT)
            if animated {
                self.runAction(
                    SCNAction.move(
                        to: targetPosition,
                        duration: 2.0
                    )
                )
            } else {
                self.position = targetPosition
            }
        }
    }
    
    public func forceMoveTo(x: Int, y: Int, animated: Bool) {
        self.x = x
        self.y = y
        var targetPosition = Board.boardCoordinateToVector(x: x, y: y)
        if animated {
            targetPosition.z = Float(Piece.LIFTED_HEIGHT)
            self.runAction(SCNAction.sequence([
                SCNAction.moveBy(x: 0.0, y: 0.0, z: Piece.LIFTED_HEIGHT, duration: 0.5),
                SCNAction.move(
                    to: targetPosition,
                    duration: 2.0
                ),
                SCNAction.moveBy(x: 0.0, y: 0.0, z: -Piece.LIFTED_HEIGHT, duration: 0.5)
            ]))
        } else {
            self.position = targetPosition
        }
    }
    
    public func captured() {
        self.runAction(
            SCNAction.sequence([
                SCNAction.fadeOut(duration: 1.0),
                SCNAction.run({node in
                    let thisNode = node as! Piece
                    let board = thisNode.parent?.parent as! Board
                    board.removePiece(piece: thisNode)
                })
            ])
        )
    }
    
    /**
     * Updates the piece's type and reloads the model
     */
    public func promote(to type: PieceType) {
        self.type = type
        self.model?.removeFromParentNode()
        self.loadModel(type: type, color: self.color)
    }
    
    private func loadModel(type: PieceType, color: PieceColor) {
        
        //Extract node from scene
        let pieceScene = SCNScene(named: "art.scnassets/pieces.dae")!
        let pieceNode: SCNNode = pieceScene.rootNode.childNode(withName: type.rawValue, recursively: true)!
        
        //Configure model
        pieceNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        pieceNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        pieceNode.scale = SCNVector3(x: Piece.SCALE_FACTOR, y: Piece.SCALE_FACTOR, z: Piece.SCALE_FACTOR)
        pieceNode.geometry?.material(named: "chess_piece")?.multiply.contents = (color == PieceColor.white) ? UIColor.white : UIColor.darkGray
        
        //Add to parent node
        self.model = pieceNode
        self.addChildNode(pieceNode)
    }
}
