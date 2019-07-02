//
//  Kleene.swift
//  MIDIUtils
//
//  Created by Julian Porter on 03/05/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa



struct Kleene : Equatable {
    private enum Value {
        case True
        case False
        case Mid
    }
    private static func bToK(_ b : Bool?) -> Value {
        return b==true ? .True : b==false ? .False : .Mid
    }
    private static func sToK(_ s: NSControl.StateValue) -> Value {
        return s == .on ? .True : s == .off ? .False : .Mid
    }
    
    private var value : Value
    
    private init(_ v : Value) { value=v }
    public init(bool: Bool) { value=Kleene.bToK(bool) }
    public init(state : NSControl.StateValue) { value = Kleene.sToK(state) }
    
    public var isBoolean : Bool { return value != .Mid }
    public var isMid : Bool { return value == .Mid }
    
    public var bool : Bool? {
        get { return value == .True ? true : value == .False ? false : nil }
        set { value = Kleene.bToK(newValue) }
    }
    public var state : NSControl.StateValue {
        get { return (value == .Mid) ? .mixed : (value == .True) ? .on : .off }
    }
    
    public static let True = Kleene(.True)
    public static let Mid = Kleene(.Mid)
    public static let False = Kleene(.False)
    
    public static func == (_ left : Kleene,_ right : Kleene) -> Bool {
        return left.value==right.value
    }
    public static func != (_ left : Kleene,_ right : Kleene) -> Bool {
        return left.value != right.value
    }
    public static func == (_ left : Kleene,_ right : Bool) -> Bool {
        return left == Kleene(bool: right)
    }
    
    public static func || (_ left : Kleene,_ right : Kleene) -> Kleene {
        return (left == .True || right == .True) ? .True : ((left == .False && right == .False) ? .False : .Mid)
    }
    
    public static func && (_ left : Kleene,_ right : Kleene) -> Kleene {
        return (left == .False || right == .False) ? .False : ((left == .True && right == .True) ? .True : .Mid)
    }
    
    public static prefix func ! (_ value: Kleene) -> Kleene {
        return (value == .True) ? .False : ((value == .False) ? .True : .Mid)
    }
}

