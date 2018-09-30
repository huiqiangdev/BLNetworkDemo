//
//  BLOperaionCotainer.m
//  BLNetworkDemo
//
//  Created by lightning on 2018/9/30.
//  Copyright © 2018 lightning. All rights reserved.
//

#import "BLOperaionCotainer.h"

@interface BLOperaionCotainer () {
    NSLock *_lock;
}
@property (nonatomic, strong) NSMutableArray *operations;
@end

@implementation BLOperaionCotainer


#pragma mark -懒加载
- (NSMutableArray *)operations {
    if (!_operations) {
        _operations = [[NSMutableArray alloc] init];
    }
    return _operations;
}
@end
