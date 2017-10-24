//
//  WebView.hpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#ifndef WindowObject_hpp
#define WindowObject_hpp

#include <stdio.h>

#include <node.h>
#include <node_object_wrap.h>

#import <Cocoa/Cocoa.h>

using namespace v8;

class WindowObject : public node::ObjectWrap {
public:
    static v8::Handle<v8::FunctionTemplate> Init( v8::Isolate *isolate );
    
private:
    explicit WindowObject();
    ~WindowObject();
    
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static v8::Persistent<v8::Function> constructor;
    
    NSWindow* window;
    
    static void Hello(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void GetTitle(Local<String> property, const PropertyCallbackInfo<Value>& args);
    static void SetTitle(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args);
};

#endif /* WindowObject_hpp */
