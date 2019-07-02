//
//  MIDIError.swift
//  MIDI Utils
//
//  Created by Julian Porter on 14/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

public class MIDIError : Error, CustomStringConvertible {
    
    public enum Reason {
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
    
    public let reason : MIDIError.Reason
    public let status : OSStatus
    
    public init(reason: MIDIError.Reason,status: OSStatus = 0) {
        self.reason=reason
        self.status=status
    }
    
    public init(status: OSStatus = 0) {
        self.reason = .Other
        self.status=status
    }
    
    public var description : String {
        return "\(reason) with status code \(status)"
    }
}