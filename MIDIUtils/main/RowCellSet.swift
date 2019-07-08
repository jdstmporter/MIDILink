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

@dynamicMemberLookup
public class Lookup<Key, Value> where Key : NamedEnumeration {
    
    private var dict : [Key:Value?]
    
    init() {
        self.dict=[:]
        Key.allCases.forEach { self.dict[$0] = nil }
    }
    
    subscript(dynamicMember key: String) -> Value? {
        get { return self[key] }
        set { self[key]=newValue }
    }
    subscript(_ key : String) -> Value? {
        get {
            if let k = Key(key), let v = dict[k] { return v }
            else { return nil }
        }
        set {
            if let k = Key(key) { dict[k]=newValue }
        }
    }
    subscript(_ key : Key) -> Value? {
        get { if let v = dict[key] { return v } else { return nil } }
        set { dict[key]=newValue }
    }
    
}

internal class RowCellSet {
    
    internal enum Cells : NamedEnumeration {
        case Name
        case Model
        case Manufacturer
        case UID
        case Active
        case Linked
        
        public static let names : [Cells : String] = { () in
            var d : [Cells : String] = [:]
            Cells.allCases.forEach { d[$0] = "\($0)" }
            return d
        }()
    }
    
    private var cells = Lookup<Cells,NSView>()
    private let uid : MIDIUniqueID
    private var switchCell : NSButton!
    private let mode : MIDIObjectMode
    private let cb : (_:MIDIUniqueID,_:Bool) -> ()
    
    init(endpoint: MIDIEndpoint,handler:@escaping (_:MIDIUniqueID,_:Bool) -> ()) {
        uid=endpoint.uid
        mode=endpoint.mode
        cb=handler
        
        
        cells.Name=VTextField(labelWithString: endpoint.name)
        cells.Model=VTextField(labelWithString: endpoint.model)
        cells.Manufacturer=VTextField(labelWithString: endpoint.manufacturer)
        
        let uidCell=VTextField(labelWithString: endpoint.uid.hex)
        uidCell.font=Font(family: .Monospace, size: .Small, weight: .black).font
        cells.UID=uidCell
        
        let activeCell=MIDIIndicatorView() //NSTextField(labelWithString: "")
        //activeCell.alignment = .center
        cells.Active=activeCell
        
        switchCell=nil
        let s=NSButton(checkboxWithTitle: "", target: self, action: #selector(RowCellSet.handler(_:)))
        s.tag=Int(uid)
        s.imagePosition = .imageOnly
        switchCell=s
        
        let linkCell=VTextField(labelWithString: "")
        linkCell.alignment = .center
        linkCell.tag=Int(uid)
        linkCell.font=Font(family: .Monospace, size: .Small, weight: .black).font
        cells.Linked=linkCell
    }
    
    public subscript(_ name: String) -> NSView? {
        var cell : NSView? = nil
        if name=="Inject" { cell = (mode == .destination) ? switchCell : nil }
        else if name=="Decode" { cell = (mode == .source) ? switchCell : nil }
        else { cell = cells[name] }
        return cell
    }
    
    public var Switch : Bool {
        get { return switchCell.boolValue }
        set(v) { switchCell.boolValue=v }
    }
    
    public var Active : Bool {
        get { return (cells.Active as? MIDIIndicatorView)?.status ?? false }
        set(v) { (cells.Active as? MIDIIndicatorView)?.status=v }
    }
    
    @objc func handler(_ sender : NSButton) {
        cb(uid,switchCell.boolValue)
    }
    
    
    
    public var Linked : MIDIUniqueID {
        get { return MIDIUniqueID((cells.Linked as! VTextField).stringValue) ?? kMIDIInvalidUniqueID }
        set(v) {
            if v==kMIDIInvalidUniqueID { (cells.Linked as! VTextField).stringValue="" }
            else { (cells.Linked as! VTextField).stringValue=v.hex }
        }
    }
}

