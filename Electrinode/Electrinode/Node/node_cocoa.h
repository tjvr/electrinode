
#import <Foundation/Foundation.h>

@interface NodeCocoa: NSObject

+ (void)emit:(NSObject*) message;
+ (int)startWithArgs:(NSArray*)arguments onTick:(void (*)())onTick onMessage:(void (*)(NSObject*))onMessage;

@end
