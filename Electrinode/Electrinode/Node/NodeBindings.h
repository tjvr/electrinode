//
//  NodeBindings.h
//  Electrinode
//
//  Created by Tim on 08/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NodeBindings : NSObject

-(id)initWithRunLoop:(CFRunLoopRef)runLoop;
-(void) prepareMessageLoop;
-(void) setupNodeWithArgs:(NSArray<NSString*>*)arguments;

// private
-(id)uvRunOnce;

@end
