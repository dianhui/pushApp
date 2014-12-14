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
@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *companyNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *projectPhaseTitle;
@property (weak, nonatomic) IBOutlet UILabel *projectPhase;
@property (weak, nonatomic) IBOutlet UILabel *fundSumTitle;
@property (weak, nonatomic) IBOutlet UILabel *fundSum;
@property (weak, nonatomic) IBOutlet UILabel *contactPersonTitle;
@property (weak, nonatomic) IBOutlet UILabel *contactPerson;
@property (weak, nonatomic) IBOutlet UILabel *contactPhoneTitle;
@property (weak, nonatomic) IBOutlet UILabel *contactPhone;
@property (weak, nonatomic) IBOutlet UILabel *dateTitle;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *bidSectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *bidSection;
@property (weak, nonatomic) IBOutlet UIButton *confirm;
@property (weak, nonatomic) IBOutlet UILabel *detailInfo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progress;

@property (strong, nonatomic) Msg *pushMsg;

@property (retain, nonatomic) NSURLConnection *proDetailConnection;
@property (retain, nonatomic) NSURLConnection *syncReadConnection;
@property (retain, nonatomic) NSURLConnection *syncAttendConnection;

@end
