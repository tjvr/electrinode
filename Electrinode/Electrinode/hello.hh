//
//  hello.hh
//  Electrinode
//
//  Created by Tim on 26/09/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//
#include <node.h>

#ifndef hello_h
#define hello_h

using v8::FunctionCallbackInfo;
using v8::Isolate;
using v8::Local;
using v8::Object;
using v8::String;
using v8::Value;

namespace demo {
    void Method(const FunctionCallbackInfo<Value>& args);
}

#endif /* hello_h */
