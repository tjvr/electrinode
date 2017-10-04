//
//  Node.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation



class Node {
    static var thread: Thread!
    static var delegate: NodeDelegate?
    
    static func start(entryPoint: String) {
        thread = Thread {
            // argv[0] controls process.title.
            // Use the app name here
            let processTitle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            
            // construct argv,
            // run Node/uv main loop
            let exitCode = NodeCocoa.start(withArgs: [processTitle, entryPoint], onTick: _onTick, onMessage: _onMessage)
            
            // node has exited
            if exitCode > 0 {
                print("node exited with code", exitCode)
            }
        }
        thread.start()
    }
    
    static var outbox = [Any]()
    static let withOutbox = DispatchQueue(label: "Node sendQueue")
        
    static func send(_ obj: Any) {
        withOutbox.async {
            outbox.append(obj)
        }
    }
}

fileprivate func _onTick() {
    Node.withOutbox.async {
        for message in Node.outbox {
            NodeCocoa.emit(message)
        }
        Node.outbox.removeAll(keepingCapacity: true)
    }
}

fileprivate func _onMessage(_ message: Any?) {
    // ignore nil messages
    // TODO: warn about them?
    guard let message = message else { return }
    
    if let delegate = Node.delegate {
        // TODO do we need to avoid DispatchQueue for perf reasons?
        DispatchQueue.main.async {
            do {
                try handleNodeMessage(message: message, delegate: delegate)
            } catch let error as SerializationError {
                print("SerializationError:", error)
            } catch {
                fatalError("uncaught error in handleMessage")
            }
        }
    }
}
