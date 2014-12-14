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
    NSLog(@"url: %@", url);
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
    NSLog(@"url: %@", url);
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
    NSLog(@"url: %@", url);
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
        
        NSLog(@"connectionDidFinishLoading: %@",results);
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
        [self.confirm setTitle:@"感谢参与" forState:UIControlStateNormal];
        [self.confirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [dbMgr setMsgConfirm:[[NSNumber alloc] initWithInt:self.pushMsg.msgId] confirm:[[NSNumber alloc] initWithInt:1]];
    }
}

-(void)onRetrieveMsg: (Msg *)msg {
    
//    if (msg.msgContent.length > 0) {
//        self.screenTitle.title = msg.msgContent;
//    }
    
    if (msg.msgType == 1) {
        self.projectName.text = msg.attrVar3;
        self.companyName.text = msg.attrVar1;
        self.projectPhase.text = msg.attrVar2;
        self.fundSum.text = msg.attrVar6;
        self.contactPerson.text = msg.attrVar7;
        self.contactPhone.text = msg.attrVar8;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
        self.date.text = stringFromDate;
        self.bidSection.text = msg.attrVar5;
        if (msg.confirm == 0) {
            [self.confirm setTitle:@"确认招标" forState:UIControlStateNormal];
        } else {
            self.confirm.enabled = NO;
            [self.confirm setTitle:@"感谢参与" forState:UIControlStateNormal];
            [self.confirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        self.detailInfo.text = msg.attrLong1;
        
        return;
    }
    
    if (self.pushMsg.msgType == 9) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
        self.companyNameTitle.text = @"时间：";
        self.companyName.text = stringFromDate;
        self.detailInfo.text = msg.attrLong1;
        
        self.projectName.hidden = YES;
        self.companyName.hidden = YES;
        self.projectPhaseTitle.hidden = YES;
        self.projectPhase.hidden = YES;
        self.fundSumTitle.hidden = YES;
        self.fundSum.hidden = YES;
        self.contactPersonTitle.hidden = YES;
        self.contactPerson.hidden = YES;
        self.contactPhoneTitle.hidden = YES;
        self.contactPhone.hidden = YES;
        self.bidSectionTitle.hidden = YES;
        self.bidSection.hidden = YES;
        self.confirm.hidden = YES;
        self.dateTitle.hidden = YES;
        self.date.hidden = YES;
        
        return;
    }
    
    self.projectName.text = msg.attrVar4;
    self.companyName.text = msg.attrVar2;
    self.projectPhase.text = msg.attrVar3;
    self.fundSumTitle.text = @"编号：";
    self.fundSum.text = msg.attrVar1;
    self.contactPerson.text = msg.attrVar5;
    self.contactPhone.text = msg.attrVar6;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:[[NSDate alloc] initWithTimeIntervalSince1970: [msg.attrDate1 longLongValue]/1000]];
    self.date.text = stringFromDate;
    self.bidSectionTitle.hidden = YES;
    self.bidSection.hidden = YES;
    self.confirm.hidden = YES;
    self.detailInfo.text = msg.attrLong1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onConfirmClicked:(id)sender {
    [self syncAttendStatus];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *name;
    switch (section) {
        case 0:
            if (self.pushMsg.msgType == 9) {
                name = @"";
            } else {
                name = @"工程名称";
            }
            break;
        case 1:
            if (self.pushMsg.msgType == 9) {
                name = @"";
            } else {
                name = @"工程信息";
            }
            break;
        case 2:
            if (self.pushMsg.msgType == 1) {
                name = @"详细介绍";
            } else if(self.pushMsg.msgType == 9){
                name = @"通知正文";
            } else {
                name = @"招标范围";
            }
            break;
            
    }
    return name;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 100.0;
    switch (indexPath.section) {
        case 0:
            if (self.pushMsg.msgType == 9) {
                height = 0.0;
            } else {
                height = 43.0;
            }
            break;
        case 1:
            if (self.pushMsg.msgType == 1) {
                height = 307.0;
            } else if(self.pushMsg.msgType == 9) {
                height = 36.0;
            } else {
                height = 220.0;
            }
            break;
        case 2:
            height = 177.0;
            break;
            
    }
    return height;
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
