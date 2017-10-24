//
//  NodeInterface.m
//  Electrinode
//
//  Created by Tim on 20/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NodeInterface.hh"
#include "WebView.hh"

@implementation NodeInterface {
    
}

NSWindow* window;

static void hello(const FunctionCallbackInfo<v8::Value>& args) {
    window = [[NSWindow alloc] init];
    [window makeKeyAndOrderFront:nil];
}

-(void) bindTo:(Handle<ObjectTemplate>)global isolate:(Isolate*)isolate {
    Local<ObjectTemplate> interface = ObjectTemplate::New(isolate);
    global->Set(String::NewFromUtf8(isolate, "__electrinode"), interface, ReadOnly);
    
    interface->Set(String::NewFromUtf8(isolate, "MyObject"), MyObject::StartUp(isolate), ReadOnly);
    
    interface->Set(String::NewFromUtf8(isolate, "hello"), FunctionTemplate::New(isolate, hello));

}

@end
