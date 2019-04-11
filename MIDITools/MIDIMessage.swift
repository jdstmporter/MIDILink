//
//  MIDIMessage.swift
//  MIDIManager
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public struct MIDIMessageData {
    let timestamp : MIDITimeStamp
    let bytes : [UInt8]
    
    let command : MIDICommandTypes
    let channel : UInt8
    
    let arg0 : UInt8
    let arg1 : UInt8
    let arg2 : UInt8
    let word : UInt16
    
    init(_ packet : MIDIPacket) {
        var pkt = packet.data
        let len = Int(packet.length)
        let ptr = UnsafeRawBufferPointer.init(start: &pkt, count: len)
        let arr = ptr.bindMemory(to: UInt8.self)
        let bytes = (0..<len).map { arr[$0] }
        let (arg0,arg1,arg2) = (bytes[0],bytes[1],bytes[2])
        
        self.bytes = bytes
        self.command = MIDICommandTypes(arg0)
        self.channel = 1 + (arg0&0x0f)
        self.arg0 = arg0
        self.arg1 = arg1
        self.arg2 = arg2
        self.word = (UInt16(arg2)<<8) + UInt16(arg1)
        self.timestamp = packet.timeStamp
    }
    
    public var count : Int { return bytes.count }
    
    public var name : String { return command.name }
    public var attrs : [KVPair] {
        var args : [KVPair] = [KVPair("Timestamp",timestamp),
                               KVPair("1",arg0), KVPair("2",arg1), KVPair("3",arg2),
                               KVPair("Command", command.name), KVPair("Channel",channel)]
        switch command {
        case .NoteOnEvent, .NoteOffEvent:
            args.append(contentsOf: [KVPair("Note" , arg1), KVPair("Velocity", arg2)])
        case .KeyPressure:
            args.append(contentsOf: [KVPair("Note" , arg1), KVPair("Pressure" , arg2)])
        case .ChannelPressure:
            args.append(contentsOf: [KVPair("Pressure" , arg1)])
        case .ProgramChange:
            args.append(contentsOf: [KVPair("Program" , arg1)])
        case .PitchBend:
            args.append(contentsOf: [KVPair("Bend" , word)])
        case .SystemMessage:
            args.append(contentsOf: [KVPair("Message" , channel-1), KVPair("Byte1", arg1), KVPair("Byte2", arg2)])
        case .ControlChange:
            args.append(contentsOf: [KVPair("Controller", arg1),KVPair("Value", arg2)])
            if let kv=MIDIControlMessages(arg1).kv(arg2) { args.append(kv) }
        default:
            break
        }
        return args
    }
}


public class MIDIMessage : CustomStringConvertible {
    private let fields = ["Timestamp", "Command", "Channel", "Arguments"]
    public let packet : MIDIMessageData
    
    public var Timestamp : String { return packet.timestamp.str }
    public var Command : String { return packet.command.name }
    public var Arguments : String { return packet.attrs.map { "\($0.key) = \($0.value.str)" }.joined(separator: ", ") }
    public var Channel : String { return packet.command == .SystemMessage ? "" : packet.channel.str }
    public var Raw : [UInt8] { return packet.bytes }
    public init(_ packet : MIDIPacket,timebase: MIDITimeStandard) {
        self.packet=MIDIMessageData(packet)
    }
    
    public var description: String {
        return [
            "Timestamp : \(Timestamp)",
            "Command : \(Command)",
            "Channel : \(Channel)",
            "Arguments : \(Arguments)"
            ].joined(separator: "; ")
    }
    
    public subscript(_ key : String) -> String? {
        if key == "Timestamp" { return Timestamp }
        if key == "Command" { return Command }
        if key == "Arguments" { return Arguments }
        if key == "Channel" { return Channel }
        return nil
    }
    public var dispatch : DispatchTime { return DispatchTime(uptimeNanoseconds: packet.timestamp) }
    
    
    
}

