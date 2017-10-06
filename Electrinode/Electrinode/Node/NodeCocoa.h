
#import <Foundation/Foundation.h>

@interface NodeCocoa: NSObject

+ (void)awaken;
+ (void)emit:(id) message;
+ (int)startWithArgs:(NSArray<NSString*>*)arguments onTick:(void (*)())onTick onMessage:(void (*)(id))onMessage;

@end
