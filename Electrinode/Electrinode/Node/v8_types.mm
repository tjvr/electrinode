
//#include "node_main.h"
#import "v8_types.h"
//<Foundation/Foundation.h>

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;

extern "C" {

Handle<Value> v8_from_cocoa(NSObject* object) {
    return String::NewFromUtf8(isolate, "Moooo");
}

NSObject* cocoa_from_v8(Handle<Value> value) {
    return nil;
}

}
