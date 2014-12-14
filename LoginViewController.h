//
//  LoginViewController.h
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)onLoginBtnClicked:(id)sender;
- (IBAction)onEndEditUserName:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UILabel *loginFail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progress;
@end
