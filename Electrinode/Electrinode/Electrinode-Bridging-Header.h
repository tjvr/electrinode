//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifdef __cplusplus
extern "C" {
#endif
    
    int node_Start(int argc, char *argv[]);
    void node_Init(int* argc,
                   const char** argv,
                   int* exec_argc,
                   const char*** exec_argv);
    int NodeMain(int argc, char *argv[]);

#ifdef __cplusplus
}
#endif

