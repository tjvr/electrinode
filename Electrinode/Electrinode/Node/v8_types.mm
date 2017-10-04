
//#include "node_main.h"
#import "v8_types.h"
//<Foundation/Foundation.h>

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;

extern "C" {

Handle<Value> v8_from_cocoa(NSObject* obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *string = (NSString*)obj;
        const char* cString = [string UTF8String];
        Local<String> value = String::NewFromUtf8(isolate, cString);
        return value;
    }
    return Null(isolate);
}

NSObject* cocoa_from_v8(Handle<Value> value) {
    String::Utf8Value string(value);
    char* cString = *string;
    return [NSString stringWithUTF8String:cString];
}

}
