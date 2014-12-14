//
//  Msg.h
//  PushApp
//
//  Created by dianhui on 14-11-15.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Msg : NSObject {
}

-(id)init;
-(void)printLog;

@property (assign, nonatomic) int msgId;
@property (assign, nonatomic) int msgType;
@property (strong, nonatomic ) NSString *msgContent;
@property (strong, nonatomic) NSString *attrVar1;
@property (strong, nonatomic) NSString *attrVar2;
@property (strong, nonatomic) NSString *attrVar3;
@property (strong, nonatomic) NSString *attrVar4;
@property (strong, nonatomic) NSString *attrVar5;
@property (strong, nonatomic) NSString *attrVar6;
@property (strong, nonatomic) NSString *attrVar7;
@property (strong, nonatomic) NSString *attrVar8;
@property (strong, nonatomic) NSString *attrLong1;
@property (strong, nonatomic) NSString *attrDate1;
@property (assign, nonatomic) int read;
@property (assign, nonatomic) int confirm;

@end
