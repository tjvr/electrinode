//
//  macros.h
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#ifndef macros_h
#define macros_h

#define STRING(cString) String::NewFromUtf8(isolate, cString)
#define LOCAL_STRING(nsString) ((Local<String>)String::NewFromUtf8(isolate, [nsString UTF8String]))
#define NS_STRING(localString) [NSString stringWithUTF8String: *(String::Utf8Value(localString))]

#define NC_UNWRAP(OBJECT) ObjectWrap::Unwrap<OBJECT>(args.Holder()); Isolate* isolate = args.GetIsolate()

#define NC_DEFINE_PROPERTY(name) \
    static void get_ ## name(Local<String> property, const PropertyCallbackInfo<Value>& args); \
    static void set_ ## name(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args);

#define NC_ATTACH_PROPERTY(name) instanceTpl->SetAccessor(String::NewFromUtf8(isolate, #name), get_ ## name, set_ ## name)

// TODO better error handling
#define CHECK_STRING(value) if (!value->IsString()) { isolate->ThrowException(STRING("Expected string")); return; }
#define CHECK_NUMBER(value) if (!value->IsNumber()) { isolate->ThrowException(STRING("Expected number")); return; }

#endif /* macros_h */
