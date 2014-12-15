//
//  DatabaseMgr.m
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "DatabaseMgr.h"

@interface DatabaseMgr()
-(void)initDb;
@end

@implementation DatabaseMgr

-(id)init {
    self = [super init];
    if (self != nil) {
        [self initDb];
    }
    return self;
}

-(void)initDb {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"push_msg.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath] == YES) {
        NSLog(@"Db file exists.");
        return;
    }
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) == SQLITE_OK) {
        char *errMsg;
        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS MSG(ID INTEGER PRIMARY KEY AUTOINCREMENT, MSG_ID INTEGER UNIQUE, MSG_TYPE INTEGER, MSG_CONTENT TEXT, ATTRIBUTE_VAR1 TEXT, ATTRIBUTE_VAR2 TEXT, ATTRIBUTE_VAR3 TEXT, ATTRIBUTE_VAR4 TEXT, ATTRIBUTE_VAR5 TEXT, ATTRIBUTE_VAR6 TEXT, ATTRIBUTE_VAR7 TEXT, ATTRIBUTE_VAR8 TEXT, ATTRIBUTE_LONG1 TEXT, ATTRIBUTE_DATE1 TEXT, READ INTEGER, CONFIRM INTEGER, FLAG INTEGER)";
        if (sqlite3_exec(pushMsgDb, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create message table.");
        }
    } else {
        NSLog(@"Failed to open push_msg database.");
    }
}

-(Msg *)queryMsg: (NSNumber *) msgId {
    Msg *msg = nil;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return msg;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * from MSG where MSG_ID=%d", msgId.intValue];
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"No result for the query: %@", sqlQuery);
        sqlite3_close(pushMsgDb);
        return msg;
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        msg = [[Msg alloc] init];
        int msgId = sqlite3_column_int(statement, 1);
        msg.msgId = msgId;
        
        int msgType = sqlite3_column_int(statement, 2);
        msg.msgType = msgType;
        
        char *content_p = (char*)sqlite3_column_text(statement, 3);
        NSString *content = [[NSString alloc]initWithUTF8String:content_p];
        msg.msgContent = content;
        
        char *atrr_var1_p = (char*)sqlite3_column_text(statement, 4);
        NSString *atrr_var1 = [[NSString alloc]initWithUTF8String:atrr_var1_p];
        msg.attrVar1 = atrr_var1;

        char *atrr_var2_p = (char*)sqlite3_column_text(statement, 5);
        NSString *atrr_var2 = [[NSString alloc]initWithUTF8String:atrr_var2_p];
        msg.attrVar2 = atrr_var2;
        
        char *atrr_var3_p = (char*)sqlite3_column_text(statement, 6);
        NSString *atrr_var3 = [[NSString alloc]initWithUTF8String:atrr_var3_p];
        msg.attrVar3 = atrr_var3;
        
        char *atrr_var4_p = (char*)sqlite3_column_text(statement, 7);
        NSString *atrr_var4 = [[NSString alloc]initWithUTF8String:atrr_var4_p];
        msg.attrVar4 = atrr_var4;
        
        char *atrr_var5_p = (char*)sqlite3_column_text(statement, 8);
        NSString *atrr_var5 = [[NSString alloc]initWithUTF8String:atrr_var5_p];
        msg.attrVar5 = atrr_var5;
        
        char *atrr_var6_p = (char*)sqlite3_column_text(statement, 9);
        NSString *atrr_var6 = [[NSString alloc]initWithUTF8String:atrr_var6_p];
        msg.attrVar6 = atrr_var6;
        
        char *atrr_var7_p = (char*)sqlite3_column_text(statement, 10);
        NSString *atrr_var7 = [[NSString alloc]initWithUTF8String:atrr_var7_p];
        msg.attrVar7 = atrr_var7;
        
        char *atrr_var8_p = (char*)sqlite3_column_text(statement, 11);
        NSString *atrr_var8 = [[NSString alloc]initWithUTF8String:atrr_var8_p];
        msg.attrVar8 = atrr_var8;
        
        char *atrr_long1_p = (char*)sqlite3_column_text(statement, 12);
        NSString *atrr_long1 = [[NSString alloc]initWithUTF8String:atrr_long1_p];
        msg.attrLong1 = atrr_long1;
        
        char *atrr_date1_p = (char*)sqlite3_column_text(statement, 13);
        NSString *atrr_date1 = [[NSString alloc]initWithUTF8String:atrr_date1_p];
        msg.attrDate1 = atrr_date1;
        
        int read = sqlite3_column_int(statement, 14);
        msg.read = read;
        
        int confirm = sqlite3_column_int(statement, 15);
        msg.confirm = confirm;
    }
    sqlite3_finalize(statement);
    sqlite3_close(pushMsgDb);
    return msg;
}

-(void)insertOrReplaceMsg: (Msg *)msg {
    sqlite3_stmt *statement;
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open push_msg database.");
        return;
    }

    NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO MSG(MSG_ID, MSG_TYPE, MSG_CONTENT, ATTRIBUTE_VAR1, ATTRIBUTE_VAR2, ATTRIBUTE_VAR3, ATTRIBUTE_VAR4, ATTRIBUTE_VAR5, ATTRIBUTE_VAR6, ATTRIBUTE_VAR7, ATTRIBUTE_VAR8, ATTRIBUTE_LONG1, ATTRIBUTE_DATE1, READ, CONFIRM) VALUES(%d, %d, \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %d, %d)", msg.msgId, msg.msgType, msg.msgContent, msg.attrVar1, msg.attrVar2, msg.attrVar3, msg.attrVar4, msg.attrVar5, msg.attrVar6, msg.attrVar7, msg.attrVar8, msg.attrLong1, msg.attrDate1, msg.read, msg.confirm];
    
    NSLog(@"insert: %@", insertSQL);
    
    const char *insert_stmt = [insertSQL UTF8String];
    sqlite3_prepare_v2(pushMsgDb, insert_stmt, -1, &statement, NULL);
    int result = sqlite3_step(statement);
    if (result == SQLITE_DONE) {
        NSLog(@"Success to insert or replace db.");
    } else {
        NSLog(@"Failed to insert or replace db, error: %d", result);
    }
    sqlite3_finalize(statement);
    sqlite3_close(pushMsgDb);
}

