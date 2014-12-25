//
//  DetailTableViewController.m
//  PushApp
//
//  Created by dianhui on 14-11-15.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "Constants.h"
#import "DetailTableViewController.h"
#import "Util.h"

@interface DetailTableViewController () {
    NSMutableData *recvProDetailData;
}

@end

@implementation DetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.progress.hidden = YES;
    NSNumber *num = [[NSNumber alloc] initWithInt:self.pushMsg.msgType];
    self.screenTitle.title = [Util getTitleByMsgType: num];
    
    if (dbMgr == nil) {
        dbMgr = [[DatabaseMgr alloc] init];
    }
    
    // get data from db first.
    num = [[NSNumber alloc] initWithInt:self.pushMsg.msgId];
    Msg *msg = [dbMgr queryMsg:num];
    [msg printLog];
    
    if (msg != nil && [Util isMsgDataComplete: msg]) {
        [self onRetrieveMsg:msg];
        [dbMgr setMsgRead:[[NSNumber alloc] initWithInt:msg.msgId] read: [[NSNumber alloc] initWithInt:1]];
        [self syncReadStatus];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDbChangeNotify object:nil];
    } else {
        [self retrieveInfoFromServer];
    }
}

- (void)retrieveInfoFromServer {
    self.progress.hidden = NO;
    [self.progress startAnimating];
    
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc] init];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *url = [[NSString alloc] initWithFormat:@"%@:%@/%@/%d?%@=%@", kBaseUrl, kPort, kMessagePath, self.pushMsg.msgId, @"user_id", userId];
    [request setURL:[NSURL URLWithString: url]];
    [request setTimeoutInterval:5.0];
    
    recvProDetailData = [[NSMutableData alloc] initWithData: nil];
    self.proDetailConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.proDetailConnection == nil) {
        // 创建失败
        NSLog(@"Failed to create connection.");
        self.progress.hidden = YES;
        [self.progress stopAnimating];
        return;
    }
}

-(void)syncReadStatus {
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc] init];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *url = [[NSString alloc] initWithFormat:@"%@:%@/%@/%d?%@=%@&%@=%@", kBaseUrl, kPort, kMessagePath, self.pushMsg.msgId, @"user_id", userId, @"type", @"read"];
    [request setURL:[NSURL URLWithString: url]];
    [request setTimeoutInterval:5.0];
    
    self.syncReadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.syncReadConnection == nil) {
        // 创建失败
        NSLog(@"Failed to create connection.");
        return;
    }
}

-(void)syncAttendStatus {
    self.progress.hidden = NO;
    [self.progress startAnimating];
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc] init];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    NSString *url = [[NSString alloc] initWithFormat:@"%@:%@/%@/%d?%@=%@&%@=%@", kBaseUrl, kPort, kMessagePath, self.pushMsg.msgId, @"user_id", userId, @"type", @"accept"];
    [request setURL:[NSURL URLWithString: url]];
    [request setTimeoutInterval:5.0];
    
    self.syncAttendConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (self.syncAttendConnection == nil) {
        // 创建失败
        NSLog(@"Failed to create connection.");
        self.progress.hidden = YES;
        [self.progress stopAnimating];
        return;
    }
}

// 收到回应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"receive the response");
    if (connection == self.proDetailConnection) {
        [recvProDetailData setLength:0];
    }
    
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"get some data");
    if (connection == self.proDetailConnection) {
        [recvProDetailData appendData:data];
    }
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == self.proDetailConnection) {
        NSString *results = [[NSString alloc]
                             initWithBytes:[recvProDetailData bytes]
                             length:[recvProDetailData length]
                             encoding:NSUTF8StringEncoding];
        recvProDetailData = nil;
        
        if ([results length] < 8) {
            [self.progress stopAnimating];
            return;
        }
        
        NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
        if (err == nil) {
            int status = [[dict objectForKey:@"status"] intValue];
            if (status == 0) {
                Msg *msg = [[Msg alloc] init];
                msg.msgId = self.pushMsg.msgId;
                msg.msgType = [[dict objectForKey:@"MSG_TYPE"] intValue];
                msg.msgContent = [dict objectForKey:@"MSG_CONTENT"];
                msg.attrVar1 = [dict objectForKey:@"ATTRIBUTE_VAR1"];
                msg.attrVar2 = [dict objectForKey:@"ATTRIBUTE_VAR2"];
                msg.attrVar3 = [dict objectForKey:@"ATTRIBUTE_VAR3"];
                msg.attrVar4 = [dict objectForKey:@"ATTRIBUTE_VAR4"];
                msg.attrVar5 = [dict objectForKey:@"ATTRIBUTE_VAR5"];
                msg.attrVar6 = [dict objectForKey:@"ATTRIBUTE_VAR6"];
                msg.attrVar7 = [dict objectForKey:@"ATTRIBUTE_VAR7"];
                msg.attrVar8 = [dict objectForKey:@"ATTRIBUTE_VAR8"];
                msg.attrLong1 = [dict objectForKey:@"ATTRIBUTE_LONG1"];
                msg.attrDate1 = [[NSString alloc] initWithFormat:@"%@", [dict objectForKey:@"ATTRIBUTE_DATE1"]];
                msg.read = 1;
                
                Msg *msgOld = [dbMgr queryMsg:[[NSNumber alloc] initWithInt:msg.msgId]];
                if (![Util isMsgDataComplete:msgOld]) {
                    [dbMgr insertOrReplaceMsg:msg];
                }
                [self onRetrieveMsg:msg];
                
                [self syncReadStatus];
            } else {
                NSLog(@"Status is: %d", status);
            }
        } else {
            NSLog(@"Failed to parse project details data.");
        }
        
        self.progress.hidden = YES;
        [self.progress stopAnimating];
        return;
    }
    
    if (self.syncAttendConnection == connection) {
        self.progress.hidden = YES;
        [self.progress stopAnimating];
        self.confirm.enabled = NO;
        [self.confirm setTitle:@"已接受" forState:UIControlStateNormal];
        [self.confirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [dbMgr setMsgConfirm:[[NSNumber alloc] initWithInt:self.pushMsg.msgId] confirm:[[NSNumber alloc] initWithInt:1]];
    }
}

