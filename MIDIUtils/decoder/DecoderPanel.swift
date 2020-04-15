//
//  Window.swift
//  MIDIUtils
//
//  Created by Julian Porter on 20/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import AppKit

import CoreMIDI



class DecoderPanel : NSPanel, LaunchableItem , MIDIDecoderInterface {
    
    static var lock = NSLock()
   static var nibname : NSNib.Name = NSNib.Name("Decoder")
    
    enum MenuBarItem : Int    {
        case Save = 1
        case Clear = 2
        case Start = 3
        case Pause = 4
        case Print = 5
    }

    
    @IBOutlet var header: VTextField!
    @IBOutlet var table: NSTableView!
    
    internal var decoder : MIDIDecoder!
    
    private var tableDelegate : MIDIDecodeTable!
    
    @IBOutlet weak var menuBar: NSToolbar!
    
    
    func link(decoder d:MIDIDecoder) {
        decoder=d
        tableDelegate?.link(decoder: decoder)
    }
    
   
    
    public func unlink() {
        decoder?.action = nil
        tableDelegate=nil
        decoder=nil
    }
    

    
    
    
    
    @IBAction func menuBarAction(_ sender: NSToolbarItem) {
        let item=MenuBarItem(rawValue: sender.tag)
        if item==nil { return }
        switch item! {
        case .Clear:
            decoder?.reset()
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            break
        case .Save:
            //let saver=SavePackets(decoder: decoder)
            //saver.action(window: self)
            break
        case .Print:
            //let printer=PrintPackets(decoder: decoder)
            //printer.action(window: self)
            break
        default:
            break
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableDelegate=MIDIDecodeTable(table: table)
        
        
    }
    
  
    /*
    override func changeFont(_ sender: Any?) {
        debugPrint("Change Font occurred!")
        let f = (sender as! NSFontManager?)?.convert(tableDelegate.Font)
        if f != nil { tableDelegate.Font = f! }
    }*/
    
    
    
    
    
    static var panels : [MIDIUniqueID : DecoderPanel] = [:]
    static var nib : NSNib?
    
    
    
    static func launch(uid: MIDIUniqueID) -> DecoderPanel? {
        var panel : DecoderPanel? = panels[uid]
        if panel == nil {
            panel=instance()
            panels[uid]=panel
        }
        
        panel?.header.stringValue=String(format:"Decoded MIDI for %08X",uid)
        panel?.makeKeyAndOrderFront(nil)
        
        return panel
    }
    
    static func close(uid: MIDIUniqueID) -> DecoderPanel? {
        let panel=panels[uid]
        panel?.performClose(nil)
        return panel
    }
    
    static func reset() {
        panels.removeAll()
    }
    
    
    
}
