
#ifndef wrapper_hpp
#define wrapper_hpp

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>


namespace node {
    
    int Start(int argc, char *argv[]);
    void Init(int* argc,
              const char** argv,
              int* exec_argc,
              const char*** exec_argv);
    
}


extern "C" int node_Start(int argc, char *argv[]) {
    // the expectation is that the argv elements are next to each other in memory
    // so let's go ahead and fix that
    
    /* Calculate how much memory we need for the argv strings. */
    int size = 0;
    for (int i = 0; i < argc; i++)
    size += strlen(argv[i]) + 1;
    
    char *buffer = (char *)malloc(size);
    char **new_argv = (char **)malloc(argc);
    
    char *pointer = buffer;
    for (int i = 0; i < argc; i++) {
        new_argv[i] = pointer;
        char *str = argv[i];
        do {
            *(pointer++) = *(str);
        } while (*(str++) != '\0');
    }
    // TODO this can sometimes fail :-(
    assert(pointer == buffer + size);
    
    return node::Start(argc, new_argv);
}
extern "C" void node_Init(int* argc,
                          const char** argv,
                          int* exec_argc,
                          const char*** exec_argv) { node::Init(argc, argv, exec_argc, exec_argv); }

#endif /* wrapper_hpp */
