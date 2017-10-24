//
//  WebView.cpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#include "WindowObject.hh"

using namespace v8;

Persistent<Function> WindowObject::constructor;

WindowObject::WindowObject() {
    window = [[NSWindow alloc] init]; //initWithContentRect:<#(NSRect)#> styleMask:<#(NSWindowStyleMask)#> backing:<#(NSBackingStoreType)#> defer:<#(BOOL)#>];
    [window setStyleMask:[window styleMask] | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable];
    //[window setStyleMask:[window styleMask] & ~NSResizableWindowMask];
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
    NC_ATTACH_PROPERTY(title);
    NC_ATTACH_PROPERTY(minWidth);
    NC_ATTACH_PROPERTY(minHeight);
    
    // TODO error for invalid property access
    
    // Prototype
    NODE_SET_PROTOTYPE_METHOD(tpl, "focus", focus);
    
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

void WindowObject::get_title(Local<String> property, const PropertyCallbackInfo<Value>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    args.GetReturnValue().Set(LOCAL_STRING([obj->window title]));
}
void WindowObject::set_title(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    CHECK_STRING(value);
    [obj->window setTitle:NS_STRING(value)];
}

void WindowObject::get_minWidth(Local<String> property, const PropertyCallbackInfo<Value>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    CGSize size = [obj->window minSize];
    args.GetReturnValue().Set(Number::New(isolate, size.width));
}
void WindowObject::set_minWidth(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    CHECK_NUMBER(value);
    Local<Number> number = value->ToNumber();
    CGSize size = [obj->window minSize];
    [obj->window setMinSize:CGSizeMake(number->Value(), size.height)];
    // TODO resize now
}

void WindowObject::get_minHeight(Local<String> property, const PropertyCallbackInfo<Value>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    CGSize size = [obj->window minSize];
    args.GetReturnValue().Set(Number::New(isolate, size.height));
}
void WindowObject::set_minHeight(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    CHECK_NUMBER(value);
    Local<Number> number = value->ToNumber();
    CGSize size = [obj->window minSize];
    [obj->window setMinSize:CGSizeMake(size.width, number->Value())];
    // TODO resize now
}

void WindowObject::focus(const FunctionCallbackInfo<Value>& args) {
    WindowObject *obj = NC_UNWRAP(WindowObject);
    [obj->window makeKeyAndOrderFront:nil];
}

