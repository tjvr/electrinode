
#ifndef wrapper_hpp
#define wrapper_hpp

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#include "hello.hh"

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
TypeName(const TypeName&);                 \
void operator=(const TypeName&)

#import <node.h>
#import <node_platform.h>
#include "uv.h"
//#import "libplatform/libplatform.h" // v8::platform

using v8::V8;
using v8::Isolate;
using v8::Context;
using v8::HandleScope;
//using node::NodePlatform;
using node::IsolateData;
using node::Environment;

    
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
                          const char*** exec_argv) {
    node::Init(argc, argv, exec_argc, exec_argv);
}


/*
extern "C" int node_Start_isolate(Isolate* isolate, IsolateData* isolate_data,
                           int argc, const char* const* argv,
                           int exec_argc, const char* const* exec_argv) {
    return node::Start(isolate, isolate_data, argc, argv, exec_argc, exec_argv);
}
*/


extern "C" int NodeMain(int argc, char *argv[]) {
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
    

    int exit_code;
    
    {
        argv = uv_setup_args(argc, new_argv);
        uv_loop_t* loop = uv_default_loop();

        // This needs to run *before* V8::Initialize().
        int exec_argc;
        const char** exec_argv;
        node::Init(&argc, const_cast<const char**>(argv), &exec_argc, &exec_argv);

        // TODO set V8 entropy source
        
        // Initialize V8.
        /*
        V8::InitializeICUDefaultLocation(argv[0]);
        V8::InitializeExternalStartupData(argv[0]);
        */
        
        /* v8_platform.Initialize(v8_thread_pool_size, uv_default_loop()); */
        int v8_thread_pool_size = 1;
        static node::NodePlatform* platform_;
        platform_ = new node::NodePlatform(v8_thread_pool_size, loop, nullptr);
        //static v8::Platform* platform_;
        //platform_ = v8::platform::CreateDefaultPlatform();
        V8::InitializePlatform(platform_);
        V8::Initialize();
        
        /* BEGIN Start(uv_default_loop(), argc, argv, exec_argc, exec_argv); */

        Isolate::CreateParams params;
        // TODO consider using node::ArrayBufferAllocator ?
        params.array_buffer_allocator = v8::ArrayBuffer::Allocator::NewDefaultAllocator();
        Isolate* const isolate = Isolate::New(params);
        if (isolate == nullptr)
            return 12;  // Signal internal error.
        
        v8::Locker locker(isolate);

        //isolate->AddMessageListener(OnMessage);
        //isolate->SetAbortOnUncaughtExceptionCallback(ShouldAbortOnUncaughtException);
        isolate->SetAutorunMicrotasks(false);
        //isolate->SetFatalErrorHandler(OnFatalError);
        
        Isolate::Scope isolate_scope(isolate);
        HandleScope handle_scope(isolate);
        node::IsolateData* isolate_data = node::CreateIsolateData(isolate, loop);
        
        /* BEGIN Start(isolate, &isolate_data, argc, argv, exec_argc, exec_argv); */
        
        // Create a new context.
        Local<Context> context = Context::New(isolate);
        assert(context->GetIsolate() != nullptr);
        
        // CHECK_EQ(0, uv_key_create(&thread_local_env));
        //uv_key_set(&thread_local_env, &env);
        
        node::Environment *env = node::CreateEnvironment(isolate_data, context, argc, argv, exec_argc, exec_argv);

        // env.set_abort_on_uncaught_exception(abort_on_uncaught_exception);
        
        //Environment::AsyncCallbackScope callback_scope(&env);
        //Environment::AsyncHooks::ExecScope exec_scope(&env, 1, 0);
        node::LoadEnvironment(env);
        
        
        
        bool more;
        do {
            more = uv_run(loop, UV_RUN_ONCE);
            if (more == false) {
                node::EmitBeforeExit(env);
         
                //plat.DrainVMTasks();
                
                // Emit `beforeExit` if the loop became alive either after emitting
                // event, or after running some callbacks.
                more = uv_loop_alive(loop);

                if (uv_run(loop, UV_RUN_NOWAIT) != 0)
                    more = true;
            }
        } while (more == true);
        
        exit_code = node::EmitExit(env);
        node::RunAtExit(env);
        
        node::FreeEnvironment(env);
        node::FreeIsolateData(isolate_data); // ???
    }

    V8::Dispose();
    
    return exit_code;
}

#endif /* wrapper_hpp */
