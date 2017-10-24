//
//  WebView.cpp
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#include "WebView.hh"
#include "macros.hh"

using namespace v8;

Persistent<Function> WebViewObject::constructor;

WebViewObject::WebViewObject() {
    webView = [[WKWebView alloc] init];
    //[webView retain];
}

WebViewObject::~WebViewObject() {
    //[webView release];
}

Handle<FunctionTemplate> WebViewObject::Init( Isolate *isolate ) {
    EscapableHandleScope scope(isolate);
    
    // Prepare constructor template
    Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New);
    tpl->SetClassName(String::NewFromUtf8(isolate, "MyObject"));
    tpl->InstanceTemplate()->SetInternalFieldCount(1);
    
    // Prototype
    NODE_SET_PROTOTYPE_METHOD(tpl, "navigateTo", Navigate);
    
    //Return the JS wrapper for our C++ object
    return scope.Escape(tpl);
}

void WebViewObject::New(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    if (!args.IsConstructCall()) {
        isolate->ThrowException(STRING("Constructor WebView cannot be invoked without 'new'"));
        return;
    }
    
    // Invoked as constructor: `new MyObject(...)`
    WebViewObject* obj = new WebViewObject();
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());
}


void WebViewObject::Navigate(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = args.GetIsolate();
    
    WebViewObject* obj = ObjectWrap::Unwrap<WebViewObject>(args.Holder());
    
    Local<String> url = args[0]->ToString(isolate);
    
    NSString* urlString = NS_STRING(url);
    
    [obj->webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    //args.GetReturnValue().Set(Number::New(isolate, obj->));
}
