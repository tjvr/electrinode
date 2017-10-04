
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void node_cocoa_emit(NSObject* message);
int node_cocoa_main(int argc, char* argv[], void (*tick)(), void (*on_message)(NSObject*));

#ifdef __cplusplus
} // extern "C"
#endif