-(Boolean)deleteMsgById: (NSNumber *)msgId {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return NO;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"DELETE FROM MSG WHERE MSG_ID=%d", msgId.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to delete from msg table.");
        sqlite3_close(pushMsgDb);
        return NO;
    }
    
    int success = sqlite3_step(statement);
    if (success == SQLITE_DONE) {
        sqlite3_finalize(statement);
        sqlite3_close(pushMsgDb);
        return YES;
    }
    
    sqlite3_close(pushMsgDb);
    NSLog(@"Failed to delete from msg table.");
    return NO;
}

-(Boolean)deleleMsgByType: (NSNumber *)type {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return NO;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"DELETE FROM MSG WHERE MSG_TYPE=%d", type.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to delete from msg table.");
        sqlite3_close(pushMsgDb);
        return NO;
    }
    
    int success = sqlite3_step(statement);
    if (success == SQLITE_DONE) {
        sqlite3_finalize(statement);
        sqlite3_close(pushMsgDb);
        return YES;
    }
    
    sqlite3_close(pushMsgDb);
    NSLog(@"Failed to delete from msg table.");
    return NO;
}

-(NSMutableArray *)getMsgListByType:(NSNumber *) msgType {
    NSMutableArray *queryResult = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return queryResult;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT MSG_ID, MSG_TYPE, MSG_CONTENT, READ from MSG where MSG_TYPE=%d", msgType.intValue];
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"No result for the query: %@", sqlQuery);
        sqlite3_close(pushMsgDb);
        return queryResult;
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        Msg *msg = [[Msg alloc] init];
        int msgId = sqlite3_column_int(statement, 0);
        msg.msgId = msgId;
        
        int msgType = sqlite3_column_int(statement, 1);
        msg.msgType = msgType;
        
        char *content_p = (char*)sqlite3_column_text(statement, 2);
        NSString *content = [[NSString alloc]initWithUTF8String:content_p];
        msg.msgContent = content;
        
        int read = sqlite3_column_int(statement, 3);
        msg.read = read;
        
        [queryResult addObject:msg];
    }
    sqlite3_close(pushMsgDb);
    
    return queryResult;
}

-(Boolean)setMsgRead:(NSNumber *)msgId read:(NSNumber *)readValue{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return NO;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE MSG set READ=%d WHERE MSG_ID=%d", readValue.intValue, msgId.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to update msg table.");
        sqlite3_close(pushMsgDb);
        return NO;
    }

    int success = sqlite3_step(statement);
    NSLog(@"sucess: %d", success);
    sqlite3_finalize(statement);
    sqlite3_close(pushMsgDb);
    
    if (success == SQLITE_DONE) {
        return YES;
    }
    
    NSLog(@"Failed to update msg database.");
    return NO;
}

-(Boolean)setMsgConfirm:(NSNumber *)msgId confirm:(NSNumber *)confirmValue {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return NO;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE MSG set CONFIRM=%d WHERE MSG_ID=%d", confirmValue.intValue, msgId.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to update msg table.");
        sqlite3_close(pushMsgDb);
        return NO;
    }
    
    int success = sqlite3_step(statement);
    if (success == SQLITE_DONE) {
        sqlite3_finalize(statement);
        sqlite3_close(pushMsgDb);
        return YES;
    }

    sqlite3_close(pushMsgDb);
    NSLog(@"Failed to update msg database.");
    return NO;
}

-(int)getTotalCountByType:(NSNumber *) msgType {
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return count;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT COUNT(*) from MSG WHERE MSG_TYPE=%d", msgType.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to select COUNT(*), error: %s", sqlite3_errmsg(pushMsgDb));
        sqlite3_close(pushMsgDb);
        return count;
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        count = sqlite3_column_int(statement, 0);
    } else {
        NSLog(@"Failed to select COUNT(*), error: %s", sqlite3_errmsg(pushMsgDb));
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(pushMsgDb);
    return count;
}

-(int)getUnreadCountByType:(NSNumber *) msgType {
    int count = 0;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &pushMsgDb) != SQLITE_OK) {
        NSLog(@"Failed to open database.");
        return count;
    }
    
    sqlite3_stmt *statement;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT COUNT(*) from MSG WHERE (MSG_TYPE=%d AND READ=0)", msgType.intValue];
    NSLog(@"sqlQuery: %@", sqlQuery);
    if (sqlite3_prepare_v2(pushMsgDb, [sqlQuery UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Failed to select COUNT(*), error: %s", sqlite3_errmsg(pushMsgDb));
        sqlite3_close(pushMsgDb);
        return count;
    }
    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        count = sqlite3_column_int(statement, 0);
    } else {
        NSLog(@"Failed to select COUNT(*), error: %s", sqlite3_errmsg(pushMsgDb));
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(pushMsgDb);
    return count;
}

@end
