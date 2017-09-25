//
//  Node.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation


class Node {

    let entryPoint: String
    var thread: Thread!

    init(entryPoint: String) {
        self.entryPoint = entryPoint
    }
    
    func start() {
        thread = Thread {
            // argv[0] controls process.title.
            // Use the app name here
            let processTitle = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            
            // construct argv
            let nodeArgs = [processTitle, self.entryPoint]
            let argc = Int32(nodeArgs.count)
            let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: nodeArgs.count)
            for (index, arg) in nodeArgs.enumerated() {
                argv[index] = UnsafeMutablePointer<Int8>(mutating: arg.cString(using: .utf8)!)
            }
            
            // run Node/uv main loop
            let exitStatus = node_Start(argc, argv)
            
            // TODO: consider using node_Init and making our own v8 platform
            // so we can integrate closely with node
            
            // node has exited
            if exitStatus > 0 {
                print("node exited with code", exitStatus)
            }
        }
        thread.start()
    }
    
    // TODO message passing?
    // consider DispatchQueue
}
