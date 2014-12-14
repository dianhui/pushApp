//
//  RootTableViewController.h
//  PushApp
//
//  Created by dianhui on 14-11-16.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseMgr.h"
#import "UIPopoverListView.h"

@interface RootTableViewController : UITableViewController <UIPopoverListViewDataSource, UIPopoverListViewDelegate> {
    DatabaseMgr *mDbMgr;
}
- (IBAction)onClickMore:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *inviteTxt;
@property (weak, nonatomic) IBOutlet UILabel *notifyTxt;
@property (weak, nonatomic) IBOutlet UILabel *qaTxt;
@property (weak, nonatomic) IBOutlet UILabel *congTxt;
@property (weak, nonatomic) IBOutlet UILabel *msgNotifyTxt;
@end
