
#include "node_cocoa.h"
#include "node_main.h"

// Objective-C++ file: interface between Cocoa and V8

using namespace v8;


/* Convert NSObjects to V8 values. */
inline Handle<String> v8_string_from_cocoa(NSString* string) {
    return String::NewFromUtf8(isolate, [string UTF8String]);
}

inline Handle<Value> v8_from_cocoa(id thing) {
    // Primitives
    if ([thing isKindOfClass:[NSNull class]]) {
        return Null(isolate);
    } else if ([thing isKindOfClass:[NSString class]]) {
        return v8_string_from_cocoa((NSString*)thing);
    } else if ([thing isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber*)thing;
        return Number::New(isolate, [number doubleValue]);
        
    // NSArray -> Array
    } else if ([thing isKindOfClass:[NSArray class]]) {
        NSArray* array = (NSArray*)thing;
        uint32_t count = (uint32_t)[array count];
        Local<Array> items = Array::New(isolate, count);
        for (uint32_t i = 0; i < count; i++) {
            items->Set(i, v8_from_cocoa([array objectAtIndex:i]));
        }
        return items;
    
    // NSDictionary -> Object
    } else if ([thing isKindOfClass:[NSDictionary class]]) {
        NSDictionary<NSString*,NSObject*>* dict = (NSDictionary<NSString*,NSObject*>*)thing;
        uint32_t count = (uint32_t)[dict count];
        Local<Object> object = Object::New(isolate);
        for (id key in dict) {
            object->Set(v8_string_from_cocoa(key), v8_from_cocoa(dict[key]));
        }
        return object;
    
    } else {
        return Null(isolate); // TODO panic
    }
}


/* Convert V8 values to NSObjects. */
inline NSString* cocoa_string_from_v8(Handle<Value> message) {
    String::Utf8Value string(message);
    return [NSString stringWithUTF8String:*string];
}

inline NSObject* cocoa_from_v8(Handle<Value> message) {
    HandleScope handle_scope(isolate);
    Local<Context> context = Context::New(isolate);
    
    if (message->IsObject()) {
        // Array -> NSArray
        if (message->IsArray()) {
            Local<Array> items = Local<Array>::Cast(message);
            uint32_t count = items->Length();
            NSMutableArray* array = [NSMutableArray arrayWithCapacity:count];
            for (uint32_t i = 0; i < count; i++) {
                [array addObject:cocoa_from_v8(items->Get(i))];
            }
            return array;
        
        // Object -> NSDictionary
        } else {
            Local<Object> object = message->ToObject();
            MaybeLocal<Array> maybe_props = object->GetOwnPropertyNames(context);
            if (maybe_props.IsEmpty()) {
                return @{};
            }
            Local<Array> props = maybe_props.ToLocalChecked();
            uint32_t count = props->Length();
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
            for (uint32_t i = 0; i < count; i++) {
                Local<Value> key = props->Get(i);
                NSObject* obj = cocoa_from_v8(object->Get(key));
                [dict setObject:obj forKey:cocoa_string_from_v8(key)];
            }
            return dict;
        }
        
    // primitives
    } else if (message->IsString() || message->IsStringObject()) {
        return cocoa_string_from_v8(message);
    } else if (message->IsNumber() || message->IsNumberObject()) {
        return [NSNumber numberWithDouble:message->NumberValue()];
    } else if (message->IsNull() || message->IsUndefined()) {
        return [NSNull null];

    } else {
        return nil; // panic
    }
}

static void (*handle_message)(id);
void on_node_message(Handle<Value> value) {
    handle_message(cocoa_from_v8(value));
}

/* Wrap our C++ Node wrappers */
@implementation NodeCocoa

+(void)emit:(id) message {
    node_emit(v8_from_cocoa(message));
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
