//
//  CGFloat+Ext.swift
//  Ninja2
//
//  Created by Serena Savarese on 11/12/23.
//

//MARK: Extention CGFloat

import CoreGraphics

public let π = CGFloat.pi

extension CGFloat{
    
    func radiantsToDegrees() -> CGFloat {
        return self * 180.0 / π
    }
    
    func degreesToRadiants() -> CGFloat {
        return self * π / 180.0
    }
    
     //Create methods to get random values
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF)) //return 0, 1
    }
    
    //Return min or max value
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min<max)
        return CGFloat.random() * (max-min) + min //return min or max
    }
}
