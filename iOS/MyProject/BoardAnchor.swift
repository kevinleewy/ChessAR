//
//  WorldAnchor.swift
//  MyProject
//
//  Created by Kevin Lee on 6/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import ARKit

class BoardAnchor: ARAnchor {
    
    private var size: CGSize
    
    init(transform: float4x4, size: CGSize) {
        self.size = size
        super.init(transform: transform)
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.size = aDecoder.decodeCGSize(forKey: "size")
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(size, forKey: "size")
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        // required by objc method override
        let copy = super.copy(with: zone) as! BoardAnchor
        copy.size = size
        return copy
    }
}