-(void)onRetrieveMsg: (Msg *)msg {
    if (msg.msgType == 1) {    //发标邀请函
        self.confirm.hidden = NO;
        self.msgTitle.text = msg.msgContent;

        self.divider1.hidden = NO;
        
        self.title1.hidden = NO;
        self.title1.text = @"公司名称：";
        self.name1.hidden = NO;
        self.name1.text = msg.attrVar1;
        
        self.divider2.hidden = NO;

        self.title2.hidden = NO;
        self.title2.text = @"项目分期：";
        self.name2.hidden = NO;
        self.name2.text = msg.attrVar2;
        
        self.divider3.hidden = NO;
        
        self.title3.hidden = NO;
        self.title3.text = @"招标工程名：";
        self.name3.hidden = NO;
        self.name3.text = msg.attrVar3;

        self.divider4.hidden = NO;
        
        self.title4.hidden = NO;
        self.title4.text = @"项目概况：";
        self.name4.hidden = NO;
        self.name4.text = msg.attrLong1;
        
        self.divider5.hidden = NO;
        
        self.title5.hidden = NO;
        self.title5.text = @"标段划分：";
        self.name5.hidden = NO;
        self.name5.text = msg.attrVar5;
        
        self.divider6.hidden = NO;
        
        self.title6.hidden = NO;
        self.title6.text = @"投标保证金：";
        self.name6.hidden = NO;
        self.name6.text = msg.attrVar6;
        
        self.divider7.hidden = NO;
        
        self.title7.hidden = NO;
        self.title7.text = @"联系人：";
        self.name7.hidden = NO;
        self.name7.text = msg.attrVar7;
        
        self.divider8.hidden = NO;
        
        self.title8.hidden = NO;
        self.title8.text = @"联系人电话：";
        self.name8.hidden = NO;
        self.name8.text = msg.attrVar8;
        
        self.divider9.hidden = NO;
        
        self.title9.hidden = NO;
        self.title9.text = @"发送日期：";
        self.name9.hidden = NO;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
        self.name9.text = stringFromDate;

        if (msg.confirm == 0) {
            [self.confirm setTitle:@"接受" forState:UIControlStateNormal];
        } else {
            self.confirm.enabled = NO;
            [self.confirm setTitle:@"已接受" forState:UIControlStateNormal];
            [self.confirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        return;
    }
    
    if (self.pushMsg.msgType == 2 ||
        self.pushMsg.msgType == 3 ||
        self.pushMsg.msgType == 4) {    //发标通知, 投标问卷，中标通知
        
        self.confirm.hidden = YES;
        self.msgTitle.text = msg.msgContent;
        
        self.divider1.hidden = NO;
        
        self.title1.hidden = NO;
        self.title1.text = @"招标编号：";
        self.name1.hidden = NO;
        self.name1.text = msg.attrVar1;
        
        self.divider2.hidden = NO;
        
        self.title2.hidden = NO;
        self.title2.text = @"公司名称：";
        self.name2.hidden = NO;
        self.name2.text = msg.attrVar2;
        
        self.divider3.hidden = NO;
        
        self.title3.hidden = NO;
        self.title3.text = @"项目分期：";
        self.name3.hidden = NO;
        self.name3.text = msg.attrVar3;
        
        self.divider4.hidden = NO;
        
        self.title4.hidden = NO;
        self.title4.text = @"招标工程名：";
        self.name4.hidden = NO;
        self.name4.text = msg.attrVar4;
        
        self.divider5.hidden = NO;
        
        self.title5.hidden = NO;
        self.title5.text = @"招标范围：";
        self.name5.hidden = NO;
        self.name5.text = msg.attrLong1;
        
        self.divider6.hidden = NO;
        
        self.title6.hidden = NO;
        self.title6.text = @"联系人：";
        self.name6.hidden = NO;
        self.name6.text = msg.attrVar5;
        
        self.divider7.hidden = NO;
        
        self.title7.hidden = NO;
        self.title7.text = @"发送日期：";
        self.name7.hidden = NO;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
        self.name7.text = stringFromDate;
        
        return;
    }
    
    if (self.pushMsg.msgType == 9) {
        self.confirm.hidden = YES;
        self.msgTitle.text = msg.msgContent;
        
        self.title1.hidden = NO;
        self.title1.text = @"通知正文：";
        self.name1.hidden = NO;
        self.name1.text = msg.attrLong1;
        
        self.divider1.hidden = NO;
        
        self.title2.hidden = NO;
        self.title2.text = @"发送日期：";
        self.name2.hidden = NO;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
        self.name2.text = stringFromDate;
        
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onConfirmClicked:(id)sender {
    [self syncAttendStatus];
}

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
