//
//  DetailTableViewController.h
//  PushApp
//
//  Created by dianhui on 14-11-15.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseMgr.h"
#import "Msg.h"

@interface DetailTableViewController : UITableViewController {
    DatabaseMgr *dbMgr;
}
- (IBAction)onConfirmClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationItem *screenTitle;

@property (weak, nonatomic) IBOutlet UILabel *msgTitle;
@property (weak, nonatomic) IBOutlet UIImageView *divider1;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UIImageView *divider2;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *name2;
@property (weak, nonatomic) IBOutlet UIImageView *divider3;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *name3;
@property (weak, nonatomic) IBOutlet UIImageView *divider4;
@property (weak, nonatomic) IBOutlet UILabel *title4;
@property (weak, nonatomic) IBOutlet UILabel *name4;
@property (weak, nonatomic) IBOutlet UIImageView *divider5;
@property (weak, nonatomic) IBOutlet UILabel *title5;
@property (weak, nonatomic) IBOutlet UILabel *name5;
@property (weak, nonatomic) IBOutlet UIImageView *divider6;
@property (weak, nonatomic) IBOutlet UILabel *title6;
@property (weak, nonatomic) IBOutlet UILabel *name6;
@property (weak, nonatomic) IBOutlet UIImageView *divider7;
@property (weak, nonatomic) IBOutlet UILabel *title7;
@property (weak, nonatomic) IBOutlet UILabel *name7;
@property (weak, nonatomic) IBOutlet UIImageView *divider8;
@property (weak, nonatomic) IBOutlet UILabel *title8;
@property (weak, nonatomic) IBOutlet UILabel *name8;
@property (weak, nonatomic) IBOutlet UIImageView *divider9;
@property (weak, nonatomic) IBOutlet UILabel *title9;
@property (weak, nonatomic) IBOutlet UILabel *name9;

@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progress;

@property (strong, nonatomic) Msg *pushMsg;

@property (retain, nonatomic) NSURLConnection *proDetailConnection;
@property (retain, nonatomic) NSURLConnection *syncReadConnection;
@property (retain, nonatomic) NSURLConnection *syncAttendConnection;

@end
