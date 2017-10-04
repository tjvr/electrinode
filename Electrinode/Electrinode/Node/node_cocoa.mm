
#include "node_cocoa.h"
#include "node_main.h"

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;


/* Convert NSObjects to V8 values. */
inline Handle<Value> v8_from_cocoa(NSObject* obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *string = (NSString*)obj;
        const char* cString = [string UTF8String];
        Local<String> value = String::NewFromUtf8(isolate, cString);
        return value;
    }
    return Null(isolate);
}

/* Convert V8 values to NSObjects. */
inline NSObject* cocoa_from_v8(Handle<Value> value) {
    String::Utf8Value string(value);
    char* cString = *string;
    return [NSString stringWithUTF8String:cString];
}

static void (*handle_message)(NSObject*);
void on_node_message(Handle<Value> value) {
    handle_message(cocoa_from_v8(value));
}

/* Wrap our C++ Node wrappers */
@implementation NodeCocoa

+(void)emit:(NSObject*) message {
    node_emit(v8_from_cocoa(message));
}

+(int)startWithArgs:(NSArray*)arguments onTick:(void (*)())onTick onMessage:(void (*)(NSObject*))onMessage {
    int argc = (int)[arguments count];
    char** argv = (char**)malloc(argc);
    for (int i=0; i<argc; i++) {
        NSString* string = (NSString*)[arguments objectAtIndex:i];
        argv[i] = (char*)[string UTF8String];
    }
    
    handle_message = onMessage;
    char** continuous_argv = node_fix_argv(argc, argv);
    return node_main(argc, continuous_argv, onTick, on_node_message);
}

@end
