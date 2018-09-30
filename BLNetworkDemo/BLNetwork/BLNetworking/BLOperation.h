//
//  BLOperation.h
//  BLNetworkDemo
//
//  Created by lightning on 2018/9/30.
//  Copyright © 2018 lightning. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLOperation : NSObject

@property (nonatomic, copy) void(^callBack)(void);

- (void)run;
- (void)leave;
- (void)enter;
- (void)runDefaultOperation:(__kindof BLOperation *)operation callBack:(void(^)(void))callBack;


@end

NS_ASSUME_NONNULL_END
