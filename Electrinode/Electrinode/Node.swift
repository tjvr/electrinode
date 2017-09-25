//
//  Node.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Foundation


class Node {
    
    var thread: Thread!

    init() {}
    
    func start() {
        thread = Thread {
            let nodeArgs = ["node", Bundle.main.resourcePath!.appending("/main.js")]
            
            let argc = Int32(nodeArgs.count)
            let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: nodeArgs.count)
            for (index, arg) in nodeArgs.enumerated() {
                argv[index] = UnsafeMutablePointer<Int8>(mutating: arg.cString(using: .utf8)!)
            }
            
            let exitStatus = node_Start(argc, argv)
            
            // node has exited
            
            if exitStatus > 0 {
                print("node exited with code", exitStatus)
            }
        }
        thread.start()
    }
}
