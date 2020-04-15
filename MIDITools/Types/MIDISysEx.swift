//
//  MIDISysEx.swift
//  MIDIUtils
//
//  Created by Julian Porter on 11/04/2020.
//  Copyright © 2020 JP Embedded Solutions. All rights reserved.
//

import Foundation

public struct MIDISystemMessage : Sequence {
    public typealias Iterator = MIDIDict.Iterator
    
    public let command : MIDISystemTypes
    public let body : MIDIDict
    
    public init(_ bytes : OffsetArray<UInt8>) throws {
        guard bytes.count > 0 else { throw MIDIMessageError.NoContent }
        
        let command=MIDISystemTypes(bytes[0])
        let out = MIDIDict()
        out[.SystemCommand] = command
        switch command {
        case .SysEx:
            let cmds = try MIDISysExTypes.parse(bytes.shift(1))
            out.append(cmds)
        case .TimeCode:
            let cmds = try MIDITimeCodeTypes.parse(bytes.shift(1))
            out.append(cmds)
        case .Tune, .EndSysEx, .TimingClock, .Start, .Continue, .Stop, .ActiveSensing, .SystemReset :
            break
        case .SongSelect :
            guard bytes.count >= 1 else { throw MIDIMessageError.NoContent }
            out[.Song]=bytes[1]
        case .SongPosition :
            guard bytes.count >= 2 else { throw MIDIMessageError.NoContent }
            out[.SongPositionLO]=bytes[1]
            out[.SongPositionHI]=bytes[2]
        default:
            break
        }
        self.body = out
        self.command = command
    }
    public var count : Int { self.body.count }
    public func makeIterator() -> Iterator { self.body.makeIterator() }
    
    
 
}

