//
//  IBENewsReaderAppDelegate.m
//  IBENewsReader
//
//  Created by man9527 on 2010/12/14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "IBENewsReaderAppDelegate.h"
#import "User.h"
#import "UserService.h"
#import "NewsTabBarViewController.h"
#import "MBProgressHUD.h"
#import "UILoginView.h"
#import "UIAddPayView.h"
#import "LoginManager.h"
#import "URLManager.h"

@implementation IBENewsReaderAppDelegate

@synthesize window,newsTabBarViewController, loginManager, loginView, addPayView;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	newsTabBarViewController= [[NewsTabBarViewController alloc] init];
	loginManager = [[LoginManager alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginForm) name:@"ShowLoginForm" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddPayForm) name:@"ShowAddPayForm" object:nil];
	
	[UserService loadCacheUserAsLogonUser];
	User *u = [UserService currentLogonUser];
	
	// if user/passwd cached, try login and regardless the result
	if (u != NULL){
		loginManager.delegate=self;
		[loginManager login:u];
	}
	else {
		[self goToNewsTabBarViewController];
	}

	// [self goToNewsTabBarViewController];
	[window makeKeyAndVisible];
	
	return YES;
}

// DidLoginDelegate
- (void)didLoginResult:(bool) isSuccessful andReason:(NSString*)reason For:(User*) u
{
	[self goToNewsTabBarViewController];
}

- (void)displayNewView:(UIView *)viewToDisplay {
	// remove all views
	for( UIView* view in [window subviews] ) {
	 	[view removeFromSuperview];
	}
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:window cache:YES];
	[window addSubview:viewToDisplay];	
	[UIView commitAnimations];
}


- (void)goToNewsTabBarViewController
{
	[self displayNewView:newsTabBarViewController.view];
}

- (void)showLoginForm // :(NSNotification *)notification
{
	// [self.loginView release];
	
	// NSDictionary *defaultValue = [notification userInfo];
	
	if (!loginView)
	{
		loginView = [[UILoginView alloc] initWithTitle:@"會員登入" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"登入", nil];
	}
	/*
	if (defaultValue!=nil)
	{
		NSString *account = [defaultValue valueForKey:@"account"];
		NSString *pwd = [defaultValue valueForKey:@"password"];
		NSString *addpaykey = [defaultValue valueForKey:@"addpaykey"];
	
		if (account!=nil)
		{
			loginView.idTextField.text = account;
		}
		if (pwd!=nil)
		{
			loginView.passwordTextField.text = pwd;
		}
		if (addpaykey!=nil)
		{
			loginView.addPayTextField.text = addpaykey;
		}
	}*/

	[loginView show];
}

- (void)showAddPayForm // :(NSNotification *)notification
{
	// [self.addPayView release];
	
	// NSDictionary *defaultValue = [notification userInfo];

	if (!self.addPayView)
	{
		self.addPayView = [[UIAddPayView alloc] initWithTitle:@"請輸入儲值碼" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"儲值", nil];
	}
	/*
	if (defaultValue!=nil)
	{
		NSString *addpaykey = [defaultValue valueForKey:@"addpaykey"];
		
		if (addpaykey!=nil)
		{
			addPayView.addPayTextField.text = addpaykey;
		}
	}*/
	[addPayView show];
}

- (void)showLoading:(BOOL)show withText:(NSString*)message
{
	if (show)
	{
		if (loadingView == nil)
		{
			loadingView = [[MBProgressHUD alloc] initWithWindow:window];
		}
		[window addSubview:loadingView];
		loadingView.labelText = message;	
		[loadingView show:TRUE];
	}
	else {
		[loadingView hide:TRUE];
	}

}

- (BOOL)validateForPaidUser
{
	User* user = [UserService currentLogonUser];
	
	if (user==nil || ![user isPaid]) 
	{
		if (user==nil)
		{
			NSString *message = @"本服務僅提供給付費有效會員使用，請先登入";
		
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您尚未登入" message:message  delegate:self  cancelButtonTitle:@"僅試閱" otherButtonTitles:@"會員登入", nil];
			alert.tag=1000;
			[alert show];
			[alert release];		
		}
		else 
		{
			NSString *message = @"本服務僅提供給付費有效會員使用，請前往訂閱";
				
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"想要看更多內容？" message:message  delegate:self  cancelButtonTitle:@"僅試閱" otherButtonTitles:@"前往訂閱", nil];
			alert.tag=2000;
			[alert show];
			[alert release];		
		}
		
		return NO;
	}
	else {
		return YES;
	}

}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag==1000)
	{
		if (buttonIndex==1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoginForm" object:nil userInfo:nil];
		}
	}
	else if (alertView.tag==2000)
	{
		if (buttonIndex==1) {
			NSURL *url = [NSURL URLWithString:[URLManager getSubscribeURL]];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

- (void)dealloc {
	[newsTabBarViewController release];
	[loginManager release];
    [window release];
	[loadingView release];
	[loginView release];
	[addPayView release];
	
	[super dealloc];
}


@end
