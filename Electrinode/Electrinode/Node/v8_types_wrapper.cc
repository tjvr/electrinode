
// C++ file: wrap C++ types in C externs.
// this file may *not* import Foundation

#include "v8_types_wrapper.h"

using namespace v8;

// implemented in v8_types.mm
Handle<Value> v8_from_cocoa(NSObject* object);
NSObject* cocoa_from_v8(Handle<Value> value);

NodeValue wrap_v8_from_cocoa(NSObject* object) {
    return v8_from_cocoa(object);
}

NSObject* wrap_cocoa_from_v8(NodeValue value) {
    return cocoa_from_v8(value);
}


