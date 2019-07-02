//
//  MIDIDecodeTable.swift
//  MIDIUtils
//
//  Created by Julian Porter on 07/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import MIDITools



class MIDIDecodeTable : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
  
    
    //private static let colourNames : [String]=["textColour","rawByteColour","channelColour","commandColour","valueColour"]
    
    private var font : NSFont!
    private let table : NSTableView!
    private var decoder : MIDIDecoderBase?
    
    init(table t: NSTableView!,withColour c: Bool = true) {
        table = t
        
        
        super.init()
        
        table.delegate=self
        table.dataSource=self
        
       
        
    }
    
    func Touch() {
        DispatchQueue.main.async {
            self.table.reloadData()
            self.table.scrollRowToVisible(max(0,self.numberOfRows(in: self.table)-1))
        }
    }
    
    func link(decoder d:MIDIDecoderBase) {
        decoder=d
        decoder?.action = { self.Touch() }
    }
    
    
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return decoder?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if tableColumn==nil { return nil }
        let column = ["Timestamp","Packet","Channel","Description"].firstIndex(of: tableColumn!.title)
        if column==nil { return nil }
        
        guard let packet=decoder?[row] else { return nil }
        
        let string = FormattedString(font: font, colour: .black)
        
        switch tableColumn!.title {
        case "Timestamp":
            string.append(packet.Timestamp)
            break
        case "Packet":
            let raw=packet.Raw.map { String(format:"%02x",$0) }
            string.append(raw.joined(separator: "-"),colour: .brown)
            break
        case "Channel":
            string.append(packet.Channel.str,colour: .blue)
            break
        case "Description":
            string.append(packet.Command.str+" ",colour: .red)
            string.append("\(packet)",colour: .blue)
            break
        default:
            return nil
        }
        
        let view = VTextField(labelWithAttributedString: string.Value)
        view.verticalAlignment = .middle
        if tableColumn!.title != "Description" { view.alignment = .center }
        return view
    }

    
    
}
