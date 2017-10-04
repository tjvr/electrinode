
#include "node_main.h"
#import <Foundation/Foundation.h>

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;

typedef struct _NodeValue {} _NodeValue;

extern Handle<Value> v8_from_cocoa(NSObject* object) {
    return String::NewFromUtf8(isolate, "moo");
}

extern NSObject* cocoa_from_v8(Handle<Value> value) {
    return nil;
}
