//
//  WebView.cpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#include "WebView.hh"

using namespace v8;

Persistent<Function> WebViewObject::constructor;

WebViewObject::WebViewObject(double value) : value_(value) {
}

WebViewObject::~WebViewObject() {
}

Handle<FunctionTemplate> WebViewObject::Init( Isolate *isolate ) {
    EscapableHandleScope scope(isolate);
    
    // Prepare constructor template
    Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New);
    tpl->SetClassName(String::NewFromUtf8(isolate, "MyObject"));
    tpl->InstanceTemplate()->SetInternalFieldCount(1);
    
    // Prototype
    NODE_SET_PROTOTYPE_METHOD(tpl, "plusOne", PlusOne);
    
    //Return the JS wrapper for our C++ object
    return scope.Escape(tpl);
}

void WebViewObject::New(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    
    if (args.IsConstructCall()) {
        // Invoked as constructor: `new MyObject(...)`
        double value = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
        WebViewObject* obj = new WebViewObject(value);
        obj->Wrap(args.This());
        args.GetReturnValue().Set(args.This());
    } else {
        // Invoked as plain function `MyObject(...)`, turn into construct call.
        const int argc = 1;
        Local<Value> argv[argc] = { args[0] };
        Local<Context> context = isolate->GetCurrentContext();
        Local<Function> cons = Local<Function>::New(isolate, constructor);
        Local<Object> result =
        cons->NewInstance(context, argc, argv).ToLocalChecked();
        args.GetReturnValue().Set(result);
    }
}

void WebViewObject::PlusOne(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    
    WebViewObject* obj = ObjectWrap::Unwrap<WebViewObject>(args.Holder());
    obj->value_ += 1;
    
    args.GetReturnValue().Set(Number::New(isolate, obj->value_));
}
