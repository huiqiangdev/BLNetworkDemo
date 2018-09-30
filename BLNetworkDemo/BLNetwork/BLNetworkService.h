//
//  BLNetworkService.h
//  BLNetworkDemo
//  1.这一层存在的目的是隔离网络库的影响的问题
//  Created by lightning on 2018/9/17.
//  Copyright © 2018年 lightning. All rights reserved.
//  网络服务层

#import <Foundation/Foundation.h>

@interface BLNetworkService : NSProxy
+ (instancetype)shareService;
/**
 注册网络请求类的协议

 @param httpProtocol 协议名称
 @param handler 协议的处理者
 */
- (void)registerHttpProtocol:(Protocol *)httpProtocol handler:(id)handler;
@end
