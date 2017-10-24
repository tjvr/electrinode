//
//  macros.h
//  Electrinode
//
//  Created by Tim on 24/10/2017.
//  Copyright © 2017 Electrinode. All rights reserved.
//

#ifndef macros_h
#define macros_h

#define STRING(cString) String::NewFromUtf8(isolate, cString)
#define LOCAL_STRING(nsString) ((Local<String>)String::NewFromUtf8(isolate, [nsString UTF8String]))
#define NS_STRING(localString) [NSString stringWithUTF8String: *(String::Utf8Value(localString))]

#endif /* macros_h */
