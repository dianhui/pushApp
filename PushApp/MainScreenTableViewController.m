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
    cell.textLabel.text = [NSString stringWithFormat:@"%d. %@", (indexPath.row + 1), msg.msgContent];
    if (msg.read == 1) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

@end
