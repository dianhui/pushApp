//
//  RootTableViewController.m
//  PushApp
//
//  Created by dianhui on 14-11-16.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "AboutViewController.h"
#import "Constants.h"
#import "LoginViewController.h"
#import "HelpViewController.h"
#import "MainScreenTableViewController.h"
#import "RootTableViewController.h"
#import "XGPush.h"
#import "Util.h"

@interface RootTableViewController () {
    NSMutableData *recvData;
}

@end

@implementation RootTableViewController

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
    
    self.navigationController.title = @"首创招标客户端";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    if (userId == nil) {
        [self performSelector:@selector(showLoginView:) withObject:self afterDelay:0.0];
    } else {
        [XGPush setAccount:userId];
        [Util registerDevice];
    }
    
    if (mDbMgr == nil) {
        mDbMgr = [[DatabaseMgr alloc] init];
    }
    [self updateTxtViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged:) name:kDbChangeNotify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSucess:) name:kLoginSuccNotify object:nil];
    
    if (userId != nil) {
        [self retrieveMsgFromNet:userId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTxtViews {
    NSString *txt = [[NSString alloc] initWithFormat:@"(%d/%d)", [mDbMgr getUnreadCountByType:[[NSNumber alloc] initWithInt: 1]], [mDbMgr getTotalCountByType:[[NSNumber alloc] initWithInt: 1]]];
    self.inviteTxt.text = txt;
    
    txt = [[NSString alloc] initWithFormat:@"(%d/%d)", [mDbMgr getUnreadCountByType:[[NSNumber alloc] initWithInt: 2]], [mDbMgr getTotalCountByType:[[NSNumber alloc] initWithInt: 2]]];
    self.notifyTxt.text = txt;
    
    txt = [[NSString alloc] initWithFormat:@"(%d/%d)", [mDbMgr getUnreadCountByType:[[NSNumber alloc] initWithInt: 3]], [mDbMgr getTotalCountByType:[[NSNumber alloc] initWithInt: 3]]];
    self.qaTxt.text = txt;
    
    txt = [[NSString alloc] initWithFormat:@"(%d/%d)", [mDbMgr getUnreadCountByType:[[NSNumber alloc] initWithInt: 4]], [mDbMgr getTotalCountByType:[[NSNumber alloc] initWithInt: 4]]];
    self.congTxt.text = txt;
    
    txt = [[NSString alloc] initWithFormat:@"(%d/%d)", [mDbMgr getUnreadCountByType:[[NSNumber alloc] initWithInt: 9]], [mDbMgr getTotalCountByType:[[NSNumber alloc] initWithInt: 9]]];
    self.msgNotifyTxt.text = txt;
}

-(void)retrieveMsgFromNet: (NSString *)userId {
    //    self.progress.hidden = NO;
    //    [self.progress startAnimating];
    
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat:@"%@:%@/%@?%@=%@", kBaseUrl, kPort, kMsgListPath, @"user_id", userId];
    NSLog(@"url: %@", url);
    [request setURL:[NSURL URLWithString: url]];
    [request setTimeoutInterval:5.0];
    
    recvData = [[NSMutableData alloc] initWithData: nil];
    NSURLConnection *connetion = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connetion == nil) {
        // 创建失败
        NSLog(@"Failed to create connection.");
        //        self.progress.hidden = YES;
        //        [self.progress stopAnimating];
        return;
    }
}

// 收到回应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"receive the response");
    [recvData setLength:0];
    
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"get some data");
    [recvData appendData:data];
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *results = [[NSString alloc]
                         initWithBytes:[recvData bytes]
                         length:[recvData length]
                         encoding:NSUTF8StringEncoding];
    recvData = nil;
    
    NSLog(@"connectionDidFinishLoading: %@",results);
    NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if (err == nil) {
        NSLog(@"array size: %lu", (unsigned long)array.count);
        for (NSDictionary *dict in array) {
            Msg *msg = [[Msg alloc] init];
            msg.msgId = [[dict objectForKey:@"msgId"] intValue];
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
            msg.attrDate1 = [dict objectForKey:@"ATTRIBUTE_DATE1"];
            
            Msg *msgOld = [mDbMgr queryMsg:[[NSNumber alloc] initWithInt:msg.msgId]];
            if (![Util isMsgDataComplete:msgOld]) {
                [mDbMgr insertOrReplaceMsg:msg];
            } else {
                NSLog(@"msg already exists in the db.");
            }
        }
        [self updateTxtViews];
    } else {
        NSLog(@"Failed to parse project details data.");
    }
    
    //    self.progress.hidden = YES;
    //    [self.progress stopAnimating];
    return;
}

- (void)onLoginSucess: (NSNotification *)notification{
    NSLog(@"onLoginSucess ...");
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
    [self retrieveMsgFromNet:userId];
    
}

- (void)onDataChanged: (NSNotification *)notification{
    NSLog(@"onDataChanged ...");
    [self updateTxtViews];
}

-(void)showLoginView:(id)sender{
    LoginViewController *login = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:login animated:NO completion:nil];
    login = nil;
}

-(void)showHelpView:(id)sender {
    HelpViewController *help = (HelpViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    [self presentViewController:help animated:NO completion:nil];
    help = nil;
}

-(void)showAboutView:(id)sender {
    AboutViewController *about = (AboutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self presentViewController:about animated:NO completion:nil];
    about = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MainScreenTableViewController *mainScreen = [segue destinationViewController];
    if ([segue.identifier isEqualToString:kShowInviteMsgs]) {
        mainScreen.mMsgType = 1;
    } else if ([segue.identifier isEqualToString:kShowNotifyMsgs]) {
        mainScreen.mMsgType = 2;
    }  else if ([segue.identifier isEqualToString:kShowQaMsgs]) {
        mainScreen.mMsgType = 3;
    }  else if ([segue.identifier isEqualToString:kShowCongMsgs]) {
        mainScreen.mMsgType = 4;
    } else if ([segue.identifier isEqualToString:kShowMsgNotifyMsgs]) {
        mainScreen.mMsgType = 9;
    } else {
        mainScreen.mMsgType = -1;
    }
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:identifier];
    
    int row = indexPath.row;
    if(row == 0){
        cell.textLabel.text = @"退出";
    }else if (row == 1){
        cell.textLabel.text = @"帮助中心";
    }else if (row == 2){
        cell.textLabel.text = @"关于首创";
    }
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSelector:@selector(showLoginView:) withObject:self afterDelay:0.0];
            // Clear user access token.
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kUserId];
            break;
        case 1:
            [self performSelector:@selector(showHelpView:) withObject:self afterDelay:0.0];
            break;
        case 2:
            [self performSelector:@selector(showAboutView:) withObject:self afterDelay:0.0];
            break;
            
        default:
            break;
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (IBAction)onClickMore:(id)sender {
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(160.f, 44.0f, 160, 150)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = FALSE;
    [poplistview show];
}
@end
