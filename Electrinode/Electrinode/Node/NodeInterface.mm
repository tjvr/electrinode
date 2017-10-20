//
//  NodeInterface.m
//  Electrinode
//
//  Created by Tim on 20/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import "NodeInterface.hh"


@implementation NodeInterface

static void hello(const FunctionCallbackInfo<v8::Value>& args) {
    args.GetReturnValue().Set(4.0);
}

-(void) bindTo:(Handle<ObjectTemplate>)global isolate:(Isolate*)isolate {
    Local<ObjectTemplate> interface = ObjectTemplate::New(isolate);
    global->Set(String::NewFromUtf8(isolate, "__electrinode"), interface);
    
    interface->Set(String::NewFromUtf8(isolate, "hello"), FunctionTemplate::New(isolate, hello));

}

@end
