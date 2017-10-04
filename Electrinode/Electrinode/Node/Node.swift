//
//  Node.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation

var nodeThread: Thread!

class Node {
    static func start(entryPoint: String) {
        nodeThread = Thread {
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
        nodeThread.start()
    }
    
    static func send(_ obj: NSObject) {
        NodeCocoa.emit(obj)
    }
}

private func _onTick() {
    Node.send(NSString(string: "Hello from Swift"))
}

private func _onMessage(_ obj: NSObject?) {
    guard let obj = obj else {
        return // got nil
    }
    
    
    if let string = obj as? String {
        print("Swift got:", obj)
    }
}
