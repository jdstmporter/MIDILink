//
//  Previewer.swift
//  MIDIUtils
//
//  Created by Julian Porter on 06/07/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import MIDITools

class DecoderPreview  {
    
    
    
    @IBOutlet weak var table : NSTableView!
    private var delegate: MIDIDecodeTable!
    private var decoder : MIDIDecoder
    private var hash: Int
    private var colours : [String: NSColor]
    
    init(decoder d: MIDIDecoder? = nil) throws{
        decoder = try d ?? MIDIDecoder()
        let u=UUID.init()
        hash=u.hashValue
        colours=[:]
    }
    
    public func awake() {
        delegate=MIDIDecodeTable(table: table, withColour: false)
        delegate.link(decoder: decoder)
        delegate.Touch()
    }
    
    
    
    var hashValue: Int { return hash }
    
    
}


