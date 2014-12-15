//
//  MainScreenTableViewController.h
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseMgr.h"
#import "UIPopoverListView.h"

@interface MainScreenTableViewController : UITableViewController <UIPopoverListViewDataSource, UIPopoverListViewDelegate> {
    DatabaseMgr *dbMgr;
    NSMutableArray *msgList;
}

- (IBAction)onClickedMore:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationItem *screenTitle;
@property (assign, nonatomic) int mMsgType;
@end
