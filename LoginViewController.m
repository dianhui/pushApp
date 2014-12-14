//
//  LoginViewController.m
//  PushApp
//
//  Created by dianhui on 14-11-12.
//  Copyright (c) 2014年 dianhui. All rights reserved.
//

#import "Constants.h"
#import "LoginViewController.h"
#import "Util.h"
#import "XGPush.h"

@interface LoginViewController () {
    NSMutableData *receivedData;
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.progress.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onLoginBtnClicked:(id)sender {
    [self doLogin:self.userName.text password:self.passWord.text];
}

- (IBAction)onEndEditUserName:(id)sender {
    [self.userName resignFirstResponder];
    [self.passWord becomeFirstResponder];
}

- (void)doLogin:(NSString *) userName password:(NSString *)password {
    self.progress.hidden = NO;
    self.loginFail.hidden = YES;
    [self.progress startAnimating];
    NSMutableURLRequest  *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat:@"%@:%@/%@?%@=%@&%@=%@", kBaseUrl, kPort, kLoginPath, @"name", userName, @"password", password];
    NSLog(@"login url: %@", url);
    [request setURL:[NSURL URLWithString: url]];
    [request setTimeoutInterval:5.0];
    
    receivedData = [[NSMutableData alloc] initWithData: nil];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection == nil) {
        // 创建失败
        NSLog(@"Failed to create connection.");
        self.progress.hidden = YES;
        [self.progress stopAnimating];
        self.loginFail.hidden = NO;
        return;
    }
}

// 收到回应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"receive the response");
    // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        NSLog(@"allHeaderFields: %@",dictionary);
    }
    [receivedData setLength:0];
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"get some data");
    [receivedData appendData:data];
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *results = [[NSString alloc]
                         initWithBytes:[receivedData bytes]
                         length:[receivedData length]
                         encoding:NSUTF8StringEncoding];
    receivedData = nil;
    self.progress.hidden = YES;
    [self.progress stopAnimating];
    
    NSLog(@"connectionDidFinishLoading: %@",results);
    
    NSData *jsonData = [results dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if (err != nil) {
        NSLog(@"Failed to login.");
        self.loginFail.hidden = NO;
        return;
    }
    
    int status = [[dict objectForKey:@"status"] intValue];
    if (status == 1) {
        NSLog(@"Failed to login.");
        self.loginFail.hidden = NO;
        return;
    }
    
    NSNumber *userId = [dict objectForKey:@"user_id"];
    // Save user access token.
    [[NSUserDefaults standardUserDefaults] setObject: userId forKey:kUserId];
    NSString *account = [[NSString alloc] initWithFormat:@"%d", userId.intValue];
    NSLog(@"XGPush account: %@", account);
    [XGPush setAccount: account];
    [Util registerDevice];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccNotify object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 返回错误


@end
