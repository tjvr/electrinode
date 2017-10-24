//
//  WebView.cpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#include "WindowObject.hh"
#include "macros.hh"

using namespace v8;

Persistent<Function> WindowObject::constructor;

WindowObject::WindowObject() {
    window = [[NSWindow alloc] init];
    //[webView retain];
}

WindowObject::~WindowObject() {
    //[webView release];
}

Handle<FunctionTemplate> WindowObject::Init( Isolate *isolate ) {
    EscapableHandleScope scope(isolate);
    
    // Prepare constructor template
    Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New);
    tpl->SetClassName(String::NewFromUtf8(isolate, "Window"));
    
    Local<ObjectTemplate> instanceTpl = tpl->InstanceTemplate();
    instanceTpl->SetInternalFieldCount(1);
    instanceTpl->SetAccessor(STRING("title"), GetTitle, SetTitle);
    
    // Prototype
    NODE_SET_PROTOTYPE_METHOD(tpl, "hello", Hello);
    
    //Return the JS wrapper for our C++ object
    return scope.Escape(tpl);
}

void WindowObject::New(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    if (!args.IsConstructCall()) {
        isolate->ThrowException(STRING("Constructor WebView cannot be invoked without 'new'"));
        return;
    }
    
    // Invoked as constructor: `new MyObject(...)`
    WindowObject* obj = new WindowObject();
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());
    
    if (args[0]->IsObject()) {
        Local<Object> options = args[0]->ToObject(isolate);
        // TODO set attributes
    }
}

NC_PROPERTY_GETTER(WindowObject, Title, {
    returnValue = LOCAL_STRING([obj->window title]);
})

NC_PROPERTY_SETTER(WindowObject, Title, {
    CHECK_STRING(value);
    [obj->window setTitle:NS_STRING(value)];
})

NC_METHOD(WindowObject, Hello, {
    [obj->window makeKeyAndOrderFront:nil];
    [obj->window setTitle:@"frob"];
})

