//
//  MIDIError.swift
//  MIDI Utils
//
//  Created by Julian Porter on 14/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation


public class BaseError<R> : Error, CustomStringConvertible {
    public typealias Reason=R
    public let reason : Reason?
    public let status : OSStatus
    public private(set) var description : String
    
    required public init(reason: Reason,status: OSStatus = 0) {
        self.reason=reason
        self.status=status
        self.description="\(reason) with status code \(status)"
        
    }
    
    required public init(_ message : String) {
        self.reason = nil
        self.status = 0
        self.description = message
    }
    
    public init(status: OSStatus = 0) {
        self.reason=nil
        self.status=status
        self.description="Error with status code \(status)"
    }
    
    typealias Block = () -> OSStatus
    static func Try(reason: Reason, block: Block) throws {
        let error=block()
        if error != noErr { throw Self(reason: reason, status: error) }
    }
    static func Try(_ message: String, block: Block) throws {
        if block() != noErr { throw Self(message) }
    }
}

public enum MIDIErrorReason {
    case CannotReadProperty
    case CannotLoadEndPoint
    case CannotLoadEntity
    case CannotLoadDevice
    case CannotLoadObject
    case CannotCreateApplication
    case CannotCreateOutputPort
    case CannotCreateInputPort
    case CannotLinkInputPort
    case CannotLinkOutputPort
    case CannotUnlinkInputPort
    case CannotUnlinkOutputPort
    case CannotSendPackets
    case Other
}
public enum MIDIMessageReason {
    case NoContent
    case BadPacket
    case CannotParseSystemMessage
    case UnknownMessage
    case NoCommand
    case NoNote
    case NoValue
    case BadBend
}
public enum MIDIPacketReason {
    case UnknownCommandType
    case MissingParameters
    case CannotDoSysExYet
    case BadMessageDescription
}

public typealias MIDIError = BaseError<MIDIErrorReason>
public typealias MIDIMessageError = BaseError<MIDIMessageReason>
public typealias MIDIPacketError = BaseError<MIDIPacketReason>
