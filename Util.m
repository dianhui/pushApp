//
//  Util.m
//  PushApp
//
//  Created by dianhui on 14-11-13.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "Constants.h"
#import "Util.h"
#import "XGPush.h"

@implementation Util

+(NSString *)getTitleByMsgType: (NSNumber* )type {
    if (type.intValue == 1) {
        return @"招标邀请函";
    }
    
    if (type.intValue  == 2) {
        return @"发标通知";
    }
    
    if (type.intValue == 3) {
        return @"投标问卷";
    }
    
    if (type.intValue == 4) {
        return @"中标通知";
    }
    
    if (type.intValue == 9) {
        return @"其他通知";
    }

    
    return @"";
}

+(Boolean)isMsgDataComplete: (Msg *)msg {    
    if (msg.attrVar1.length == 0 && msg.attrVar2.length == 0 && msg.attrVar3.length == 0 && msg.attrVar4.length == 0 && msg.attrVar5.length == 0 && msg.attrVar6.length == 0 && msg.attrVar7.length == 0 && msg.attrVar8.length == 0 && msg.attrLong1.length == 0) {
        return false;
    }
    
    return true;
}

+(NSString *)registerDevice {
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]register successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]register errorBlock");
    };
    
    NSData *deviceToken = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    if (deviceToken == nil) {
        NSLog(@"Failed to register device to XGPush.");
        return nil;
    }
    
    return [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];
}

@end
