
#include "node_main.h"

#ifdef __cplusplus
typedef void NSObject;
#else
#import <Foundation/Foundation.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

NodeValue wrap_v8_from_cocoa(NSObject* object);
NSObject* wrap_cocoa_from_v8(NodeValue value);
    
#ifdef __cplusplus
}
#endif
