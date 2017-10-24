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

#define NC_PROPERTY_GETTER(OBJECT, NAME, BLOCK) void OBJECT::Get ## NAME(Local<String> property, const PropertyCallbackInfo<Value>& args) { \
    Isolate* isolate = args.GetIsolate(); \
    OBJECT* obj = ObjectWrap::Unwrap<OBJECT>(args.Holder()); \
    Handle<Value> returnValue; \
    BLOCK; \
    args.GetReturnValue().Set(returnValue); }

#define NC_PROPERTY_SETTER(OBJECT, NAME, BLOCK) void OBJECT::Set ## NAME(Local<String> property, Local<Value> value, const PropertyCallbackInfo<void>& args) { \
    Isolate* isolate = args.GetIsolate(); \
    WindowObject* obj = ObjectWrap::Unwrap<WindowObject>(args.Holder()); \
    BLOCK; }

#define NC_METHOD(OBJECT, NAME, BLOCK) void OBJECT::NAME(const FunctionCallbackInfo<Value>& args) { \
    Isolate* isolate = args.GetIsolate(); \
    OBJECT* obj = ObjectWrap::Unwrap<OBJECT>(args.Holder()); \
    BLOCK; }
    
#define CHECK_STRING(value) { \
    if (!value->IsString()) { \
        isolate->ThrowException(STRING("Expected string")); \
        return; } \
    }

#endif /* macros_h */
