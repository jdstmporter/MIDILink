//
//  EndPointDelegate.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreMIDI
import MIDITools


public class MIDIEndPointHandler : NSResponder, NSTableViewDataSource, NSTableViewDelegate {
    
    
    
    
    
    enum Column {
        case Text
        case UID
        case Action
        case Switch
    }
    
    
    
    internal var registered : OrderedDictionary<MIDIUniqueID,ActiveMIDIObject>
    
    @IBOutlet weak var table : NSTableView!
    private var enableActivityIndicators : Bool = true
    internal var cells : OrderedDictionary<MIDIUniqueID,RowCellSet>
    private var clicked : MIDIUniqueID? = nil
    private var clickedIndex : Int? = nil
    
    
    public override init() {
        registered=OrderedDictionary<MIDIUniqueID,ActiveMIDIObject>()
        cells = OrderedDictionary<MIDIUniqueID,RowCellSet>()
        
        super.init()
 
    }
    
    public required init?(coder: NSCoder) {
        registered=OrderedDictionary<MIDIUniqueID,ActiveMIDIObject>()
        cells = OrderedDictionary<MIDIUniqueID,RowCellSet>()
        
        super.init(coder: coder)
    }
    
    private func handleLink(links: LinkedEndpoints) {
        cells.forEach { kv in
            let to=links.ids(from: kv.key).first
            let from=links.ids(to: kv.key).first
            kv.value.Linked = to ?? from ?? kMIDIInvalidUniqueID
        }
 
    }
    
    
    
    
    
    
    public func reset() {
        registered.removeAll()
    }
    
    public func load(endpoints: [MIDIEndpoint]? = nil,links: LinkedEndpoints) throws {
        
        if let endpoints = endpoints {

            let add : [MIDIEndpoint] = endpoints.compactMap { registered.has($0.uid) ? nil : $0 }
        
            let remove = registered.keySet.subtracting(endpoints.map { $0.uid })
            remove.forEach { uid in
                debugPrint("Deleting session for \(uid)")
                cells.remove(key: uid)
                registered.remove(key: uid)
            }
        
            try add.forEach { (endpoint) in
                debugPrint("Creating session for \(endpoint) with name \(endpoint.targetName)")
                do {
                    let wrapper = try ActiveMIDIObject.make(endpoint)
                    if let w = wrapper as? MIDISource {
                        w.activityCallback = { (uid,active) in
                            if let row = self.cells[uid] { row.Active=active }
                        }
                    }
                    registered[endpoint.uid]=wrapper
                
                    cells[endpoint.uid]=RowCellSet(endpoint: wrapper.endpoint as! MIDIEndpoint, handler: { (uid,status) in self.handleSwitches(uid,status) })
                }
                catch let e {
                    print("Error when creating session for \(endpoint) with name \(endpoint.targetName) : \(e)")
                    throw e
                }
            }
        }
        
        clicked=nil
        //clickedIndex=nil
        cells.forEach { $0.value.clear() }
        
        handleLink(links: links)
        
        
        
        
    }
    
    public subscript(_ uid : MIDIUniqueID) -> MIDIBase? {
        return registered[uid]?.endpoint
    }
    
    public func filtered(_ f: Bool) {
        registered.forEach { (arg) in
            let wrapper = arg.value
            if wrapper.isSource {
                //(wrapper as? MIDISourceWrapper)?.filtered=f
            }
        }
    }
    
    // Callbacks
    
    internal func highlight(_ uid: MIDIUniqueID?) {
            cells.forEach { $0.value.setState(.Highlighted, uid) }
            DispatchQueue.main.async { self.table.reloadData() }
        
    }
    
    @discardableResult internal func select(_ uid : MIDIUniqueID) -> Bool {
        return select(registered.index(of: uid) ?? -1)
    }
    @discardableResult internal func select(_ row : Int) -> Bool {
        if let item = registered.at(row), let cell = cells[item.uid] {
            if cell.isSelected {
                clicked = nil
                clickedIndex = nil
                cell.clear()
                return false
            }
           else {
                clicked = item.uid
                cells.forEach { $0.value.setState(.Selected,clicked) }
                clickedIndex = row
                return true
            }
        }
        return false
    }
    
    public func rowSelected(_ table: NSTableView) -> MIDIUniqueID? {
        select(self.table.clickedRow)
        DispatchQueue.main.async { table.reloadData() }
        print("Clicked index = \(clickedIndex ?? -1)")
        return clicked
    }
    
    public var selected : MIDIBase? {
        if let c=clicked { return registered[c]?.endpoint }
        else { return nil }
    }
    
    
    public func statusChange(_ uid: MIDIUniqueID, _ active: Any) {
        if enableActivityIndicators { DispatchQueue.main.async { self.table.reloadData() } }
    }
    
    public func handleSwitches(_ uid: MIDIUniqueID,_ status : Bool) {
        debugPrint("Handling switch for \(uid) with status \(status)")
        if let wrapper=registered[uid] {
            switch wrapper.mode {
            case .source:
                if status {
                    if let panel=DecoderPanel.launch(uid: uid), let w = wrapper as? MIDISource {
                        w.startDecoding(interface: panel)
                    }
                }
                else {
                    if let panel=DecoderPanel.close(uid: uid) {
                        //wrapper.stopDecoding()
                        panel.unlink()
                    }
                }
                break
            case .destination:
                break
            default:
                break
            }
        }
        
    }
    
    // Table data source functions
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return registered.count
    }


    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let wrapper=registered.at(row), let tableColumn=tableColumn {
            let column : String = tableColumn.title
            let uid=wrapper.uid
            if let cellSet = cells[uid] {
                cellSet.Active=wrapper.isActive
                let cell = cellSet[column]
                cell?.backgroundColor = cellSet.background
                return cell
            }
            
        }
        return nil
    }
    
    // Table delegate methods
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
   
    
    public func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return tableColumn?.title=="Linked"
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow: Int) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 21.0
    }
    
    // NSResponder methods
    
    public override func mouseEntered(with event: NSEvent) {
        debugPrint("Enter")
    }
    public override func mouseExited(with event: NSEvent) {
        debugPrint("Exit")
    }
    public override func mouseMoved(with event: NSEvent) {
        
    }
    public override func cursorUpdate(with event: NSEvent) {
        
    }
}

