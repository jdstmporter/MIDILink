//
//  MIDIControl.swift
//  MIDITools
//
//  Created by Julian Porter on 01/09/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public struct MIDIControlMessage : Serialisable {
    
    public let command : MIDIControlMessages
    public let value : UInt8?
    
    public init(_ b0 : UInt8, _ b1 : UInt8? = nil) throws {
        guard let command = MIDIControlMessages(rawValue: b0), !(command.needsValue && b1==nil)
            else { throw MIDIMessageError.BadPacket}
        
        self.command=command
        self.value=b1
    }
    public init(_ bytes: OffsetArray<UInt8>) throws {
        guard bytes.count>0 else { throw MIDIMessageError.NoContent }
        let b0=bytes[0]
        let b1=bytes.count>1 ? bytes[1] : nil
        try self.init(b0,b1)
    }
    public init(_ command : MIDIControlMessages, _ value : String?) throws {
        guard let transformer = command.transform.transformer else { throw MIDIMessageError.BadPacket }
        try self.init(command.raw,transformer[value])
    }
    
    
    public var interpretedValue : Serialisable? {
        guard let value = self.value else { return nil }
        guard let transformer = self.command.transformer else { return value.str }
        return transformer[value]
    }
    
    public var str : String {
        if let interpreted = interpretedValue { return "\(self.command) = \(interpreted)" }
        else { return "\(self.command)" }
    }
    
}
