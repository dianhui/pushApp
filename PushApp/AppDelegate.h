//
//  AppDelegate.h
//  PushApp
//
//  Created by dianhui on 14-11-11.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseMgr.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    DatabaseMgr *mDbMgr;
}

@property (strong, nonatomic) UIWindow *window;

@end
