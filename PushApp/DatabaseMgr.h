//
//  DatabaseMgr.h
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Msg.h"

@interface DatabaseMgr : NSObject {
    sqlite3 *pushMsgDb;
    NSString *databasePath;
}

-(id)init;
-(Msg *)queryMsg: (NSNumber *)msgId;
-(void)insertOrReplaceMsg: (Msg *)msg;
-(Boolean)deleteMsgById: (NSNumber *)msgId;
-(Boolean)deleleMsgByType: (NSNumber *)type;
-(NSMutableArray *)getMsgListByType:(NSNumber *) msgType;
-(int)getTotalCountByType:(NSNumber *) msgType;
-(int)getUnreadCountByType:(NSNumber *) msgType;
-(Boolean)setMsgRead:(NSNumber *)msgId read:(NSNumber *)readValue;
-(Boolean)setMsgConfirm:(NSNumber *)msgId confirm:(NSNumber *)confirmValue;

@end