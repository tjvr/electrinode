//
//  NodeBindings.m
//  Electrinode
//
//  Created by Tim on 08/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#import "NodeBindings.h"

#include <node.h>
#include <uv.h>
#include <v8.h>

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
TypeName(const TypeName&); \
void operator=(const TypeName&)
#include <node_platform.h>

#include "env.h"
#include "env-inl.h"
#include "node_buffer.h"
#include "node_debug_options.h"
#include "node_internals.h"


// TODO meh
#include "node_main.h"


using namespace v8;


void RunLoopSourcePerformRoutine (void *info) {
    NodeBindings* self = (__bridge NodeBindings*)info;
    [self uvRunOnce];
}


@implementation NodeBindings {
    CFRunLoopRef runLoop;
    CFRunLoopSourceRef source;
    
    int argc_;
    char** argv_;
    
    node::NodePlatform* platform_;
    Isolate* isolate;
    node::Environment* env;
    Handle<Context> context;
    
    uv_loop_t* uv_loop_;
    uv_async_t dummy_uv_handle_;
    uv_sem_t embed_sem_;
    uv_thread_t embed_thread_;
    BOOL embed_closed_;
}


-(id)initWithRunLoop:(CFRunLoopRef)rl {
    if (self = [super init]) {
        runLoop = rl;
        
        CFRunLoopSourceContext sourceContext = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
            NULL,
            NULL,
            RunLoopSourcePerformRoutine};
        source = CFRunLoopSourceCreate(NULL, 0, &sourceContext);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    }
    return self;
}

-(void) setupNodeWithArgs:(NSArray<NSString*>*)arguments {
    argc_ = (int)[arguments count];
    char** argv = (char**)malloc(argc_);
    for (int i=0; i<argc_; i++) {
        NSString* string = (NSString*)[arguments objectAtIndex:i];
        argv[i] = (char*)[string UTF8String];
    }
    
    argv_ = node_fix_argv(argc_, argv);
    
    // init UV
    argv_ = uv_setup_args(argc_, argv_);
    uv_loop_ = uv_default_loop();

    // This must be before V8::Initalize()
    int exec_argc;
    const char** exec_argv;
    node::Init(&argc_, const_cast<const char**>(argv), &exec_argc, &exec_argv);
    
    // Initialize V8.
    V8::InitializeICUDefaultLocation(argv[0]);
    V8::InitializeExternalStartupData(argv[0]);

    // We have to make a Node Platform, not a V8 one, because libnode doesn't export
    // the symbol v8::platform::CreateDefaultPlatform. This is fine!
    int v8_thread_pool_size = 1;
    platform_ = new node::NodePlatform(v8_thread_pool_size, uv_loop_, nullptr);
    
    V8::InitializePlatform(platform_);
    V8::Initialize();
    
    // Create a new Isolate and make it the current one.
    Isolate::CreateParams create_params;
    create_params.array_buffer_allocator =
    ArrayBuffer::Allocator::NewDefaultAllocator();
    isolate = Isolate::New(create_params);

    Isolate::Scope isolate_scope(isolate);

    // Create a stack-allocated handle scope.
    HandleScope handle_scope(isolate);

    // Create a template for the global object and set the
    // built-in global functions.
    Local<ObjectTemplate> global = ObjectTemplate::New(isolate);
    Local<ObjectTemplate> interface = ObjectTemplate::New(isolate);
    global->Set(String::NewFromUtf8(isolate, "__electrinode"), interface);

    
    //interface->Set(String::NewFromUtf8(isolate, "listen"), FunctionTemplate::New(isolate, ListenCallback));
    //interface->Set(String::NewFromUtf8(isolate, "send"), FunctionTemplate::New(isolate, SendCallback));

    // Create a new context.
    context = Context::New(isolate, NULL, global);

    // Enter the context for compiling and running the hello world script.
    //Context::Scope context_scope(context);

    node::IsolateData* isolate_data = node::CreateIsolateData(isolate, uv_loop_);
    node::Environment *env = node::CreateEnvironment(isolate_data, context, argc_, argv_, exec_argc, exec_argv);
    node::LoadEnvironment(env);
    
    env->process_object()
    
    [self uvRunOnce];
}

-(void) prepareMessageLoop {
    uv_loop_ = uv_loop_new();
    embed_closed_ = false;
    uv_async_init(uv_loop_, &dummy_uv_handle_, nullptr);
    
    // Add dummy handle for libuv, otherwise libuv would quit when there is
    // nothing to do.
    uv_async_init(uv_loop_, &dummy_uv_handle_, nullptr);
    
    // Start worker that will interrupt main loop when having uv events.
    uv_sem_init(&embed_sem_, 0);
    uv_thread_create(&embed_thread_, embedThreadRunner, (__bridge void *)self);
}

// static
void embedThreadRunner(void *arg) {
    NodeBindings* self = (__bridge NodeBindings*)(arg);
    
    while (true) {
        // Wait for the main loop to deal with events.
        uv_sem_wait(&self->embed_sem_);
        if (self->embed_closed_)
            break;
        
        // Wait for something to happen in uv loop.
        [self pollEvents];
        if (self->embed_closed_)
            break;
        
        // Deal with event in main thread.
        [self wakeUpMainThread];
    }
}

-(void)pollEvents {
    struct timeval tv;
    int timeout = uv_backend_timeout(uv_loop_);
    if (timeout != -1) {
        tv.tv_sec = timeout / 1000;
        tv.tv_usec = (timeout % 1000) * 1000;
    }
    
    fd_set readset;
    int fd = uv_backend_fd(uv_loop_);
    FD_ZERO(&readset);
    FD_SET(fd, &readset);
    
    // Wait for new libuv events.
    int r;
    do {
        r = select(fd + 1, &readset, nullptr, nullptr,
                   timeout == -1 ? nullptr : &tv);
    } while (r == -1 && errno == EINTR);
}

-(void)uvRunOnce {
    // Use Locker in browser process.
    v8::HandleScope handle_scope(isolate);
    
    // Enter node context while dealing with uv events.
    v8::Context::Scope context_scope(context);
    
    // Deal with uv events.
    int r = uv_run(uv_loop_, UV_RUN_NOWAIT);
    
    if (r == 0) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    // Tell the worker thread to continue polling.
    uv_sem_post(&embed_sem_);
}

-(void) wakeUpMainThread {
    CFRunLoopSourceSignal(source);
    CFRunLoopWakeUp(runLoop);
}

-(void) wakeUpEmbedThread {
    // wake UV if it's blocked inside uv_run(loop, UV_RUN_ONCE)
    uv_async_send(&dummy_uv_handle_);
}

-(void)shutdown {
    // Quit the embed thread.
    embed_closed_ = true;
    uv_sem_post(&embed_sem_);
    [self wakeUpEmbedThread];
    
    // Wait for everything to be done.
    uv_thread_join(&embed_thread_);
    
    // Clear uv.
    uv_sem_destroy(&embed_sem_);
    uv_close(reinterpret_cast<uv_handle_t*>(&dummy_uv_handle_), nullptr);
    
    // Destroy loop.
    uv_loop_delete(uv_loop_);
    
    // Shutdown V8.
    isolate->Dispose();
    V8::Dispose();
    V8::ShutdownPlatform();
    platform_->Shutdown(); // can't hurt

    CFRelease(source);
}

@end
