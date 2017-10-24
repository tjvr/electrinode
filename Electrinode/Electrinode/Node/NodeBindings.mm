//
//  NodeBindings.m
//  Electrinode
//
//  Created by Tim on 08/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//


/*
#define NODE_WANT_INTERNALS 1
#include <env.h>
#undef NODE_WANT_INTERNALS
*/

#include <node.h>
#include <node_internals.h>

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
TypeName(const TypeName&); \
void operator=(const TypeName&)
#include <node_platform.h>

#import "NodeBindings.h"
#import "NodeInterface.hh"

#include <uv.h>
#include <v8.h>




using namespace v8;


void RunLoopSourcePerformRoutine (void *info) {
    NodeBindings* self = (__bridge NodeBindings*)info;
    [self uvRunOnce];
}

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


@implementation NodeBindings {
    CFRunLoopRef runLoop;
    CFRunLoopSourceRef source;
    
    int argc_;
    char** argv_;
    
    NodeInterface* api;
    node::NodePlatform* platform_;
    Isolate* isolate;
    node::IsolateData* isolate_data;
    node::Environment* node_env_;
    Persistent<Context> context_;
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
    
    /*
    // run the UV loop once to check it's happy
    uv_run(uv_loop_, (uv_run_mode)(UV_RUN_NOWAIT));
    */
    
    // This must be before V8::Initialize()
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
    // TODO use an ARC-based allocator?
    create_params.array_buffer_allocator = ArrayBuffer::Allocator::NewDefaultAllocator();
    isolate = Isolate::New(create_params);
    
    Isolate::Scope isolate_scope(isolate);

    // Create a stack-allocated handle scope.
    HandleScope handle_scope(isolate);
    
    // Create a template for the global object and set the
    // built-in global functions.
    Local<ObjectTemplate> global = ObjectTemplate::New(isolate);
    
    api = [[NodeInterface alloc] init];
    [api bindTo:global isolate:isolate];
    
    // Create a new context.
    Local<Context> context = Context::New(isolate, NULL, global);
    context_.Reset(isolate, context);

    // Enter the context for compiling and running the hello world script.
    Context::Scope context_scope(context);
    
    isolate_data = node::CreateIsolateData(isolate, uv_loop_);
    node_env_ = node::CreateEnvironment(isolate_data, context, argc_, argv_, exec_argc, exec_argv);
    node::LoadEnvironment(node_env_);
    
    
    [self prepareMessageLoop];
    
    // Start things off
    // For some reason, UV gets sad if we do the first run outside of setupNode
    // TODO fix this
    [self uvRunOnce];
    
    NSLog(@"party");
}

-(void) start {
    //[self uvRunOnce];
}

-(void) prepareMessageLoop {
    assert(uv_loop_ != NULL);
    embed_closed_ = false;
    
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
    HandleScope handle_scope(isolate);
    
    Local<Context> context = Local<Context>::New(isolate, context_);
    
    // Enter node context while dealing with uv events.
    Context::Scope context_scope(context);
    
    // Deal with uv events.
    // Only run one loop (or V8 crashes??), and don't block on sockets,
    // since we listen on backend_fd in the embed thread.
    int r = uv_run(uv_loop_, (uv_run_mode)(UV_RUN_NOWAIT));
    
    /*
    if (r == 0 || uv_loop_->stop_flag != 0)
        message_loop_->QuitWhenIdle();  // Quit from uv.
    */
    /*
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
     
     exit_code = node::EmitExit(env);
     node::RunAtExit(env);
    */
    
    if (r == 0) {
        [self shutdown]; // ?? test this
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
    [self wakeUpEmbedThread];
    
    // Wait for everything to be done.
    uv_thread_join(&embed_thread_);
    
    // Cleanup node.
    node::FreeEnvironment(node_env_);
    node::FreeIsolateData(isolate_data);

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
