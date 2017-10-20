//
//  NodeInterface.h
//  Electrinode
//
//  Created by Tim on 20/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <v8.h>

using namespace v8;

@interface NodeInterface : NSObject

-(void) bindTo:(Handle<ObjectTemplate>)global isolate:(Isolate*)isolate;

@end
