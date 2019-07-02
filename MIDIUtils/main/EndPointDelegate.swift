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


public class MIDIEndPointHandler : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
   
    
    
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
    
    public override init() {
        registered=OrderedDictionary<MIDIUniqueID,ActiveMIDIObject>()
        cells = OrderedDictionary<MIDIUniqueID,RowCellSet>()
        super.init()
        

        
    }
    
    @objc private func linkChanged(_ n : Notification) {
        guard let info = n.userInfo else { return }
        let from=info["from"] as? MIDIUniqueID ?? kMIDIInvalidUniqueID
        let to=info["to"] as? MIDIUniqueID ?? kMIDIInvalidUniqueID
        let status=info["linked"] as? Bool ?? false
        cells[from]?.Linked = status ? to : kMIDIInvalidUniqueID
        cells[to]?.Linked = status ? from : kMIDIInvalidUniqueID
        table.reloadData()
    }
    
    
    public func register(endpoint : MIDIEndpoint) throws {
        let wrapper = try ActiveMIDIObject.make(endpoint)
        if let w = wrapper as? MIDISource {
            w.activityCallback = { (uid,active) in
                if let row = self.cells[uid] { row.Active=active }
            }
        }
        registered[endpoint.uid]=wrapper
        
        cells[endpoint.uid]=RowCellSet(endpoint: wrapper.endpoint as! MIDIEndpoint, handler: { (uid,status) in self.handleSwitches(uid,status) })
        //return wrapper
    }
    
    public func reset() {
        registered.removeAll()
    }
    
    public func load(endpoints: [MIDIEndpoint]) throws {

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
                try self.register(endpoint: endpoint)
            }
            catch let e {
                print("Error when creating session for \(endpoint) with name \(endpoint.targetName) : \(e)")
                throw e
            }
        }
        
        
        
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
                return cellSet[column]
            }
        }
        return nil
    }
    
    // Table delegate methods
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        if tableColumn.title=="Linked" {
            NotificationCenter.default.post(name: Controller.OpenLinkPanelRequest, object: nil)
        }
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
}

