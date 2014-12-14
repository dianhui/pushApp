//
//  Msg.m
//  PushApp
//
//  Created by dianhui on 14-11-15.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "Msg.h"

@implementation Msg
-(id)init {
    self = [super init];
    if (self != nil) {
        self.msgId = -1;
        self.msgType = -1;
        self.msgContent = @"";
        self.attrVar1 = @"";
        self.attrVar2 = @"";
        self.attrVar3 = @"";
        self.attrVar4 = @"";
        self.attrVar5 = @"";
        self.attrVar6 = @"";
        self.attrVar7 = @"";
        self.attrVar8 = @"";
        self.attrLong1 = @"";
        self.attrDate1 = @"";
        self.read = 0;
        self.confirm = 0;
    }
    return self;
}

-(void)printLog {
    NSLog(@"-----msg--------");
    NSLog(@"msgId: %d, msgType: %d, msgContent: %@ \
          \n attrVar1: %@, attrVar2: %@, attrVar3: %@\
          \n attrVar4: %@, attrVar5: %@, attrVar6: %@\
          \n attrVar7: %@, attrVar8: %@, attrLong1: %@\
          \n attrDate1: %@, read: %d, confirm: %d", self.msgId, self.msgType, self.msgContent, self.attrVar1, self.attrVar2, self.attrVar3, self.attrVar4, self.attrVar5, self.attrVar6, self.attrVar7, self.attrVar8, self.attrLong1, self.attrDate1, self.read, self.confirm);
}

@end
