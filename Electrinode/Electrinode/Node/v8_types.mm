
#include "v8_types.h"

using namespace v8;

Handle<Value> v8_from_cocoa(NSObject* object) {
    return String::NewFromUtf8(isolate, "moo");
}

NSObject* cocoa_from_v8(NodeValue value) {
    return nil;
}

