//
//  Util.h
//  PushApp
//
//  Created by dianhui on 14-11-13.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Msg.h"

@interface Util : NSObject

+(NSString *)getTitleByMsgType: (NSNumber *)type;
+(Boolean)isMsgDataComplete: (Msg *)msg;
+(NSString *)registerDevice;
@end
