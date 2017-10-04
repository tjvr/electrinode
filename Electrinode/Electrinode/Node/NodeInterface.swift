//
//  NodeInterface.swift
//  Electrinode
//
//  Created by Tim on 04/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    func get<T>(key: String) throws -> T {
        guard let field = self[key] else { throw SerializationError.missing(key) }
        guard let value = field as? T else { throw SerializationError.invalid(key, field) }
        return value
    }
}

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
    func nodePing(payload: Any)
}

func handleNodeMessage(message: Any, delegate: NodeDelegate) throws {
    guard let dict = message as? [String: Any] else {
        throw SerializationError.wrongType("Object", message)
    }
    let type: String = try dict.get(key: "_type")
    
    switch type {
    case "httpStarted":
        let url: String = try dict.get(key: "url")
        delegate.nodeHttpStarted(url: url)
    case "ping":
        let data: Any = try dict.get(key: "data")
        delegate.nodePing(payload: data)
    default:
        throw SerializationError.invalid("_type", type)
    }
}


