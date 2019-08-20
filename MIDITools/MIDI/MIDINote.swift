//
//  MIDINote.swift
//  MIDITools
//
//  Created by Julian Porter on 18/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

extension NSTextCheckingResult {
    public func range(_ index: Int, in s: String) -> String? {
        guard index < numberOfRanges,
            let r = Range<String.Index>(range(at: index), in: s)
            else { return nil }
        return String(s[r])
    }
}


public struct MIDINote : CustomStringConvertible, Equatable, Comparable {
    
    private static let names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
    private static let regex=try! NSRegularExpression(pattern: "([a-zA-Z]{1}[#]?)([-]?[0-9]+)", options: [])
    
    private static let A4Code : Int = 69
    private static let A4Freq : Float = 440.0
    private static let minorSecond : Float = powf(2.0, 1.0/12.0)
    
    public let duodecimal : UInt
    public let octave : Int
    public let code : UInt8
    
    
    public init(_ code : UInt8) {
        self.code=code
        self.duodecimal=numericCast(code) % 12
        self.octave=(numericCast(code)/12)-1
    }
    public init(octave: Int,duodecimal: UInt) {
        self.duodecimal=duodecimal
        self.octave=Swift.max(octave,-1)
        self.code=numericCast(12*(self.octave+1)+numericCast(self.duodecimal))
    }
    public init?(_ name : String) {
        guard let match=MIDINote.regex.firstMatch(in: name, options: [],range: name.range),
            match.numberOfRanges >= 3,
            let note = match.range(1, in: name),
            let octString = match.range(2,in: name),
            let oct = Int(octString),
            let duo = MIDINote.names.firstIndex(of: note.uppercased())
            else { return nil }
        self.init(octave: oct,duodecimal: numericCast(duo))
    }
    
    public var frequency : Float {
        let offset : Int = numericCast(code)-MIDINote.A4Code
        return MIDINote.A4Freq*powf(MIDINote.minorSecond, Float(offset))
    }
    public var note : String { return MIDINote.names[numericCast(self.duodecimal)] }
    public var name : String { return "\(note)\(octave)" }
    public var description: String { return "\(name) = \(code) = [\(octave),\(duodecimal)] = \(frequency)Hz" }
    
    public static func ==(_ l : MIDINote,_ r : MIDINote) -> Bool { return l.code==r.code }
    public static func !=(_ l : MIDINote,_ r : MIDINote) -> Bool { return l.code != r.code }
    public static func <(_ l : MIDINote,_ r : MIDINote) -> Bool { return l.code < r.code }
}

