//
//  AppDelegate.swift
//  Electrinode
//
//  Created by Tim on 25/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let nodeThread = Thread {
            let nodeArgs = ["node", Bundle.main.resourcePath!.appending("/main.js")]
            
            var argc = Int32(nodeArgs.count)
            let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: nodeArgs.count)
            for (index, arg) in nodeArgs.enumerated() {
                argv[index] = UnsafeMutablePointer<Int8>(mutating: arg.cString(using: .utf8)!)
            }
            
            //node_Init(&argc, argv, argc, argv)
            
            let exitStatus = node_Start(argc, argv)
            
            // node has exited
            if exitStatus > 0 {
                print("node exited with code", exitStatus)
            }
        }
        nodeThread.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

