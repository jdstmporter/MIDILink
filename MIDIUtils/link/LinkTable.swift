//
//  LinkTable.swift
//  MIDIUtils
//
//  Created by Julian Porter on 13/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreMIDI



class MIDIIndicatorView : NSBox {
    
    private var _status : Bool=false
    private var image : NSImageView!
    
    init(status s: Bool = false) {
        super.init(frame: NSZeroRect)
        initialise(status: status)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise(status: false)
    }
    
    private func initialise(status s: Bool) {
        boxType = .custom
        borderType = .lineBorder
        borderColor = NSColor.black
        fillColor = NSColor(deviceWhite: 1, alpha: 0)
        borderWidth = 1.0
        cornerRadius = 0
        titlePosition = .noTitle
        
        image=NSImageView()
        self.contentView=image
        
        status=s
    }
    
    var status : Bool {
        get { return _status }
        set {
            _status=newValue
            let name=(status) ? NSImage.Name.statusAvailable : NSImage.Name.statusNone
            image.image=NSImage(named: name)
        }
    }
    
    
    
}



extension NSImageView {
    
    func setStatusImage(_ status : Bool = false) -> NSImageView {
        let name=(status) ? NSImage.Name.statusAvailable : NSImage.Name.statusNone
        self.image=NSImage(named: name)
        return self
    }
}

class LinkageWindow : NSPanel, LaunchableItem, NSTableViewDelegate, NSTableViewDataSource {
    
    
    internal typealias ConnectionID = String
    static var nibname = NSNib.Name("LinkTable")
    static var lock = NSLock()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(LinkageWindow.updateTables(_:)), name: LinkManager.MIDILinkTableChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LinkageWindow.resizeColumns(_:)), name: NSWindow.didResizeNotification,object: nil)
        
    }
    @IBOutlet weak var table: NSTableView!
    
    private var links : ILinkTableSource!
    private var matrix : [String: NSView] = [:]
    private var rows : [String] = []
    private var columns : [String] = []

    private func toTag(_ from: String, _ to: String) -> String {
        return "\(from):\(to)"
    }
    
    @objc private func updateTables(_ n: NSNotification? = nil) {
        rows.forEach { (from) in
            columns.forEach { (to) in
                let tag=toTag(from,to)
                let field = (matrix[tag] as! MIDIIndicatorView?) ?? MIDIIndicatorView()
                field.status=links[from,to]
                matrix[tag]=field
            }
        }
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    private func columnNamed(name: String) -> NSTableColumn {
        let column=NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: name))
        column.title=name
        column.maxWidth=CGFloat.greatestFiniteMagnitude
        column.minWidth=0
        column.width=table.bounds.width/CGFloat(1+columns.count)
        column.headerCell.alignment = .center
        column.headerToolTip=links.tooltip(name)
        return column
    }
    
    private func makeCell(content: String = "") -> VTextField {
        let field=VTextField(labelWithString: content)
        field.textColor=NSColor.black
        
        field.font=FontDescriptor.Small.font
        field.alignment = .center
        field.verticalAlignment = .middle
        return field
    }
    
    
    
    @objc private func resizeColumns(_ n: NSNotification) {
        if n.object is LinkageWindow?   {
            let width : CGFloat = table.bounds.width/CGFloat(1+columns.count)
            table.tableColumns.forEach { $0.width=width }
        }
        touch()
    }
    

    public func setDevices(_ manager: ILinkTableSource) {
        links=manager
        rows=links.fromLabels
        columns=links.toLabels
        updateTables()
        
        rows.forEach { (from) in
            columns.forEach { (to) in
                let tag=toTag(from,to)
                matrix[tag]=MIDIIndicatorView()
            }
            let cell=makeCell(content: from)
            cell.toolTip=links.tooltip(from)
            matrix[toTag(from,"source")]=cell
        }
        debugPrint("\(matrix)")
        DispatchQueue.main.async {
            self.table.tableColumns.forEach { self.table.removeTableColumn($0) }
            self.table.addTableColumn(self.columnNamed(name: "source"))
            self.columns.forEach { self.table.addTableColumn(self.columnNamed(name: $0 )) }
        }
        
    }
    
    public func touch() {
        self.table.reloadData()
        self.viewsNeedDisplay=true
    }
    
 /*   func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        debugPrint("Object for row \(row) column \(tableColumn?.title)")
        if row < 0 || row >= rows.count { return nil }
        if tableColumn==nil { return nil }
        let source=rows[row]
        let tag=toTag(source,tableColumn!.title)
        return matrix[tag]
    }*/
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        debugPrint("View for row \(row) column \(String(describing: tableColumn?.title))")
        if row < 0 || row >= rows.count { return nil }
        if tableColumn==nil { return nil }
        let source=rows[row]
        let tag=toTag(source,tableColumn!.title)
        return matrix[tag]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        debugPrint("Number of rows is \(rows.count)")
        return rows.count
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    
    @IBAction func didClick(_ tableView : NSTableView) {
        debugPrint("\(table.clickedColumn) - \(table.clickedRow)")
        if table.clickedColumn<1 || table.clickedColumn > columns.count { return }
        if table.clickedRow<0 || table.clickedRow >= rows.count { return }
        let source=rows[table.clickedRow]
        let destination=columns[table.clickedColumn-1]
        let status=links[source,destination]
        
        do {
            if status { try links.unlink(from: source,to: destination) }
            else { try links.link(from: source,to: destination) }
        } catch LinkTableError.NoSuchEndpoint {
            debugPrint("One of the endpoints doesn't exist: \(source), \(destination)")
        } catch LinkTableError.LinkToItemAlreadyExists {
            debugPrint("The destination endpoint \(destination) is already linked")
        } catch LinkTableError.LinkFromItemAlreadyExists {
            debugPrint("The source endpoint \(source) is already linked")
        } catch LinkTableError.NoSuchLink {
            debugPrint("There is no link between \(source) and \(destination)")
        } catch {
            debugPrint("Catch-all: something unexpected happened")
        }
    }
    
    @IBAction func didDoubleClick(_ tableView : NSTableView) {
        
    }
    private static var the : LinkageWindow?
    
    

    

    public static func Create() -> LinkageWindow {
        if the == nil { the = instance() }
        return the!
    }
}


