//
//  Coding.swift
//  MIDIUtils
//
//  Created by Julian Porter on 27/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

class Coding {
    enum CodingError : Error { case All }
    
    static func split(_ string: String?,separator s: Character = ":" ) throws -> [String] {
        if string==nil { throw CodingError.All }
        return string!.split(separator:s).map { String($0) }
    }
    
    static func split(_ string: String?,to n : Int,separator s: Character = ":") throws -> [String] {
        let parts=try Coding.split(string,separator: s)
        if parts.count != n { throw CodingError.All }
        return parts
    }
    
    static func splitCG(_ string: String) throws -> [CGFloat] {
        let parts=string.split(separator: ",").map { Double(String($0)) }
        if (parts.filter { $0==nil }).count > 0 { throw CodingError.All }
        return parts.map { CGFloat($0!) }
    }
    
    static func int(_ string : String) throws -> Int {
        let i=Int(string)
        if i==nil { throw CodingError.All }
        return i!
    }
    
    static func cgfloat(_ string : String) throws -> CGFloat {
        let i=Double(string)
        if i==nil { throw CodingError.All }
        return CGFloat(i!)
    }
}


