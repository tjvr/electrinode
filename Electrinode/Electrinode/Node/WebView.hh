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

#import <WebKit/WebKit.h>

class WebViewObject : public node::ObjectWrap {
public:
    static v8::Handle<v8::FunctionTemplate> Init( v8::Isolate *isolate );
    
private:
    explicit WebViewObject();
    ~WebViewObject();
    
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static v8::Persistent<v8::Function> constructor;
    
    WKWebView* webView;
    
    static void Navigate(const v8::FunctionCallbackInfo<v8::Value>& args);
};

#endif /* WebView_hpp */
