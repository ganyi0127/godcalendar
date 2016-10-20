//
//  GodCalendarData.h
//  GodCalendar
//
//  Created by ganyi on 2016/10/19.
//  Copyright © 2016年 ganyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GodCalendarData : NSObject
@property (nonatomic, strong) NSMutableArray *curValues;
@property (nonatomic, strong) NSMutableArray *maxValues;
-(id)init;
@end
