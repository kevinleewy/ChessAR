//
//  Board.swift
//  MyProject
//
//  Created by Kevin Lee on 8/3/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class Board: SCNNode {
    
    
    // MARK: - Properties
    /// The BoardAnchor in the scene
    var anchor: BoardAnchor?
    var board: SCNNode
    
    private var pieces: [[Piece?]]
    private var moveIndicators: [MoveIndicator]
    
    //Class Constants
    private static let BOARD_WIDTH: CGFloat = 0.3
    private static let fenToPieceType = [
        "K": PieceType.king,
        "Q": PieceType.queen,
        "B": PieceType.bishop,
        "N": PieceType.knight,
        "R": PieceType.rook,
        "P": PieceType.pawn,
    ]
    
    // MARK: - Initialization
    
    /**
     * @param {String} config - FEN representation of board (https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation)
     */
    init(config: String, color: PieceColor) {

        self.pieces = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.moveIndicators = [MoveIndicator]()
        
        self.board = SCNNode()
        self.board.geometry = SCNPlane(width: Board.BOARD_WIDTH, height: Board.BOARD_WIDTH)
        self.board.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "board")
        self.board.position = SCNVector3(0.0, 0.0, 0.0)
        
        if(color == .white){
            self.board.eulerAngles = SCNVector3(-90.degreesToRadians, 0, 0)
        } else {
            self.board.eulerAngles = SCNVector3(-90.degreesToRadians, 180.degreesToRadians, 0)
        }
        
        super.init()
        
        let tokens = config.components(separatedBy: " ")
        let position = tokens[0];
        var x: Int = 0
        var y: Int = 7
        for piece in position {
            if(piece == "/") {
                y -= 1
                x = 0
            } else if (piece >= "1" && piece <= "8") {
                x += Int(piece.description)!
            } else {
                let type = Board.fenToPieceType[piece.description.uppercased()]
                let color = piece < "a" ? PieceColor.white : PieceColor.black
                addPiece(type: type!, color: color, x: x, y: y)
                x += 1
            }
        }
        
        self.addChildNode(board)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    public func getPieces() -> [[Piece?]] {
        return self.pieces
    }
    
    public func getPieceAt(x: Int, y: Int) -> Piece? {
        return self.pieces[7-y][x]
    }
    
    private func addPiece(type: PieceType, color: PieceColor, x: Int, y: Int) {
        guard 0 <= x && x < 8 && 0 <= y && y < 8 else {
            return
        }

        let piece = Piece(type: type, color: color, x: x, y: y)
        self.board.addChildNode(piece)
        self.pieces[7-y][x] = piece
    }
    
    public func removePiece(piece: Piece) {
        guard let targetPiece = self.pieces[piece.getX()][piece.getY()] as Piece?, targetPiece == piece else { return }
        self.pieces[piece.getX()][piece.getY()] = nil
        piece.removeFromParentNode()
    }
    
    public func placeMoveIndicatorsOf(piece: Piece, moves: [[String: String]]) {
        let movesOfPiece = self.getMovesOf(piece: piece, moves: moves)

        //Place indicators
        for move in movesOfPiece {
            let indicator = MoveIndicator(
                piece: piece,
                x: move["x"] as! Int,
                y: move["y"] as! Int,
                flags: move["flags"] as! String,
                san: move["san"] as! String
            )
            
            self.moveIndicators.append(indicator)
            self.board.addChildNode(indicator)
            indicator.appearOnBoard(animated: true)
        }
    }
    
    public func clearMoveIndicators() {
        for moveIndicator in self.moveIndicators {
            moveIndicator.disappearFromBoard(animated: true)
        }
        self.moveIndicators = [MoveIndicator]()
    }
    
    private func getMovesOf(piece: Piece,  moves: [[String: String]]) -> [[String : Any]] {
        var result = [[String : Any]]()
        for move in moves {
            let from = move["from"]!.ascii
            let fromX = Int(from[0] - "a".ascii[0])
            let fromY = Int(from[1] - "1".ascii[0])
            if piece.getType() == Board.fenToPieceType[move["piece"]!.uppercased()]
                && piece.isAt(x: fromX, y: fromY) {
                
                let to = move["to"]!.ascii
                
                result.append([
                    "x" : Int(to[0] - "a".ascii[0]),
                    "y" : Int(to[1] - "1".ascii[0]),
                    "flags" : move["flags"]!,
                    "san" : move["san"]!
                ])
            }
        }
        return result
    }
    
    /*
        move:  {
            color: 'w',
            from: 'f2',
            to: 'f4',
            flags: 'b',
            piece: 'p',
            san: 'f4'
        }
     */
    public func performMove(move: [String: String]) {
        let from = move["from"]!.ascii
        let fromX = Int(from[0] - "a".ascii[0])
        let fromY = Int(from[1] - "1".ascii[0])
        let to = move["to"]!.ascii
        let toX = Int(to[0] - "a".ascii[0])
        let toY = Int(to[1] - "1".ascii[0])
        let piece = self.pieces[7-fromY][fromX]
        piece?.forceMoveTo(x: toX, y: toY, animated: true)
        
        for flag in move["flags"]! {
            let moveType: MoveType = MoveType.init(rawValue: String(flag))!
            switch moveType {
            case .STANDARD_CAPTURE:
                self.pieces[7-toY][toX]?.captured()
            case .EN_PASSANT:
                self.pieces[7-fromY][toX]?.captured()
            case .PROMOTION:
                piece?.promote(to:
                    PieceType.init(rawValue: move["promotion"]!)!
                )
            default:
                break
            }
        }
        
        
        //Finally, update position of moved piece in array
        self.pieces[7-fromY][fromX] = nil
        self.pieces[7-toY][toX] = piece
    }
    
    public static func boardCoordinateToVector(x: Int, y: Int) -> SCNVector3 {
        let tileWidth: Float = Float(Board.BOARD_WIDTH) / 8
        return SCNVector3(
            x: tileWidth * (Float(x) - 3.5),
            y: tileWidth * (Float(y) - 3.5),
            z: 0.0
        )
    }
    
}

