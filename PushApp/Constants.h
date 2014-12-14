//
//  Constants.h
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#define kUserId @"user_id"
#define kDeviceToken @"device_token"

#define kBaseUrl @"http://202.96.35.35"
#define kPort @"80"
#define kLoginPath @"AppPush/user"
#define kMessagePath @"AppPush/message"
#define kMsgListPath @"AppPush/messages"

#define kDbChangeNotify @"dataChanged"
#define kLoginSuccNotify @"loginSucc"

#define kShowInviteMsgs @"showInviteMsgs"
#define kShowNotifyMsgs @"showNotifyMsgs"
#define kShowQaMsgs @"showQaMsgs"
#define kShowCongMsgs @"showCongMsgs"
#define kShowMsgNotifyMsgs @"showMsgNotifyMsgs"

#define kShowInviteScreen @"showInviteScreen"

#import <Foundation/Foundation.h>

@interface Constants : NSObject
@end