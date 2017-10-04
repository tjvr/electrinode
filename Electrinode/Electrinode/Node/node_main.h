#ifndef _node_main_h
#define _node_main_h

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __cplusplus
#include <v8.h>
typedef v8::Handle<v8::Value> NodeValue;
#else
typedef struct NodeValue {} NodeValue;
#endif

char** node_fix_argv(int argc, char *argv[]);

void node_emit(NodeValue message);
int node_main(int argc, char* argv[], void (*tick)(), void (*on_message)(NodeValue));

#ifdef __cplusplus
extern v8::Isolate* isolate;
#endif

#ifdef __cplusplus
} // extern "C"
#endif
#endif
