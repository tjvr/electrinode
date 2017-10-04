
#include "node_cocoa.h"
#include "node_main.h"

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;

inline Handle<Value> v8_from_cocoa(NSObject* obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *string = (NSString*)obj;
        const char* cString = [string UTF8String];
        Local<String> value = String::NewFromUtf8(isolate, cString);
        return value;
    }
    return Null(isolate);
}

inline NSObject* cocoa_from_v8(Handle<Value> value) {
    String::Utf8Value string(value);
    char* cString = *string;
    return [NSString stringWithUTF8String:cString];
}

extern "C" void node_cocoa_emit(NSObject* message) {
    node_emit(v8_from_cocoa(message));
}


void (*handle_message)(NSObject*);

void on_node_message(Handle<Value> value) {
    handle_message(cocoa_from_v8(value));
}

extern "C" int node_cocoa_main(int argc, char* argv[], void (*tick)(), void (*on_message)(NSObject*)) {
    handle_message = on_message;
    char** continuous_argv = node_fix_argv(argc, argv);
    return node_main(argc, continuous_argv, tick, on_node_message);
}
