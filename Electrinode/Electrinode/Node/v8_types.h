
#include "node_main.h"
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
NodeValue v8_from_cocoa(NSObject* object);
NSObject* cocoa_from_v8(NodeValue value);

#ifdef __cplusplus
} // extern "C"
#endif

