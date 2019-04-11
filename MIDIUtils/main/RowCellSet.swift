//
//  RowFieldSet.swift
//  MIDIUtils
//
//  Created by Julian Porter on 01/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreMIDI
import MIDITools

internal class RowCellSet {
    
    private var cells : [String:NSView]
    private let uid : MIDIUniqueID
    private var switchCell : NSButton!
    private let mode : MIDIEndpoint.Mode
    private let cb : (_:MIDIUniqueID,_:Bool) -> ()
    
    init(endpoint: MIDIEndpoint,handler:@escaping (_:MIDIUniqueID,_:Bool) -> ()) {
        uid=endpoint.uid
        mode=endpoint.mode
        cb=handler
        cells=[String:NSView]()
        
        cells["Name"]=VTextField(labelWithString: endpoint.name ?? "name")
        cells["Model"]=VTextField(labelWithString: endpoint.model ?? "model")
        cells["Manufacturer"]=VTextField(labelWithString: endpoint.manufacturer ?? "manufacturer")
        
        let uidCell=VTextField(labelWithString: endpoint.uid.description)
        uidCell.font=FontDescriptor(family: .Monospace, size: .Small, weight: .black).font
        cells["UID"]=uidCell
        
        let activeCell=MIDIIndicatorView() //NSTextField(labelWithString: "")
        //activeCell.alignment = .center
        cells["Active"]=activeCell
        
        switchCell=nil
        let s=NSButton(checkboxWithTitle: "", target: self, action: #selector(RowCellSet.handler(_:)))
        s.tag=Int(uid)
        s.imagePosition = .imageOnly
        switchCell=s
        
        let linkCell=VTextField(labelWithString: "")
        linkCell.alignment = .center
        linkCell.tag=Int(uid)
        linkCell.font=FontDescriptor(family: .Monospace, size: .Small, weight: .black).font
        cells["Linked"]=linkCell
    }
    
    public subscript(_ name: String) -> NSView? {
        if name=="Inject" { return (mode == .destination) ? switchCell : nil }
        else if name=="Decode" { return (mode == .source) ? switchCell : nil }
        else {return cells[name] }
    }
    
    public var Switch : Bool {
        get { return switchCell.boolValue }
        set(v) { switchCell.boolValue=v }
    }
    
    public var Active : Bool {
        get { return (cells["Active"] as? MIDIIndicatorView)?.status ?? false }
        set(v) { (cells["Active"] as? MIDIIndicatorView)?.status=v }
    }
    
    @objc func handler(_ sender : NSButton) {
        cb(uid,switchCell.boolValue)
    }
    
    @objc func linkHandler(_ sender : NSButton) {
        debugPrint("Go!")
        NotificationCenter.default.post(name: Controller.OpenLinkPanelRequest, object: nil)
    }
    
    public var Linked : MIDIUniqueID {
        get { return MIDIUniqueID(string: (cells["Linked"] as! VTextField).stringValue) }
        set(v) {
            if v==kMIDIInvalidUniqueID { (cells["Linked"] as! VTextField).stringValue="" }
            else { (cells["Linked"] as! VTextField).stringValue=v.UID }
        }
    }
}

