//
//  SharedManager.m
//  sunglance
//
//  Created by Takako INOUE on 2015/01/04.
//  Copyright (c) 2015年 Gunu App. All rights reserved.
//

#import "SharedManager.h"

@implementation SharedManager
+ (instancetype)sharedInstance {
    static SharedManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

@end
