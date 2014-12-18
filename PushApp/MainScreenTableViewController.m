//
//  MainScreenTableViewController.m
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "Constants.h"
#import "DetailTableViewController.h"
#import "MainScreenTableViewController.h"
#import "LoginViewController.h"
#import "XGPush.h"
#import "DatabaseMgr.h"
#import "Util.h"

@interface MainScreenTableViewController () {
    NSMutableData *recvData;
}
@end

@implementation MainScreenTableViewController

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
    
    NSNumber *num = [[NSNumber alloc] initWithInt:self.mMsgType];
    self.screenTitle.title = [Util getTitleByMsgType: num];
    
    if (dbMgr == nil) {
        dbMgr = [[DatabaseMgr alloc] init];
    }
    msgList = [dbMgr getMsgListByType:[[NSNumber alloc] initWithInt: self.mMsgType]];
    [self.tableView reloadData];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChanged:) name:kDbChangeNotify object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDataChanged: (NSNotification *)notification{
    msgList = [dbMgr getMsgListByType:[[NSNumber alloc] initWithInt: self.mMsgType]];
    [self.tableView reloadData];
}

-(void)showLoginView:(id)sender{
    LoginViewController *login = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:login animated:NO completion:nil];
    login = nil;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [msgList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgCell" forIndexPath:indexPath];

    Msg *msg = [msgList objectAtIndex:indexPath.row];
    NSString *title = msg.msgContent;
    if (title == nil || title.length < 1) {
        NSNumber *num = [[NSNumber alloc] initWithInt:self.mMsgType];
        title = [Util getTitleByMsgType: num];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (indexPath.row + 1), msg.msgContent];
    if (msg.read == 1) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Msg *msg = [msgList objectAtIndex:indexPath.row];
        [dbMgr deleteMsgById: [[NSNumber alloc] initWithInt: msg.msgId ]];
        [msgList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDbChangeNotify object:nil];
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
        cell.textLabel.text = @"清除通知";
    }
    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s : %d", __func__, indexPath.row);
    switch (indexPath.row) {
        case 0:
            [self performSelector:@selector(showLoginView:) withObject:self afterDelay:0.0];
            // Clear user access token.
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kUserId];
            break;
        case 1:
            [dbMgr deleleMsgByType:[[NSNumber alloc] initWithInt: self.mMsgType]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDbChangeNotify object:nil];
            
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

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowInviteScreen]) {
        NSIndexPath *indexPath =[self.tableView indexPathForCell:sender];
        Msg *msg = [msgList objectAtIndex:indexPath.row];
        
        DetailTableViewController *detailScreen = [segue destinationViewController];
        detailScreen.pushMsg = msg;
    }
}

- (IBAction)onClickedMore:(id)sender {
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(160.f, 44.0f, 160, 120)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = FALSE;
    [poplistview show];
}

- (IBAction)onBackClicked:(id)sender {
    NSLog(@"onBackClicked ...");
    [self.navigationController popViewControllerAnimated:YES];
}
@end
