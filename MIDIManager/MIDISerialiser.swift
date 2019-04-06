//
//  MIDISerialiser.swift
//  MIDIManager
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol Serialisable  {
    var str : String { get }
}




extension  UInt8: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt16: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt32: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt64: Serialisable {
    public var str : String { return "\(self)" }
}
extension String : Serialisable {
    public var str : String { return self }
}
extension Bool : Serialisable {
    public var str : String { return self ? "ON" : "OFF" }
}




public protocol MIDISerialiser {
 
    
    init(messages: [MIDIMessage])
    
    var data : Data { get }
    var str : String { get }
    
}



public protocol SerialisationElement {
    
    init(name: String,attributes: [KVPair])
    
    mutating func addChild(_ child: Self)
    mutating func empty()
    
    var data : Data { get }
}

public struct XMLAttribute  {
    
    internal let node : XMLNode
    
    public init(key: String,value : Serialisable) {
        node = XMLNode(kind: .attribute)
        node.name=key
        node.stringValue=value.str
    }
}



public class BaseMIDISerialiser<Element> : MIDISerialiser where Element : SerialisationElement {
    
    internal var messages : [MIDIMessage]
    internal var root : Element

    
    public required init(messages: [MIDIMessage]) {
        self.messages=messages
        self.root=Element(name: "MIDI", attributes: [])
    }
    
    internal func serialise(message: MIDIMessage) -> Element {
        let packet = message.packet
        return Element(name: packet.command.name, attributes: packet.attrs)
    }
    
    internal func serialise() {
        root.empty()
        messages.forEach { root.addChild(serialise(message: $0)) }
    }
    
    public var data : Data {
        serialise()
        return root.data
    }
    
    public var str : String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

public class XMLSerialisationElement : SerialisationElement {
    
    private var element : XMLElement
    
    public required init(name: String, attributes: [KVPair]) {
        element = XMLElement(name: name)
        attributes.forEach { element.addAttribute(XMLAttribute(key: $0.key, value: $0.value).node) }
    }
    
    public func addChild(_ child: XMLSerialisationElement) {
        element.addChild(child.element)
    }
    
    public func empty() {
        while element.childCount>0 { element.removeChild(at: 0) }
    }
    
    public var data : Data {
        let document = XMLDocument(rootElement: element)
        document.characterEncoding = "UTF-8"
        document.isStandalone = true
        return document.xmlData
    }
}



public class JSONSerialisationElement : SerialisationElement, Encodable {
    
    public var name : String
    public var attributes : [[String:String]]
    public var objects : [JSONSerialisationElement]
    
    public required init(name: String, attributes: [KVPair]) {
        self.name = name
        self.attributes = attributes.map { [ "key" : $0.key, "value" : $0.value.str ] }
        self.objects = []
    }
    public func addChild(_ child: JSONSerialisationElement) {
        self.objects.append(child)
    }
    public func empty() {
        self.objects.removeAll()
    }
    public var data : Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
    
    enum CodingKeys : String, CodingKey {
        case name
        case attributes
        case objects
    }
    
}

public typealias XMLSerialiser = BaseMIDISerialiser<XMLSerialisationElement>
public typealias JSONSerialiser = BaseMIDISerialiser<JSONSerialisationElement>
    
    



