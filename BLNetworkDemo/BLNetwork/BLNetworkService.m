//
//  BLNetworkService.m
//  BLNetworkDemo
//
//  Created by lightning on 2018/9/17.
//  Copyright © 2018年 lightning. All rights reserved.
//

#import "BLNetworkService.h"
#import <objc/runtime.h>


@interface BLNetworkService ()
@property (nonatomic, strong) NSMutableDictionary *protocolHandlers;
@end

@implementation BLNetworkService
+ (instancetype)shareService {
    static BLNetworkService *_shareService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareService = [BLNetworkService alloc];
        _shareService.protocolHandlers = [NSMutableDictionary dictionary];
    });
    return _shareService;
}

- (void)registerHttpProtocol:(Protocol *)httpProtocol handler:(id)handler {
    unsigned int numberOfMethods = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(httpProtocol, YES, YES, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; i++) {
        struct objc_method_description method = methods[i];
        [_protocolHandlers setValue:handler forKey:NSStringFromSelector(method.name)];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSString *methodsName = NSStringFromSelector(sel);
    id handler = [_protocolHandlers valueForKey:methodsName];
    
    if (handler != nil && [handler respondsToSelector:sel]) {
        return [handler methodSignatureForSelector:sel];
    } else {
        return [super methodSignatureForSelector:sel];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *methodsName = NSStringFromSelector(invocation.selector);
    id handler = [_protocolHandlers valueForKey:methodsName];
    
    if (handler != nil && [handler respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:handler];
    } else {
        [super forwardInvocation:invocation];
    }
}


@end
