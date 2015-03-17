//
//  SharedManager.h
//  sunglance
//
//  Created by Takako INOUE on 2015/01/04.
//  Copyright (c) 2015年 Gunu App. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedManager : NSObject

@property NSString *targetName;
@property float targetLat;
@property float targetLong;
@property float currentLat;
@property float currentLong;

+ (SharedManager *)sharedInstance;


@end
