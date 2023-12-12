//
//  Types.swift
//  Ninja2
//
//  Created by Serena Savarese on 11/12/23.
//

import Foundation

struct PhysicsCategory {
    
    /*
        Ogni categoria è rappresentata da un numero binario
        These values correspond to 2^0, 2^1, 2^2, 2^3, 2^4
     */
    static let Player: UInt32 = 0b1     //1
    static let Block: UInt32 = 0b1      //2
    static let Obstacle: UInt32 = 0b100 //4
    static let Ground: UInt32 = 0b100   //8
    static let Coin: UInt32 = 0b10000   //16
    
}
