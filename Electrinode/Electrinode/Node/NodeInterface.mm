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
#include "WindowObject.hh"

@implementation NodeInterface {
    
}

NSWindow* window;

-(void) bindTo:(Handle<ObjectTemplate>)global isolate:(Isolate*)isolate {
    Local<ObjectTemplate> interface = ObjectTemplate::New(isolate);
    global->Set(String::NewFromUtf8(isolate, "__electrinode"), interface, ReadOnly);
    
    interface->Set(String::NewFromUtf8(isolate, "WebView"), WebViewObject::Init(isolate), ReadOnly);
    interface->Set(String::NewFromUtf8(isolate, "Window"), WindowObject::Init(isolate), ReadOnly);
}

@end
