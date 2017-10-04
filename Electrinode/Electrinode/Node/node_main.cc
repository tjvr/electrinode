// Copyright 2015 the V8 project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <node.h>

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
TypeName(const TypeName&); \
void operator=(const TypeName&)
#include <node_platform.h>

#include "node_main.h"

using namespace v8;



Isolate* isolate;

static Persistent<Function> js_listener;
void (*c_listener)(Handle<Value>);


/* Used for JS to set its receive callback, so we can emit */
static void ListenCallback(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  if (args.Length() != 1 || !args[0]->IsFunction()) {
    isolate->ThrowException(Exception::TypeError(
        String::NewFromUtf8(isolate, "Expected just Function")));
    return;
  }
  HandleScope handle_scope(isolate);
  Local<Function> cb = Local<Function>::Cast(args[0]);

  // Store receiver so we can call it later
  if (!js_listener.IsEmpty()) {
    printf("warning: previous listener was replaced\n");
  }
  js_listener.Reset(isolate, cb);
}


static void SendCallback(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  if (args.Length() != 1) {
    isolate->ThrowException(Exception::TypeError(
          String::NewFromUtf8(isolate, "Expected one argument")));
    return;
  }
  HandleScope scope(args.GetIsolate());
  Local<Value> message = args[0];

  // Dispatch the message to our host
  c_listener(message);
}


extern "C" {

char** node_fix_argv(int argc, char *argv[]) {
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
    
    return new_argv;
}

    
void node_emit(Handle<Value> message) {
  // Check the receiver is set
  if (js_listener.IsEmpty()) return;

  HandleScope scope(isolate);
  Local<Function> f = Local<Function>::New(isolate, js_listener);

  // Make array for sole argument
  const unsigned argc = 1;
    Local<Value> argv[argc] = {String::NewFromUtf8(isolate, "baa")};

  f->Call(isolate->GetCurrentContext()->Global(), argc, argv);
}

int node_main(int argc, char* argv[], void (*tick)(), void (*on_message)(Handle<Value>)) {
    c_listener = on_message;

    // init UV
    argv = uv_setup_args(argc, argv);
    uv_loop_t* loop = uv_default_loop();

    // This needs to run *before* V8::Initialize().
    int exec_argc;
    const char** exec_argv;
    node::Init(&argc, const_cast<const char**>(argv), &exec_argc, &exec_argv);

    // Initialize V8.
    V8::InitializeICUDefaultLocation(argv[0]);
    V8::InitializeExternalStartupData(argv[0]);

    // make a platform--use Node,
    // because libnode doesn't export the
    // symbol: platform::CreateDefaultPlatform
    int v8_thread_pool_size = 1;
    static node::NodePlatform* platform_ = new node::NodePlatform(v8_thread_pool_size, loop, nullptr);

    V8::InitializePlatform(platform_);
    V8::Initialize();

    // Create a new Isolate and make it the current one.
    Isolate::CreateParams create_params;
    create_params.array_buffer_allocator =
            ArrayBuffer::Allocator::NewDefaultAllocator();
    isolate = Isolate::New(create_params);

    int exit_code;
    {
        Isolate::Scope isolate_scope(isolate);

        // Create a stack-allocated handle scope.
        HandleScope handle_scope(isolate);

        // Create a template for the global object and set the
        // built-in global functions.
        Local<ObjectTemplate> global = ObjectTemplate::New(isolate);
        Local<ObjectTemplate> electrinode = ObjectTemplate::New(isolate);
        global->Set(String::NewFromUtf8(isolate, "__electrinode"), electrinode);
        electrinode->Set(String::NewFromUtf8(isolate, "listen"), FunctionTemplate::New(isolate, ListenCallback));
        electrinode->Set(String::NewFromUtf8(isolate, "send"), FunctionTemplate::New(isolate, SendCallback));

        // Create a new context.
        Local<Context> context = Context::New(isolate, NULL, global);

        // Enter the context for compiling and running the hello world script.
        Context::Scope context_scope(context);

        {
            node::IsolateData* isolate_data = node::CreateIsolateData(isolate, loop);
            node::Environment *env = node::CreateEnvironment(isolate_data, context, argc, argv, exec_argc, exec_argv);
            node::LoadEnvironment(env);

            bool more;
            do {
                {
                    HandleScope tick_scope(isolate);
                    tick();
                }

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
            node::FreeIsolateData(isolate_data);
        }
    }

    // Dispose the isolate and tear down V8.
    isolate->Dispose();
    V8::Dispose();
    V8::ShutdownPlatform();
    platform_->Shutdown(); // can't hurt
    delete create_params.array_buffer_allocator;
    return 0;
}

} // extern "C"

