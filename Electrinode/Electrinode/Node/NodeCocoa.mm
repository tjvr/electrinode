
#include "NodeCocoa.h"
#include "node_main.h"

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;


static void (*handle_message)(id);
void on_node_message(Handle<Value> value) {
    //handle_message(value);
}

/* Wrap our C++ Node wrappers */
@implementation NodeCocoa

+ (void)awaken {
    node_awaken();
}

+(void)emit:(id) message {
    HandleScope handle_scope(isolate);
    //node_emit(message);
}

+(int)startWithArgs:(NSArray<NSString*>*)arguments onTick:(void (*)())onTick onMessage:(void (*)(id))onMessage {
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
