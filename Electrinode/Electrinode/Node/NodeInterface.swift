//
//  NodeInterface.swift
//  Electrinode
//
//  Created by Tim on 04/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
    case wrongType(String, Any)
    
    func string() -> String {
        switch self {
        case .missing(let name): return "Missing `\(name)` field"
        case .invalid(let name, let value): return "Invalid `\(name)` field: \(value)"
        case .wrongType(let type, let value): return "Expected \(type), got: \(value)"
        }
    }
}

protocol NodeDelegate: class {
    func nodeHttpStarted(url: String)
}

func handleNodeMessage(message: Any, delegate: NodeDelegate) throws {
    guard let dict = message as? [String: Any] else {
        throw SerializationError.wrongType("Object", message)
    }
    //let t dict["_type"]
    guard let type = dict["_type"] as? String else {
        throw SerializationError.missing("_type")
    }
    
    switch type {
    case "http-started":
        guard let url = dict["url"] as? String else {
            throw SerializationError.missing("url")
        }
        delegate.nodeHttpStarted(url: url)
    default:
        throw SerializationError.invalid("_type", type)
    }
}


