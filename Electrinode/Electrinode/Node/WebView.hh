//
//  WebView.hpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#ifndef WebView_hpp
#define WebView_hpp

#include <stdio.h>

#include <node.h>
#include <node_object_wrap.h>

class MyObject : public node::ObjectWrap {
public:
    static void Init(v8::Local<v8::Object> exports);
    static v8::Handle<v8::FunctionTemplate> StartUp( v8::Isolate *isolate );
    
private:
    explicit MyObject(double value = 0);
    ~MyObject();
    
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void PlusOne(const v8::FunctionCallbackInfo<v8::Value>& args);
    static v8::Persistent<v8::Function> constructor;
    double value_;
};

#endif /* WebView_hpp */
