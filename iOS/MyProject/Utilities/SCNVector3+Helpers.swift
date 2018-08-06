//
//  SCNVector3+Helpers.swift
//  MyProject
//
//  Created by Kevin Lee on 6/13/18.
//  Copyright © 2018 Kevin Lee. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: Float {
        return sqrt(x * x + y * y + z * z)
    }
    
    public func distance(from vect : SCNVector3) -> Float {
        return sqrt( pow(self.x - vect.x, 2) + pow(self.y - vect.y, 2) + pow(self.z - vect.z, 2))
    }
}
