//
//  threeWaySplit.swift
//  MIDIUtils
//
//  Created by Julian Porter on 16/07/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

struct ThreeWaySplit<T> where T : Hashable {
    public typealias Element = T
    
    public let toAdd : Set<T>
    public let toChange : Set<T>
    public let toRemove : Set<T>
    
    public init(new : Set<T>, old : Set<T>) {
        toChange = new.intersection(old)
        toAdd = new.subtracting(old)
        toRemove = old.subtracting(new)
    }
    
    public init(new : [T], old : [T]) {
        self.init(new: Set(new), old: Set(old))
    }
}




