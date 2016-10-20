//
//  GCConfigure.m
//  GodCalendar
//
//  Created by ganyi on 2016/10/19.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import "GCConfigure.h"

@implementation GCConfigure

static GCConfigure *configure;
+(GCConfigure *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configure = [[GCConfigure alloc] init];
    });
    
    return configure;
}

@end
