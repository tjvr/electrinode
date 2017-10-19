//
//  AppDelegate.m
//  Electrinode
//
//  Created by Tim on 06/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import "AppDelegate.h"
#import "Node/NodeBindings.h"

@interface AppDelegate ()


@end

#define RUN_LOOP_UNTIL(condition) { \
  while (!condition) \
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; }


@implementation AppDelegate {
    NodeBindings* bindings;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    bindings = [[NodeBindings alloc] initWithRunLoop:CFRunLoopGetCurrent()];
    [bindings prepareMessageLoop];
    
    NSString* entryPoint = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"main.js"];
    [bindings setupNodeWithArgs:@[@"node", entryPoint]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



@end
