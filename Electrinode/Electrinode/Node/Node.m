//
//  Node.m
//  Electrinode
//
//  Created by Tim on 06/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import "Node.h"
#import "NodeCocoa.h"

void _onTick() {
    
}

void _onMessage(id message) {
    
}

@implementation Node

+(void)start {
    NSString *processTitle = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:kCFBundleNameKey];
    NSString *entryPoint = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/main.js"];

    [NodeCocoa startWithArgs:@[processTitle, entryPoint] onTick:_onTick onMessage:_onMessage];
}
 
@end
