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
            
            // construct argv
            let nodeArgs = [processTitle, entryPoint]
            let argc = Int32(nodeArgs.count)
            let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: nodeArgs.count)
            for (index, arg) in nodeArgs.enumerated() {
                argv[index] = UnsafeMutablePointer<Int8>(mutating: arg.cString(using: .utf8)!)
            }
            let contiguous_argv = node_fix_argv(argc, argv)
            
            // run Node/uv main loop
            let exitCode = node_main(argc, contiguous_argv, _onTick, _onMessage)
            
            // node has exited
            if exitCode > 0 {
                print("node exited with code", exitCode)
            }
        }
        nodeThread.start()
    }
    
    static func send(_ message: NSObject) {
        let value = wrap_v8_from_cocoa(message)
        
        print(value)
    }
}

private func _onTick() {
    
}

private func _onMessage(_ message: NodeValue) {
    print(message)
    
    guard let obj = wrap_cocoa_from_v8(message) else {
        return // TODO cry
    }
}
