
#import <Foundation/Foundation.h>

#include "node_main.h"

#ifdef __cplusplus
extern "C" {
#endif

NodeValue v8_from_cocoa(NSObject* object);
NSObject* cocoa_from_v8(NodeValue value);
    
#ifdef __cplusplus
} // extern "C"
#endif
