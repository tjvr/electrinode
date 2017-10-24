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

void WindowObject::GetTitle(Local<String> property, const PropertyCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    WindowObject* obj = ObjectWrap::Unwrap<WindowObject>(args.Holder());
    
    args.GetReturnValue().Set(LOCAL_STRING([obj->window title]));
}

void WindowObject::SetTitle(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args) {
    Isolate* isolate = args.GetIsolate();
    WindowObject* obj = ObjectWrap::Unwrap<WindowObject>(args.Holder());
    if (!value->IsString()) {
        isolate->ThrowException(STRING("Expected string"));
    }
    
    [obj->window setTitle:NS_STRING(value)];
}


void WindowObject::Hello(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    WindowObject* obj = ObjectWrap::Unwrap<WindowObject>(args.Holder());
    
    [obj->window makeKeyAndOrderFront:nil];
    [obj->window setTitle:@"frob"];
    
    
    // TODO ???
    
    //args.GetReturnValue().Set(Number::New(isolate, obj->));
}
